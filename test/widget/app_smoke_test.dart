// ============================================================
// 文件：test/widget/app_smoke_test.dart
// 说明：全量冒烟测试 —— 遍历首页导航清单中的全部 30 个示例，
//      逐一构建并推进若干帧，断言没有任何未捕获异常（即无红屏）。
// 运行：flutter test test/widget/app_smoke_test.dart
// ============================================================
import 'package:flutter_dart/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('首页展示全部 30 个示例入口', (tester) async {
    await tester.pumpWidget(const LearningApp());
    await tester.pump();
    // AppBar 标题符合规格
    expect(find.text('Flutter 学习示例'), findsOneWidget);
    // 首屏可见「初级」分组头与首个示例条目（中级/高级需滚动才构建，
    // 这是 ListView 惰性构建的正常行为，不能断言它们已在树上）
    expect(find.textContaining('初级'), findsWidgets);
    expect(find.text('Hello World 与热重载'), findsOneWidget);
    // 导航清单确实包含 30 个示例（三个阶段的完整数据）
    expect(appExamples.length, 30);
    expect(appExamples.map((e) => e.stage).toSet(), {'初级', '中级', '高级'});
  });

  // 为每个示例生成一个独立用例：构建 + 推进帧 + 断言无异常
  for (final entry in appExamples) {
    testWidgets('示例可正常加载：[${entry.stage}] ${entry.index} ${entry.title}', (
      tester,
    ) async {
      // 每个示例都被包在独立 MaterialApp 里构建，模拟真实导航进入
      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: entry.builder)),
      );
      await tester.pump(); // 首帧
      // 推进 2 秒：让 initState 里的延迟加载（如模拟 IO）完成
      await tester.pump(const Duration(seconds: 2));
      // takeException 返回构建期间捕获的唯一异常；为 null 即无红屏
      expect(tester.takeException(), isNull);
    });
  }
}
