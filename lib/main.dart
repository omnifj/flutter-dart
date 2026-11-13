// ============================================================
// 文件：main.dart
// 阶段：全局入口
// 主题：统一导航壳 —— 抽屉/列表加载全部 30 个学习示例
// 学习目标：
//   1. 理解 MaterialApp / Scaffold / Drawer / ListView 的组合方式
//   2. 学会用数据驱动的方式维护导航列表（增删示例只改一处）
//   3. 认识 Navigator.push 的基本页面跳转
// 运行方式：flutter run 后直接看到首页，点击条目进入对应示例
// 预计阅读时间：10 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

// ---------- 初级示例 ----------
import '01_basics/01_hello_world.dart';
import '01_basics/02_dart_basics.dart';
import '01_basics/03_null_safety.dart';
import '01_basics/04_stateless_widget.dart';
import '01_basics/05_stateful_widget.dart';
import '01_basics/06_layout_row_column.dart';
import '01_basics/07_container_stack.dart';
import '01_basics/08_listview_gridview.dart';
import '01_basics/09_textfield_input.dart';
import '01_basics/10_navigation.dart';

// ---------- 中级示例 ----------
import '02_intermediate/01_change_notifier.dart';
import '02_intermediate/02_provider.dart';
import '02_intermediate/03_implicit_animations.dart';
import '02_intermediate/04_explicit_animations.dart';
import '02_intermediate/05_go_router.dart';
import '02_intermediate/06_http_requests.dart';
import '02_intermediate/07_json_serialization.dart';
import '02_intermediate/08_forms_validation.dart';
import '02_intermediate/09_theme_responsive.dart';
import '02_intermediate/10_widget_test.dart';

// ---------- 高级示例 ----------
import '03_advanced/01_clean_architecture.dart';
import '03_advanced/02_repository_pattern.dart';
import '03_advanced/03_dependency_injection.dart';
import '03_advanced/04_isolate.dart';
import '03_advanced/05_platform_channel.dart';
import '03_advanced/06_custom_paint.dart';
import '03_advanced/07_slivers_advanced.dart';
import '03_advanced/08_performance_optimization.dart';
import '03_advanced/09_design_patterns.dart';
import '03_advanced/10_real_world_app.dart';

/// 每个示例的元数据：序号、标题、所属阶段，以及如何构建它的 Widget。
/// 用数据驱动导航的好处：新增示例时只需在 [_examples] 里加一行。
class ExampleEntry {
  const ExampleEntry({
    required this.index,
    required this.title,
    required this.stage,
    required this.builder,
  });

  final String index; // 文件序号，如 "01"、"10"
  final String title; // 展示标题
  final String stage; // 阶段：初级 / 中级 / 高级
  final WidgetBuilder builder; // 延迟构建：进入页面时才创建 Widget
}

/// 全部示例清单。顺序即首页展示顺序，也是建议学习顺序。
/// 公开（非私有）是为了让冒烟测试可以遍历每个示例验证其能正常构建。
final List<ExampleEntry> appExamples = [
  // ----- 初级：Dart 与 Widget 基础 -----
  ExampleEntry(
    index: '01',
    title: 'Hello World 与热重载',
    stage: '初级',
    builder: (_) => const HelloWorldExample(),
  ),
  ExampleEntry(
    index: '02',
    title: 'Dart 语言基础',
    stage: '初级',
    builder: (_) => const DartBasicsExample(),
  ),
  ExampleEntry(
    index: '03',
    title: '空安全',
    stage: '初级',
    builder: (_) => const NullSafetyExample(),
  ),
  ExampleEntry(
    index: '04',
    title: 'StatelessWidget',
    stage: '初级',
    builder: (_) => const StatelessWidgetExample(),
  ),
  ExampleEntry(
    index: '05',
    title: 'StatefulWidget 与 setState',
    stage: '初级',
    builder: (_) => const StatefulWidgetExample(),
  ),
  ExampleEntry(
    index: '06',
    title: 'Row / Column 线性布局',
    stage: '初级',
    builder: (_) => const LayoutRowColumnExample(),
  ),
  ExampleEntry(
    index: '07',
    title: 'Container 与 Stack',
    stage: '初级',
    builder: (_) => const ContainerStackExample(),
  ),
  ExampleEntry(
    index: '08',
    title: 'ListView 与 GridView',
    stage: '初级',
    builder: (_) => const ListViewGridViewExample(),
  ),
  ExampleEntry(
    index: '09',
    title: 'TextField 输入',
    stage: '初级',
    builder: (_) => const TextFieldInputExample(),
  ),
  ExampleEntry(
    index: '10',
    title: '页面导航 Navigator',
    stage: '初级',
    builder: (_) => const NavigationExample(),
  ),
  // ----- 中级：状态管理、动画、路由、网络 -----
  ExampleEntry(
    index: '01',
    title: 'ChangeNotifier 状态管理',
    stage: '中级',
    builder: (_) => const ChangeNotifierExample(),
  ),
  ExampleEntry(
    index: '02',
    title: 'Provider 跨组件共享状态',
    stage: '中级',
    builder: (_) => const ProviderExample(),
  ),
  ExampleEntry(
    index: '03',
    title: '隐式动画',
    stage: '中级',
    builder: (_) => const ImplicitAnimationsExample(),
  ),
  ExampleEntry(
    index: '04',
    title: '显式动画 AnimationController',
    stage: '中级',
    builder: (_) => const ExplicitAnimationsExample(),
  ),
  ExampleEntry(
    index: '05',
    title: 'GoRouter 声明式路由',
    stage: '中级',
    builder: (_) => const GoRouterExample(),
  ),
  ExampleEntry(
    index: '06',
    title: '网络请求 HttpClient',
    stage: '中级',
    builder: (_) => const HttpRequestsExample(),
  ),
  ExampleEntry(
    index: '07',
    title: 'JSON 序列化',
    stage: '中级',
    builder: (_) => const JsonSerializationExample(),
  ),
  ExampleEntry(
    index: '08',
    title: '表单与校验',
    stage: '中级',
    builder: (_) => const FormsValidationExample(),
  ),
  ExampleEntry(
    index: '09',
    title: '主题与响应式布局',
    stage: '中级',
    builder: (_) => const ThemeResponsiveExample(),
  ),
  ExampleEntry(
    index: '10',
    title: 'Widget 测试入门',
    stage: '中级',
    builder: (_) => const CounterDemoPage(),
  ),
  // ----- 高级：架构、并发、平台通道、性能 -----
  ExampleEntry(
    index: '01',
    title: '整洁架构分层',
    stage: '高级',
    builder: (_) => const CleanArchitectureExample(),
  ),
  ExampleEntry(
    index: '02',
    title: 'Repository 模式',
    stage: '高级',
    builder: (_) => const RepositoryPatternExample(),
  ),
  ExampleEntry(
    index: '03',
    title: '依赖注入',
    stage: '高级',
    builder: (_) => const DependencyInjectionExample(),
  ),
  ExampleEntry(
    index: '04',
    title: 'Isolate 并发计算',
    stage: '高级',
    builder: (_) => const IsolateExample(),
  ),
  ExampleEntry(
    index: '05',
    title: 'Platform Channel 平台通道',
    stage: '高级',
    builder: (_) => const PlatformChannelExample(),
  ),
  ExampleEntry(
    index: '06',
    title: 'CustomPaint 自定义绘制',
    stage: '高级',
    builder: (_) => const CustomPaintExample(),
  ),
  ExampleEntry(
    index: '07',
    title: 'Slivers 高级滚动',
    stage: '高级',
    builder: (_) => const SliversAdvancedExample(),
  ),
  ExampleEntry(
    index: '08',
    title: '性能优化实践',
    stage: '高级',
    builder: (_) => const PerformanceOptimizationExample(),
  ),
  ExampleEntry(
    index: '09',
    title: '常用设计模式',
    stage: '高级',
    builder: (_) => const DesignPatternsExample(),
  ),
  ExampleEntry(
    index: '10',
    title: '综合实战：待办清单',
    stage: '高级',
    builder: (_) => const RealWorldAppExample(),
  ),
];

void main() {
  // runApp 是 Flutter 应用的入口：把根 Widget 挂到屏幕上
  runApp(const LearningApp());
}

/// 根 Widget：只负责主题和首页路由，不持有业务状态。
class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 学习示例',
      // Material 3 在 Flutter 3.x 默认启用；这里只定制种子色生成整套配色
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple),
      // 初始路由：首页
      home: const HomePage(),
    );
  }
}

/// 首页：AppBar + 抽屉 + 分组的示例列表。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// 把扁平的示例列表按阶段分组，保持 appExamples 里的先后顺序。
  Map<String, List<ExampleEntry>> _groupByStage() {
    final grouped = <String, List<ExampleEntry>>{};
    for (final entry in appExamples) {
      // putIfAbsent：阶段第一次出现时创建空列表，之后直接追加
      grouped.putIfAbsent(entry.stage, () => []).add(entry);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByStage();
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 学习示例')),
      // 抽屉：与列表等价的另一种导航入口，方便随时切换示例
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(child: Text('Flutter 学习示例\n选择任意示例开始学习')),
              for (final stage in grouped.keys) ...[
                // 阶段标题（抽屉内）
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    stage,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final entry in grouped[stage]!)
                  ListTile(
                    dense: true,
                    title: Text('${entry.index} ${entry.title}'),
                    onTap: () => _openExample(context, entry),
                  ),
              ],
            ],
          ),
        ),
      ),
      // 首页主体：按阶段分组的列表
      body: ListView(
        children: [
          for (final stage in grouped.keys) ...[
            // 分组头：显示阶段名称与示例数量
            ListTile(
              title: Text('$stage（${grouped[stage]!.length} 个示例）'),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            for (final entry in grouped[stage]!)
              ListTile(
                leading: CircleAvatar(child: Text(entry.index)),
                title: Text(entry.title),
                subtitle: Text(entry.stage),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openExample(context, entry),
              ),
          ],
        ],
      ),
    );
  }

  /// 跳转到示例页；先关闭抽屉（抽屉本质是导航器的本地历史项，
  /// popUntil 到首个路由即可顺手关掉它），再 push 示例页。
  void _openExample(BuildContext context, ExampleEntry entry) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: entry.builder));
  }
}
