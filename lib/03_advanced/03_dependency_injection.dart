// ============================================================
// 文件：03_dependency_injection.dart
// 阶段：高级
// 主题：依赖注入 —— 手写 Service Locator 与构造函数注入
// 学习目标：
//   1. 理解「构造函数注入」是最简单、最推荐的注入方式
//   2. 掌握手写 Service Locator（get_it 的核心思路）
//   3. 理解 DI 对可测试性的价值（测试时替换实现）
// 运行方式：flutter run 后，在首页选择“03 依赖注入”
// 预计阅读时间：18 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 服务接口：日志器。
abstract class Logger {
  void log(String message);
}

/// 实现 A：生产环境用（假装写入文件，这里打印到控制台）。
class ConsoleLogger implements Logger {
  @override
  void log(String message) => debugPrint('[ConsoleLogger] $message');
}

/// 实现 B：演示/测试用 —— 记录到内存，方便界面展示与断言。
class MemoryLogger implements Logger {
  final List<String> entries = [];

  @override
  void log(String message) => entries.add(message);
}

// ---------------- 方式 1：手写 Service Locator ----------------

/// 极简 Service Locator：一个 Map 按类型存取单例。
/// get_it 包的核心思想就是这样，外加懒加载/工厂/作用域等增强。
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  final Map<Type, Object> _services = {};

  /// 注册单例；Type 作为 key 保证一种类型一份实例。
  void register<T extends Object>(T service) => _services[T] = service;

  /// 取实例；未注册时给出明确错误，而不是空指针。
  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('服务 $T 未注册，请先调用 register<$T>()');
    }
    return service as T;
  }

  void reset() => _services.clear();
}

/// 页面：对比两种注入方式。
class DependencyInjectionExample extends StatefulWidget {
  const DependencyInjectionExample({super.key});

  @override
  State<DependencyInjectionExample> createState() =>
      _DependencyInjectionExampleState();
}

class _DependencyInjectionExampleState
    extends State<DependencyInjectionExample> {
  // 方式 2：构造函数注入 —— 依赖从外部传入，类自己不 new 依赖。
  // 好处一目了然：测试时传 MemoryLogger，生产时传 ConsoleLogger。
  final MemoryLogger _injectedLogger = MemoryLogger();

  @override
  void initState() {
    super.initState();
    // initState：应用启动期的“组装层”，注册服务再使用
    ServiceLocator.instance.register<Logger>(MemoryLogger());
  }

  @override
  void dispose() {
    ServiceLocator.instance.reset(); // 页面销毁时清理，避免示例间互相污染
    super.dispose();
  }

  void _useLocator() {
    final logger = ServiceLocator.instance.get<Logger>();
    logger.log('${DateTime.now().millisecondsSinceEpoch} 来自 ServiceLocator');
    setState(() {}); // MemoryLogger 不是 Listenable，手动刷新展示
  }

  void _useConstructor() {
    _injectedLogger.log('${DateTime.now().millisecondsSinceEpoch} 来自构造函数注入');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ServiceLocator 取到的也是 MemoryLogger，两个列表都读出来展示
    final locatorLogger = ServiceLocator.instance.get<Logger>() as MemoryLogger;
    return Scaffold(
      appBar: AppBar(title: const Text('03 依赖注入')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: _useLocator,
              child: const Text('ServiceLocator 记一条日志'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: _useConstructor,
              child: const Text('构造函数注入记一条日志'),
            ),
            const Divider(height: 32),
            Text('Locator 日志（${locatorLogger.entries.length} 条）：'),
            for (final e in locatorLogger.entries) Text('• $e'),
            const SizedBox(height: 12),
            Text('构造注入日志（${_injectedLogger.entries.length} 条）：'),
            for (final e in _injectedLogger.entries) Text('• $e'),
            const SizedBox(height: 12),
            const Text(
              '⚠️ 注意：Service Locator 使用方便但隐藏了依赖关系'
              '（看构造函数看不出类需要什么）；构造函数注入依赖一目了然，'
              '优先考虑后者，Locator 适合全局基础服务。',
            ),
          ],
        ),
      ),
    );
  }
}
