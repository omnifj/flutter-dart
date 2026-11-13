// ============================================================
// 文件：01_hello_world.dart
// 阶段：初级
// 主题：第一个 Flutter 页面与热重载体验
// 学习目标：
//   1. 认识 runApp / MaterialApp / Scaffold 的组合关系
//   2. 理解 Text / Center 等基础 Widget 如何组成界面
//   3. 体验热重载：改代码后不用重启即可看到效果
// 运行方式：flutter run 后，在首页选择“01 Hello World 与热重载”
// 预计阅读时间：10 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 第一个示例页面：展示一行可以点按钮切换的文字。
///
/// ⚠️ 注意：真正的应用入口 `main() + runApp()` 在 lib/main.dart 里，
/// 这里只是一个被导航加载的普通页面，这样所有示例才能共用一个 App。
class HelloWorldExample extends StatefulWidget {
  const HelloWorldExample({super.key});

  @override
  State<HelloWorldExample> createState() => _HelloWorldExampleState();
}

class _HelloWorldExampleState extends State<HelloWorldExample> {
  // 用一个布尔值驱动界面变化，让“热重载不丢状态”可被观察到
  bool _excited = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold 提供 Material 页面的骨架：AppBar、body、浮动按钮等
      appBar: AppBar(title: const Text('01 Hello World')),
      // Center 把唯一子 Widget 放到屏幕正中央
      body: Center(
        // Column 垂直排列多个子 Widget
        child: Column(
          mainAxisSize: MainAxisSize.min, // 只包裹内容高度，而不是撑满全屏
          children: [
            // ---- 文字：热重载体验的主角 ----
            Text(
              _excited ? '你好，Flutter！🎉' : 'Hello, World!',
              style: TextStyle(
                fontSize: 28,
                // 状态变化时颜色跟着变，便于观察 UI 随数据更新
                color: _excited ? Colors.deepPurple : Colors.black87,
              ),
            ),
            const SizedBox(height: 24), // 固定间距，比 Padding 更轻量
            // ---- 按钮：点击翻转状态，触发 rebuild ----
            FilledButton(
              onPressed: () {
                // setState 告诉框架“数据变了，请重建 build”，界面随即刷新
                setState(() => _excited = !_excited);
              },
              child: const Text('点我切换文字'),
            ),
            const SizedBox(height: 16),
            const Text(
              '热重载体验：\n1. 保持 App 运行；\n2. 修改上面字符串的内容并保存；\n3. 界面立即更新，且按钮切换的状态不会丢失。',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
