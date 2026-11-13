// ============================================================
// 文件：01_clean_architecture.dart
// 阶段：高级
// 主题：整洁架构分层（presentation / domain / data）
// 学习目标：
//   1. 理解三层划分与「依赖只能向内」的规则
//   2. 掌握用例类（UseCase）如何隔离业务逻辑与 UI
//   3. 理解 domain 层不依赖 Flutter，因此可独立测试
// 运行方式：flutter run 后，在首页选择“01 整洁架构分层”
// 预计阅读时间：20 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

// ==================== domain 层（最内层，纯 Dart，不 import Flutter） ====================

/// 领域实体：业务世界的核心概念。
class Product {
  const Product({required this.id, required this.name, required this.price});

  final int id;
  final String name;
  final double price;
}

/// 仓库接口：domain 层只定义“要什么”，不关心“怎么取”。
/// 依赖方向：data 层实现它，presentation 层依赖它 —— 箭头永远朝内。
abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
}

/// 用例类：一个类只做一件业务动作，UI 只跟用例对话。
class GetProductsUseCase {
  GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call() async {
    final products = await _repository.fetchProducts();
    // 业务规则放这里：比如“按价格从低到高排序”，UI 和数据层都不用管
    products.sort((a, b) => a.price.compareTo(b.price));
    return products;
  }
}

// ==================== data 层（实现 domain 定义的接口） ====================

/// 模拟远程数据源：返回“原始数据”，并负责翻译成领域实体。
class FakeProductRepository implements ProductRepository {
  @override
  Future<List<Product>> fetchProducts() async {
    // await 之前：模拟网络延迟；await 之后：数据到达
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const [
      Product(id: 1, name: '机械键盘', price: 399),
      Product(id: 2, name: '鼠标垫', price: 29),
      Product(id: 3, name: '显示器', price: 1299),
    ];
  }
}

// ==================== presentation 层（Flutter UI，只依赖 domain） ====================

/// 页面：只负责展示与用户交互，业务规则全部委托给用例。
class CleanArchitectureExample extends StatefulWidget {
  const CleanArchitectureExample({super.key});

  @override
  State<CleanArchitectureExample> createState() =>
      _CleanArchitectureExampleState();
}

class _CleanArchitectureExampleState extends State<CleanArchitectureExample> {
  // 组装依赖链：data 实现 → 注入用例 → 页面持有用例
  final GetProductsUseCase _getProducts = GetProductsUseCase(
    FakeProductRepository(),
  );

  List<Product>? _products; // null=未加载
  bool _loading = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    // 页面不知道数据来自哪里、怎么排序 —— 这正是解耦的价值
    final products = await _getProducts();
    if (!mounted) return; // await 后页面可能已被关闭，先检查再 setState
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = _products;
    return Scaffold(
      appBar: AppBar(title: const Text('01 整洁架构')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _loading ? null : _load,
              child: Text(_loading ? '加载中…' : '通过用例加载商品'),
            ),
          ),
          Expanded(
            child: products == null
                ? const Center(child: Text('尚未加载'))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, i) {
                      final p = products[i];
                      return ListTile(
                        title: Text(p.name),
                        trailing: Text('¥${p.price.toStringAsFixed(0)}'),
                      );
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '观察点：\n'
              '• 商品按价格排序是用例做的，不是 UI 做的；\n'
              '• 想换数据源（真实 API / 本地缓存）只需替换 FakeProductRepository，'
              'domain 与 UI 一行不用改。',
            ),
          ),
        ],
      ),
    );
  }
}
