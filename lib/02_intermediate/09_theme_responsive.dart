// ============================================================
// 文件：09_theme_responsive.dart
// 阶段：中级
// 主题：Material 3 主题与响应式布局
// 学习目标：
//   1. 掌握 ThemeData / colorSchemeSeed 生成整套 Material 3 配色
//   2. 掌握 MediaQuery 与 LayoutBuilder 的区别与使用场景
//   3. 掌握断点（breakpoint）驱动的布局切换
// 运行方式：flutter run 后，在首页选择“09 主题与响应式布局”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 演示页面：局部主题覆盖 + 深浅色切换 + 响应式双栏/单栏。
class ThemeResponsiveExample extends StatefulWidget {
  const ThemeResponsiveExample({super.key});

  @override
  State<ThemeResponsiveExample> createState() => _ThemeResponsiveExampleState();
}

class _ThemeResponsiveExampleState extends State<ThemeResponsiveExample> {
  bool _dark = false;
  Color _seed = Colors.blue;

  @override
  Widget build(BuildContext context) {
    // 局部 Theme：只影响本页面子树，不动全局主题。
    // colorSchemeSeed 让 Material 3 从一颗种子色派生出完整和谐的配色方案。
    return Theme(
      data: ThemeData(
        colorSchemeSeed: _seed,
        brightness: _dark ? Brightness.dark : Brightness.light,
      ),
      child: Builder(
        // ⚠️ 注意：要在 Theme 之下取新主题，必须用 Builder 拿到下层 context，
        // 否则 Theme.of(context) 读到的还是外层旧主题。
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          return Scaffold(
            appBar: AppBar(title: const Text('09 主题与响应式')),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- 主题控制区 ----
                SwitchListTile(
                  title: const Text('深色模式'),
                  value: _dark,
                  onChanged: (v) => setState(() => _dark = v),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                    ])
                      InkWell(
                        onTap: () => setState(() => _seed = c),
                        child: CircleAvatar(backgroundColor: c, radius: 16),
                      ),
                  ],
                ),
                // ---- 色板：展示 Material 3 配色角色 ----
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _swatch('primary', scheme.primary, scheme.onPrimary),
                      _swatch(
                        'secondary',
                        scheme.secondary,
                        scheme.onSecondary,
                      ),
                      _swatch('tertiary', scheme.tertiary, scheme.onTertiary),
                      _swatch('surface', scheme.surface, scheme.onSurface),
                    ],
                  ),
                ),
                const Divider(),
                // ---- 响应式区：LayoutBuilder 读取父级约束 ----
                Expanded(
                  child: LayoutBuilder(
                    // LayoutBuilder 拿到的是父级给的约束，比 MediaQuery 更适合
                    // 局部组件（MediaQuery 报告的是整机屏幕尺寸）。
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      // 断点：600dp 是 Material 指南推荐的手机/平板分界
                      final wide = width >= 600;
                      return Column(
                        children: [
                          Text(
                            '当前宽度 ${width.toStringAsFixed(0)}dp → '
                            '${wide ? "宽屏双栏" : "窄屏单栏"}',
                          ),
                          Expanded(
                            child: wide
                                ? Row(children: [_pane('左栏'), _pane('右栏')])
                                : Column(children: [_pane('上栏'), _pane('下栏')]),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _swatch(String name, Color bg, Color fg) {
    return Expanded(
      child: Container(
        height: 48,
        color: bg,
        alignment: Alignment.center,
        child: Text(name, style: TextStyle(color: fg, fontSize: 12)),
      ),
    );
  }

  Widget _pane(String label) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Center(child: Text(label)),
      ),
    );
  }
}
