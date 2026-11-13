// ============================================================
// 文件：04_stateless_widget.dart
// 阶段：初级
// 主题：StatelessWidget 与 const 构造函数
// 学习目标：
//   1. 掌握 StatelessWidget 的 build 方法与 Widget 树概念
//   2. 理解“配置即 UI”：Widget 是不可变的配置描述
//   3. 认识 const 构造函数对性能的意义
// 运行方式：flutter run 后，在首页选择“04 StatelessWidget”
// 预计阅读时间：12 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 页面本体也是 StatelessWidget：它自己不存状态，显示内容由参数决定。
class StatelessWidgetExample extends StatelessWidget {
  const StatelessWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('04 StatelessWidget')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // ⚠️ 注意体会：这一整棵子树都是 const，重建时零成本
          _ProfileCard(
            name: '张三',
            role: 'Flutter 初学者',
            icon: Icons.flutter_dash,
            color: Colors.blue,
          ),
          SizedBox(height: 12),
          _ProfileCard(
            name: '李四',
            role: 'Dart 爱好者',
            icon: Icons.code,
            color: Colors.green,
          ),
          SizedBox(height: 24),
          Text(
            '要点：\n'
            '1. StatelessWidget 一旦创建，字段不可变（全部 final）；\n'
            '2. 界面 = build() 返回的 Widget 树，树只是“配置描述”，很轻；\n'
            '3. const Widget 在编译期创建，重建时直接复用同一实例，'
            'Flutter 会跳过其整棵子树的重建，是最便宜的性能优化。',
          ),
        ],
      ),
    );
  }
}

/// 自定义 StatelessWidget：一张资料卡片。
/// 字段全部 final，构造函数 const —— 满足这两个条件就能享受 const 复用。
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.role,
    required this.icon,
    required this.color,
  });

  final String name;
  final String role;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Card 提供阴影与圆角外观；内部 Row 横向排列图标与文字
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 左侧：圆形图标背景
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            // 右侧：两行文字；Column 默认从左对齐需要显式指定
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text(role),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
