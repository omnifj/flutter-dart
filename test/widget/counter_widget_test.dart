// ============================================================
// 文件：test/widget/counter_widget_test.dart
// 说明：Widget 测试 —— 在测试环境中构建界面、模拟点击、断言结果。
// 被测对象：lib/02_intermediate/10_widget_test.dart 的 CounterDemoPage。
// 配套讲解：lib/02_intermediate/10_widget_test_test.dart
// 运行：flutter test test/widget/counter_widget_test.dart
// ============================================================
import 'package:flutter_dart/02_intermediate/10_widget_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('初始显示 0，点击 +1 后显示 1', (tester) async {
    // pumpWidget：把被测页面装进测试环境（需要 MaterialApp 提供主题等环境）
    await tester.pumpWidget(const MaterialApp(home: CounterDemoPage()));

    // 初始断言：findsOneWidget 表示恰好找到一个
    expect(find.text('0'), findsOneWidget);

    // tap 模拟点击；pump 触发一帧重建（setState 的效果在下一帧才可见）
    await tester.tap(find.byKey(const Key('increment-btn')));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNothing); // 旧文本应已消失
  });

  testWidgets('点击 -1 后显示 -1', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterDemoPage()));
    await tester.tap(find.byKey(const Key('decrement-btn')));
    await tester.pump();
    // ⚠️ 注意：不能用 find.text('-1')，因为按钮文案也是 '-1'，会匹配到两个；
    // 精确做法是按 Key 找到计数文本再断言它的内容。
    final counterText = tester.widget<Text>(
      find.byKey(const Key('count-text')),
    );
    expect(counterText.data, '-1');
  });

  testWidgets('连续点击 +1 三次显示 3', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterDemoPage()));
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('increment-btn')));
    }
    await tester.pump(); // 多次 tap 后统一 pump 一次即可
    expect(find.text('3'), findsOneWidget);
  });
}
