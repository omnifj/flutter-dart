// ============================================================
// 文件：02_provider.dart
// 阶段：中级
// 主题：Provider 跨组件共享状态（read / watch / select）
// 学习目标：
//   1. 掌握 ChangeNotifierProvider 把状态注入 Widget 树
//   2. 区分 context.read（取引用，不监听）与 context.watch（监听重建）
//   3. 用 context.select 只订阅需要的字段，减少重建
// 运行方式：flutter run 后，在首页选择“02 Provider 跨组件共享状态”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart'; // 本文件是允许使用第三方包的示例之一

/// 计数 + 步长：演示多个字段时 select 的精准订阅价值。
class CounterModel extends ChangeNotifier {
  int _count = 0;
  int _step = 1;

  int get count => _count;
  int get step => _step;

  void increment() {
    _count += _step;
    // 状态变化必须 notifyListeners，Provider 才知道要通知哪些监听者
    notifyListeners();
  }

  void changeStep(int newStep) {
    _step = newStep;
    notifyListeners();
  }
}

/// 页面壳：在页面根部提供状态，整棵子树都能访问。
class ProviderExample extends StatelessWidget {
  const ProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider 负责创建 CounterModel 并在页面销毁时自动 dispose，
    // 这就是为什么 Provider 比手动管理更省心。
    return ChangeNotifierProvider(
      create: (_) => CounterModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('02 Provider')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _CountDisplay(), // 只显示 count
              const SizedBox(height: 16),
              const _StepPicker(), // 只关心 step
              const SizedBox(height: 16),
              // ---- 按钮区：只调用方法，不需要监听，所以用 read ----
              // context.read 在事件回调里取引用是安全的；
              // ⚠️ 注意：不要在 build 里用 read 代替 watch，那样数据变了界面不刷新。
              Builder(
                builder: (context) => FilledButton(
                  onPressed: () => context.read<CounterModel>().increment(),
                  child: const Text('按步长增加'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '观察：改步长时只有步长区重建；点按钮时只有计数区重建。\n'
                '这就是 select 精准订阅的意义（打开控制台看重建日志）。',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 计数显示：用 select 只订阅 count 字段。
class _CountDisplay extends StatelessWidget {
  const _CountDisplay();

  @override
  Widget build(BuildContext context) {
    // select：只在 count 变化时重建本 Widget，step 变化与它无关
    final count = context.select<CounterModel, int>((m) => m.count);
    debugPrint('_CountDisplay 重建'); // 打开控制台可验证重建范围
    return Text('$count', style: Theme.of(context).textTheme.displayLarge);
  }
}

/// 步长选择：用 watch 订阅整个模型（这里字段少，watch 也够用）。
class _StepPicker extends StatelessWidget {
  const _StepPicker();

  @override
  Widget build(BuildContext context) {
    // watch：模型任何字段变化都会重建本 Widget
    final model = context.watch<CounterModel>();
    debugPrint('_StepPicker 重建');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('步长：'),
        for (final s in [1, 5, 10])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text('$s'),
              selected: model.step == s,
              onSelected: (_) => model.changeStep(s),
            ),
          ),
      ],
    );
  }
}
