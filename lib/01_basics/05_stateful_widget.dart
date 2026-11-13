// ============================================================
// 文件：05_stateful_widget.dart
// 阶段：初级
// 主题：StatefulWidget 与 setState
// 学习目标：
//   1. 理解 StatelessWidget 与 StatefulWidget 的区别
//   2. 掌握 setState 触发重建的机制
//   3. 认识 State 生命周期（initState / dispose）
// 运行方式：flutter run 后，在首页选择“05 StatefulWidget 与 setState”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 经典计数器：点击按钮让数字增长，同时演示生命周期日志。
class StatefulWidgetExample extends StatefulWidget {
  const StatefulWidgetExample({super.key});

  @override
  State<StatefulWidgetExample> createState() => _StatefulWidgetExampleState();
}

class _StatefulWidgetExampleState extends State<StatefulWidgetExample> {
  int _count = 0; // 可变状态放在 State 里，而不是 Widget 里
  final List<String> _lifecycleLogs = []; // 记录生命周期回调时间线

  @override
  void initState() {
    super.initState();
    // initState：State 创建后调用一次，适合做初始化、订阅、开定时器
    _lifecycleLogs.add('initState：State 创建，只执行一次');
  }

  @override
  void dispose() {
    // dispose：页面被永久移除时调用，适合取消订阅、释放控制器
    // ⚠️ 注意：dispose 里不能再调用 setState（页面已不存在）
    debugPrint('dispose：计数器页面被销毁'); // 用日志而非 UI，因为 UI 正在拆除
    super.dispose();
  }

  void _increment() {
    // setState 的作用：通知框架“状态变了”，框架随后重新执行 build。
    // ⚠️ 注意：若在 setState 之外修改 _count，界面不会刷新！
    setState(() {
      _count++;
      _lifecycleLogs.add('setState #$_count：触发第 $_count 次重建');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('05 StatefulWidget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---- 计数值展示区 ----
            Text('$_count', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(onPressed: _increment, child: const Text('+1')),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => setState(() => _count = 0), // 重置也是一次状态变更
                  child: const Text('清零'),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('生命周期 / setState 日志：'),
            // ---- 日志列表：占满剩余高度 ----
            Expanded(
              child: ListView.builder(
                itemCount: _lifecycleLogs.length,
                itemBuilder: (context, i) => Text('• ${_lifecycleLogs[i]}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
