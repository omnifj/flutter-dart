// ============================================================
// 文件：09_design_patterns.dart
// 阶段：高级
// 主题：常用设计模式在 Dart/Flutter 中的应用
// 学习目标：
//   1. 掌握工厂构造、单例、Builder 模式的 Dart 写法
//   2. 理解装饰器模式如何天然对应 Widget 组合
//   3. 回顾观察者模式（ChangeNotifier 就是它的实现）
// 运行方式：flutter run 后，在首页选择“09 常用设计模式”
// 预计阅读时间：20 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

// ---------------- 1. 工厂模式：根据输入决定返回哪个实现 ----------------

abstract class Shape {
  double area();
  String get name;
}

class Circle implements Shape {
  Circle(this.radius);

  final double radius;

  @override
  double area() => 3.14159 * radius * radius;

  @override
  String get name => '圆形';
}

class Square implements Shape {
  Square(this.side);

  final double side;

  @override
  double area() => side * side;

  @override
  String get name => '正方形';
}

/// 工厂：调用方只说“我要什么”，不关心怎么构造。
class ShapeFactory {
  static Shape create(String type, double size) {
    return switch (type) {
      'circle' => Circle(size),
      'square' => Square(size),
      _ => throw ArgumentError('未知形状：$type'), // 兜底比返回 null 更安全
    };
  }
}

// ---------------- 2. 单例：全局唯一实例 ----------------

class AppConfig {
  AppConfig._(); // 私有构造，外部无法 new

  static final AppConfig instance = AppConfig._();

  String themeName = '默认主题';

  // ⚠️ 注意：单例方便但本质是全局状态，滥用会让依赖关系混乱、测试困难；
  // 只放真正全局唯一的配置/服务。
}

// ---------------- 3. Builder 模式：链式组装复杂对象 ----------------

class Pizza {
  const Pizza({
    required this.size,
    required this.cheese,
    required this.toppings,
  });

  final String size;
  final bool cheese;
  final List<String> toppings;

  @override
  String toString() =>
      '$size 披萨（${cheese ? "加芝士" : "无芝士"}，配料：${toppings.join("、")}）';
}

class PizzaBuilder {
  String _size = '中号';
  bool _cheese = true;
  final List<String> _toppings = [];

  PizzaBuilder size(String value) {
    _size = value;
    return this; // 返回 this 才能链式调用
  }

  PizzaBuilder cheese(bool value) {
    _cheese = value;
    return this;
  }

  PizzaBuilder addTopping(String t) {
    _toppings.add(t);
    return this;
  }

  Pizza build() => Pizza(
    size: _size,
    cheese: _cheese,
    toppings: List.unmodifiable(_toppings),
  );
}

/// 页面：按钮逐个触发四种模式的演示，结果显示在界面上。
class DesignPatternsExample extends StatefulWidget {
  const DesignPatternsExample({super.key});

  @override
  State<DesignPatternsExample> createState() => _DesignPatternsExampleState();
}

class _DesignPatternsExampleState extends State<DesignPatternsExample> {
  final List<String> _output = [];
  int _observerCount = 0;

  void _show(String text) => setState(() => _output.insert(0, text));

  void _demoFactory() {
    final shape = ShapeFactory.create('circle', 2);
    _show('工厂模式：${shape.name} 面积=${shape.area().toStringAsFixed(2)}');
  }

  void _demoSingleton() {
    AppConfig.instance.themeName = '深色主题';
    _show('单例：AppConfig.instance.themeName = ${AppConfig.instance.themeName}');
  }

  void _demoBuilder() {
    final pizza = PizzaBuilder()
        .size('大号')
        .addTopping('蘑菇')
        .addTopping('培根')
        .build();
    _show('Builder：$pizza');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('09 设计模式')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: _demoFactory,
                child: const Text('工厂'),
              ),
              FilledButton.tonal(
                onPressed: _demoSingleton,
                child: const Text('单例'),
              ),
              FilledButton.tonal(
                onPressed: _demoBuilder,
                child: const Text('Builder'),
              ),
              FilledButton.tonal(
                // 观察者模式回顾：点击 → 状态变更 → 监听者重建
                onPressed: () => setState(() => _observerCount++),
                child: const Text('观察者（setState 版本）'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ---- 装饰器模式演示：Widget 组合就是装饰器 ----
          // 每层 Widget“装饰”内层：加边距 → 加卡片 → 加圆角裁剪 → 加背景色
          const Padding(
            // 装饰第 1 层：外边距
            padding: EdgeInsets.all(8),
            child: Card(
              // 装饰第 2 层：阴影卡片
              child: ClipRRect(
                // 装饰第 3 层：圆角裁剪
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: ColoredBox(
                  // 装饰第 4 层：背景色
                  color: Colors.lightGreen,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('装饰器模式：四层 Widget 逐层包装出最终效果'),
                  ),
                ),
              ),
            ),
          ),
          Text('观察者演示：点击了 $_observerCount 次（本文字由 setState 驱动刷新）'),
          const Divider(height: 32),
          const Text('输出日志：'),
          for (final line in _output) Text('• $line'),
        ],
      ),
    );
  }
}
