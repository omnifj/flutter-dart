// ============================================================
// 文件：03_implicit_animations.dart
// 阶段：中级
// 主题：隐式动画（AnimatedContainer / AnimatedOpacity / AnimatedSwitcher）
// 学习目标：
//   1. 理解隐式动画的触发条件：属性值变化即自动补间
//   2. 掌握 AnimatedContainer / AnimatedOpacity / AnimatedSwitcher 的用法
//   3. 学会用 Curve 调整动画节奏
// 运行方式：flutter run 后，在首页选择“03 隐式动画”
// 预计阅读时间：12 分钟
// ============================================================
import 'dart:math';

import 'package:material_ui/material_ui.dart';

/// 三个隐式动画同台演示：形状、透明度、内容切换。
class ImplicitAnimationsExample extends StatefulWidget {
  const ImplicitAnimationsExample({super.key});

  @override
  State<ImplicitAnimationsExample> createState() =>
      _ImplicitAnimationsExampleState();
}

class _ImplicitAnimationsExampleState extends State<ImplicitAnimationsExample> {
  final _random = Random();
  double _size = 100;
  double _radius = 8;
  Color _color = Colors.blue;
  bool _visible = true;
  int _page = 0;

  void _randomize() {
    // 隐式动画的触发条件很简单：setState 改变传给 AnimatedXxx 的属性值，
    // 框架自动在旧值与新值之间补间，无需手动管理 AnimationController。
    setState(() {
      _size = 60 + _random.nextDouble() * 120;
      _radius = _random.nextDouble() * 60;
      _color = Colors.primaries[_random.nextInt(Colors.primaries.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('03 隐式动画')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('1. AnimatedContainer：尺寸/圆角/颜色平滑过渡'),
          const SizedBox(height: 8),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut, // 曲线决定“加速-减速”的节奏感
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(_radius),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: FilledButton(
              onPressed: _randomize,
              child: const Text('随机变形'),
            ),
          ),
          const Divider(height: 32),
          const Text('2. AnimatedOpacity：淡入淡出'),
          SwitchListTile(
            title: const Text('显示内容'),
            value: _visible,
            onChanged: (v) => setState(() => _visible = v),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0, // opacity 变化即触发渐变
              duration: const Duration(milliseconds: 600),
              // ⚠️ 注意：透明度为 0 时子 Widget 仍在树上占位，只是不可见
              child: const Icon(Icons.flutter_dash, size: 80),
            ),
          ),
          const Divider(height: 32),
          const Text('3. AnimatedSwitcher：内容切换时交叉淡变'),
          const SizedBox(height: 8),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              // ⚠️ 注意：AnimatedSwitcher 靠 child 的 key 判断“是不是新内容”，
              //    不给 ValueKey 的话同类型 Widget 会被当成同一个，不播动画。
              child: Text(
                '第 $_page 页',
                key: ValueKey(_page),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: FilledButton.tonal(
              onPressed: () => setState(() => _page++),
              child: const Text('下一页'),
            ),
          ),
        ],
      ),
    );
  }
}
