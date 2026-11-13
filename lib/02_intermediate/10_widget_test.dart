// ============================================================
// 文件：10_widget_test.dart
// 阶段：中级
// 主题：可测试的 Widget 长什么样（Widget 测试的被测对象）
// 学习目标：
//   1. 认识 Key 在测试定位中的作用
//   2. 理解“可测试性”如何影响 Widget 的写法
//   3. 配合 10_widget_test_test.dart 学习 testWidgets 流程
// 运行方式：flutter run 后，在首页选择“10 Widget 测试入门”
//          配套测试：flutter test 运行 test/widget/counter_widget_test.dart
// 预计阅读时间：12 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 被测页面：一个带加减按钮的计数器。
/// 关键实践：给测试中需要定位的 Widget 显式分配 Key，
/// 比在测试里按文案/类型查找更稳定（文案一改测试就挂）。
class CounterDemoPage extends StatefulWidget {
  const CounterDemoPage({super.key});

  @override
  State<CounterDemoPage> createState() => _CounterDemoPageState();
}

class _CounterDemoPageState extends State<CounterDemoPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('10 Widget 测试入门')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 测试里用 find.byKey(Key('count-text')) 精确定位
            Text(
              '$_count',
              key: const Key('count-text'),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  key: const Key('increment-btn'),
                  onPressed: () => setState(() => _count++),
                  child: const Text('+1'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  key: const Key('decrement-btn'),
                  onPressed: () => setState(() => _count--),
                  child: const Text('-1'),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              '本页面是 Widget 测试的被测对象。\n\n'
              '打开 lib/02_intermediate/10_widget_test_test.dart 看测试写法：\n'
              '• pumpWidget：把 Widget 装进测试环境\n'
              '• find.byKey / find.text：查找器定位节点\n'
              '• tester.tap + pump：模拟点击并触发重建\n'
              '• expect(..., findsOneWidget)：断言结果',
            ),
          ],
        ),
      ),
    );
  }
}
