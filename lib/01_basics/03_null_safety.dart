// ============================================================
// 文件：03_null_safety.dart
// 阶段：初级
// 主题：Dart 空安全（?、!、??、late）
// 学习目标：
//   1. 理解可空类型与非空类型的区别
//   2. 掌握 ?.、??、??=、!、late 的使用场景
//   3. 认识空安全如何影响 Widget 构建（如条件渲染）
// 运行方式：flutter run 后，在首页选择“03 空安全”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 通过“用户资料”场景演示空安全：昵称可空，点击按钮模拟“加载成功/加载失败”。
class NullSafetyExample extends StatefulWidget {
  const NullSafetyExample({super.key});

  @override
  State<NullSafetyExample> createState() => _NullSafetyExampleState();
}

class _NullSafetyExampleState extends State<NullSafetyExample> {
  // String? 表示“可以是 String，也可以是 null”；Dart 强制你处理 null 情况
  String? _nickname;

  // late：声明时先不赋值，但保证用之前一定赋值；适合 initState 里初始化的字段
  late final String _loadTime;

  @override
  void initState() {
    super.initState();
    // initState 在 Widget 插入树时调用一次，适合做一次性初始化。
    // ⚠️ 注意：initState 里不能调用依赖 context 的“可依赖”API
    // （如 Theme.of），因为祖先数据还没就绪；这里用纯 DateTime 格式化。
    final now = DateTime.now();
    _loadTime =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // ---- 空安全的四个常用运算符 ----
    // 1) ??：左边为 null 时取右边的默认值
    final displayName = _nickname ?? '（未设置昵称）';
    // 2) ?.：对象不为 null 才调用，否则整个表达式为 null（不会崩溃）
    final nameLength = _nickname?.length;
    // 3) !：断言“我保证这里不是 null”。⚠️ 注意：若实际为 null 会运行期崩溃，
    //    只在你能 100% 确定时使用；本例用 length 前已判空，仅作演示。
    final riskyLength = _nickname != null ? _nickname!.length : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('03 空安全')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('页面初始化于：$_loadTime（late 字段在 initState 赋值）'),
            const SizedBox(height: 12),
            // ---- 条件渲染：可空字段直接决定 Widget 树形态 ----
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(displayName),
                subtitle: Text(
                  '?.length => $nameLength；判空后 !.length => $riskyLength',
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => _nickname = '小明'),
              child: const Text('模拟加载成功（赋值昵称）'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => setState(() => _nickname = null),
              child: const Text('模拟加载失败（置为 null）'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () {
                // 4) ??=：变量为 null 时才赋值，常用于“懒初始化”
                _nickname ??= '默认值（只在为 null 时生效）';
                setState(() {}); // 字段可能已变，触发重建刷新界面
              },
              child: const Text('演示 ??= 懒初始化'),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ 注意：不要在 build 里对可空字段随意加 !，'
              '数据变 null 时会抛异常红屏；优先用 ?? 给默认值或做条件渲染。',
            ),
          ],
        ),
      ),
    );
  }
}
