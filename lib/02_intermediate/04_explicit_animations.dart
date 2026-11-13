// ============================================================
// 文件：04_explicit_animations.dart
// 阶段：中级
// 主题：显式动画（AnimationController + Tween + CurvedAnimation）
// 学习目标：
//   1. 掌握 AnimationController 的创建、vsync 与 dispose
//   2. 理解 Tween 与 CurvedAnimation 如何“包装”动画值
//   3. 掌握动画状态监听（completed / dismissed）与 repeat/reverse
// 运行方式：flutter run 后，在首页选择“04 显式动画”
// 预计阅读时间：18 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 显式动画演示：一颗可播放/暂停/往返的“呼吸球”。
class ExplicitAnimationsExample extends StatefulWidget {
  const ExplicitAnimationsExample({super.key});

  @override
  State<ExplicitAnimationsExample> createState() =>
      _ExplicitAnimationsExampleState();
}

// SingleTickerProviderStateMixin 提供 vsync：动画帧与屏幕刷新同步，避免掉帧。
// ⚠️ 注意：一个 State 同时有多个 Controller 时要用 TickerProviderStateMixin。
class _ExplicitAnimationsExampleState extends State<ExplicitAnimationsExample>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<Color?> _color;
  String _status = '尚未开始';

  @override
  void initState() {
    super.initState();
    // initState：创建控制器并注册监听 —— 一次性准备工作都在这里做
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this, // this 来自 mixin；没有它控制器不知道按什么节奏走
    );
    // CurvedAnimation：给线性进度套上缓动曲线
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    // Tween：把 0~1 的进度映射成目标值域（尺寸、颜色皆可）
    _scale = Tween<double>(begin: 0.5, end: 1.2).animate(curved);
    _color = ColorTween(begin: Colors.blue, end: Colors.orange).animate(curved);
    // 状态监听：动画完成/回退完成时更新文案
    _controller.addStatusListener((status) {
      setState(() => _status = status.name);
    });
  }

  @override
  void dispose() {
    // ⚠️ 注意：AnimationController 持有 Ticker，不 dispose 会持续占用帧回调
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('04 显式动画')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // AnimatedBuilder：动画值每帧变化时只重建 builder 子树。
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Transform.scale(
                    scale: _scale.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _color.value,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text('动画状态：$_status'),
            const SizedBox(height: 12),
            // ---- 控制按钮：forward / reverse / repeat / stop / reset ----
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  onPressed: _controller.forward,
                  child: const Text('播放'),
                ),
                FilledButton.tonal(
                  onPressed: _controller.reverse,
                  child: const Text('倒放'),
                ),
                OutlinedButton(
                  onPressed: () => _controller.repeat(reverse: true), // 往返循环
                  child: const Text('循环呼吸'),
                ),
                OutlinedButton(
                  onPressed: _controller.stop,
                  child: const Text('停止'),
                ),
                OutlinedButton(
                  onPressed: _controller.reset,
                  child: const Text('复位'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '要点：显式动画 = 你手动控制播放过程；\n'
              '隐式动画 = 你只改目标值，过程交给框架。',
            ),
          ],
        ),
      ),
    );
  }
}
