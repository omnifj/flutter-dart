// ============================================================
// 文件：04_isolate.dart
// 阶段：高级
// 主题：Isolate 并发计算（Isolate.run）
// 学习目标：
//   1. 理解 Dart 单线程事件循环与 UI 卡顿的关系
//   2. 掌握 Isolate.run 把 CPU 密集任务移出主线程
//   3. 理解 Isolate 内存隔离：只能传值，不能共享对象/操作 UI
// 运行方式：flutter run 后，在首页选择“04 Isolate 并发计算”
// 预计阅读时间：18 分钟
// ============================================================
import 'dart:isolate';

import 'package:material_ui/material_ui.dart';

/// 计算第 n 个斐波那契数（故意用指数级慢算法模拟 CPU 密集任务）。
/// 顶层函数：Isolate 入口必须是顶层函数或静态方法，不能是闭包/实例方法，
/// 因为 Isolate 之间不共享内存，捕获不了外部变量。
int _fib(int n) {
  if (n < 2) return n;
  return _fib(n - 1) + _fib(n - 2);
}

/// 页面：对比“主线程计算（卡 UI）”与“Isolate 计算（UI 流畅）”。
class IsolateExample extends StatefulWidget {
  const IsolateExample({super.key});

  @override
  State<IsolateExample> createState() => _IsolateExampleState();
}

class _IsolateExampleState extends State<IsolateExample> {
  static const int _n = 38; // fib(38) 约需数秒，卡顿效果肉眼可见

  double _sliderValue = 0; // 用来“感知”UI 是否卡住的滑块
  String _result = '尚未计算';
  bool _computing = false;

  /// 方式 A：直接在主线程算 —— 事件循环被占满，UI 完全冻结。
  void _computeOnMain() {
    setState(() {
      _computing = true;
      _result = '主线程计算中…（试试拖动滑块，卡死了）';
    });
    final value = _fib(_n); // 同步阻塞：这期间任何点击、动画都不会响应
    setState(() {
      _computing = false;
      _result = '主线程计算结果：fib($_n) = $value';
    });
  }

  /// 方式 B：Isolate.run —— 在独立 Worker 线程里算，主线程照常渲染。
  Future<void> _computeInIsolate() async {
    setState(() {
      _computing = true;
      _result = 'Isolate 计算中…（滑块依然丝滑）';
    });
    // await 之前：任务被打包发给 Worker Isolate，主线程继续空闲；
    // await 之后：Worker 算完，结果通过消息传回主线程。
    final value = await Isolate.run(() => _fib(_n));
    if (!mounted) return;
    // ⚠️ 注意：只能在主 Isolate 操作 UI / setState；
    // Isolate.run 的回调里绝不能碰 Widget，因为它跑在另一个内存空间。
    setState(() {
      _computing = false;
      _result = 'Isolate 计算结果：fib($_n) = $value';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('04 Isolate 并发')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('先拖一拖滑块感受一下流畅度，再点下方按钮：'),
            Slider(
              value: _sliderValue,
              onChanged: (v) => setState(() => _sliderValue = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _computing ? null : _computeOnMain,
              child: const Text('主线程计算 fib(38)（UI 卡死）'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: _computing ? null : _computeInIsolate,
              child: const Text('Isolate 计算 fib(38)（UI 流畅）'),
            ),
            const SizedBox(height: 24),
            Text(_result),
            const SizedBox(height: 12),
            const Text(
              '要点：\n'
              '• Dart 主线程是事件循环：耗时同步任务会阻塞所有 UI；\n'
              '• Isolate 不共享内存，数据靠“值拷贝/消息”传递；\n'
              '• JSON 解析大文件、图片处理、复杂计算都适合放进 Isolate。',
            ),
          ],
        ),
      ),
    );
  }
}
