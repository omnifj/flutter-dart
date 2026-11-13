// ============================================================
// 文件：10_widget_test_test.dart
// 阶段：中级
// 主题：Widget 测试写法精讲（testWidgets / WidgetTester / find）
// 学习目标：
//   1. 掌握 testWidgets 与 WidgetTester 的基本流程
//   2. 掌握 find 系列查找器与 findsOneWidget 等断言
//   3. 理解 pump / pumpAndSettle 的区别
// 运行方式：本文件是“测试代码的阅读示例”，内容拷贝自
//          test/widget/counter_widget_test.dart（实际由 flutter test 运行）
// 预计阅读时间：15 分钟
// ============================================================
//
// ⚠️ 注意：按 Flutter 约定，flutter test 只会自动执行 test/ 目录下的
//    *_test.dart 文件；本文件放在 lib/ 是为了和示例页面放在一起方便对照阅读，
//    内容与 test/widget/counter_widget_test.dart 保持一致。
//
// ---------------- 测试代码精讲（逐行注释版） ----------------
//
// import 'package:flutter_test/flutter_test.dart';       // 测试框架（随 SDK 分发）
// import 'package:material_ui/material_ui.dart';         // MaterialApp 等组件
// import '10_widget_test.dart';                          // 被测页面
//
// void main() {
//   // testWidgets：声明一个 Widget 测试用例，回调拿到 WidgetTester
//   testWidgets('计数器点击 +1 后显示 1', (tester) async {
//     // 1) pumpWidget：把被测 Widget 挂进测试环境并触发首帧构建
//     await tester.pumpWidget(const MaterialApp(home: CounterDemoPage()));
//
//     // 2) find 查找器定位节点：
//     //    find.byKey     —— 最稳定，推荐
//     //    find.text      —— 按文案查找，文案改了测试就挂
//     //    find.byType    —— 按 Widget 类型查找
//     expect(find.text('0'), findsOneWidget);            // 初始值断言
//
//     // 3) tester.tap 模拟点击；pump() 触发一次重建（相当于走一帧）
//     await tester.tap(find.byKey(const Key('increment-btn')));
//     await tester.pump();
//
//     // 4) 断言新状态
//     expect(find.text('1'), findsOneWidget);
//     expect(find.text('0'), findsNothing);              // 旧值应消失
//   });
//
//   testWidgets('点击 -1 后显示 -1', (tester) async {
//     await tester.pumpWidget(const MaterialApp(home: CounterDemoPage()));
//     await tester.tap(find.byKey(const Key('decrement-btn')));
//     await tester.pump();
//     expect(find.text('-1'), findsOneWidget);
//   });
//
//   // 常用补充 API：
//   // tester.enterText(finder, '文本')  —— 模拟输入
//   // tester.pumpAndSettle()           —— 一直 pump 直到动画/定时器全部结束
//   // find.descendant(of:, matching:)  —— 限定子树范围查找
// }
//
// ---------------- 为什么是注释？ ----------------
// 该文件位于 lib/ 下，若直接包含测试代码会随应用一起打包；
// 真正可执行的版本在 test/widget/counter_widget_test.dart。
// ============================================================
