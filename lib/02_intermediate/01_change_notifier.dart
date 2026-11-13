// ============================================================
// 文件：01_change_notifier.dart
// 阶段：中级
// 主题：ChangeNotifier + ListenableBuilder 手动状态管理
// 学习目标：
//   1. 理解「数据与 UI 分离」：状态放在普通类里，而非 State 里
//   2. 掌握 ChangeNotifier.notifyListeners 的广播机制
//   3. 掌握用 ListenableBuilder 精确订阅局部刷新
// 运行方式：flutter run 后，在首页选择“01 ChangeNotifier 状态管理”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 购物车状态：不依赖 Flutter UI，是纯 Dart 类，天然可单元测试。
class CartModel extends ChangeNotifier {
  final List<String> _items = [];

  // 暴露只读视图：外部不能绕过 notifyListeners 直接改数据
  List<String> get items => List.unmodifiable(_items);
  int get totalCount => _items.length;

  void add(String item) {
    _items.add(item);
    // 为什么需要 notifyListeners：数据变了，必须主动广播，
    // 所有正在监听的 ListenableBuilder 才会重建对应 UI。
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// 页面：内部创建 CartModel 并用 ListenableBuilder 订阅它。
class ChangeNotifierExample extends StatefulWidget {
  const ChangeNotifierExample({super.key});

  @override
  State<ChangeNotifierExample> createState() => _ChangeNotifierExampleState();
}

class _ChangeNotifierExampleState extends State<ChangeNotifierExample> {
  // ChangeNotifier 持有监听器列表，是有资源的对象，必须在 dispose 中释放
  final CartModel _cart = CartModel();
  int _nextId = 1;

  @override
  void dispose() {
    _cart.dispose(); // ⚠️ 注意：忘记 dispose 会泄漏监听器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('01 ChangeNotifier')),
      body: Column(
        children: [
          // ---- 徽标：只订阅数量这一小块 UI ----
          // ListenableBuilder 只重建它的 builder 子树，页面其余部分不动。
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
              listenable: _cart,
              builder: (context, _) => Badge(
                label: Text('${_cart.totalCount}'),
                child: const Icon(Icons.shopping_cart, size: 48),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () => _cart.add('商品 ${_nextId++}'),
                child: const Text('加入购物车'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _cart.clear, child: const Text('清空')),
            ],
          ),
          const Divider(),
          // ---- 列表：另一处订阅同一状态，数据变化两处同时刷新 ----
          Expanded(
            child: ListenableBuilder(
              listenable: _cart,
              builder: (context, _) => _cart.items.isEmpty
                  ? const Center(child: Text('购物车是空的'))
                  : ListView.builder(
                      itemCount: _cart.items.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(_cart.items[i]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _cart.removeAt(i),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
