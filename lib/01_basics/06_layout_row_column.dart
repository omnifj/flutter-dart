// ============================================================
// 文件：06_layout_row_column.dart
// 阶段：初级
// 主题：Row / Column 线性布局与主轴/交叉轴对齐
// 学习目标：
//   1. 掌握 MainAxisAlignment 与 CrossAxisAlignment 的效果
//   2. 理解 Expanded 与 Flexible 的区别
//   3. 学会用 SizedBox 控制间距
// 运行方式：flutter run 后，在首页选择“06 Row / Column 线性布局”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 交互式布局实验台：切换对齐方式，实时观察三个色块的排布变化。
class LayoutRowColumnExample extends StatefulWidget {
  const LayoutRowColumnExample({super.key});

  @override
  State<LayoutRowColumnExample> createState() => _LayoutRowColumnExampleState();
}

class _LayoutRowColumnExampleState extends State<LayoutRowColumnExample> {
  // 当前选中的对齐方式；改动后 setState 重建即可看到布局变化
  MainAxisAlignment _mainAxis = MainAxisAlignment.start;
  CrossAxisAlignment _crossAxis = CrossAxisAlignment.center;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('06 Row / Column 布局')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- 实验画布：一个 Row 放三个高度不同的色块 ----
          ColoredBox(
            color: Colors.grey.shade200,
            child: SizedBox(
              height: 160,
              child: Row(
                mainAxisAlignment: _mainAxis, // 主轴（Row 横向）对齐
                crossAxisAlignment: _crossAxis, // 交叉轴（Row 纵向）对齐
                children: [
                  _box(Colors.red, 40, '1'),
                  _box(Colors.green, 70, '2'),
                  _box(Colors.blue, 100, '3'),
                ],
              ),
            ),
          ),
          const Divider(),
          // ---- 主轴对齐选择 ----
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('MainAxisAlignment（主轴）'),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final v in MainAxisAlignment.values)
                ChoiceChip(
                  label: Text(v.name),
                  selected: _mainAxis == v,
                  onSelected: (_) => setState(() => _mainAxis = v),
                ),
            ],
          ),
          // ---- 交叉轴对齐选择 ----
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('CrossAxisAlignment（交叉轴）'),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final v in CrossAxisAlignment.values)
                ChoiceChip(
                  label: Text(v.name),
                  selected: _crossAxis == v,
                  onSelected: (_) => setState(() => _crossAxis = v),
                ),
            ],
          ),
          const Divider(),
          // ---- Expanded 对比：flex 比例瓜分剩余空间 ----
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Expanded 按 flex 比例瓜分剩余空间：'),
          ),
          Row(
            children: [
              // Expanded：不管内容多大，强制按份数分配剩余空间
              Expanded(
                flex: 2,
                child: Container(
                  height: 40,
                  color: Colors.orange,
                  alignment: Alignment.center,
                  child: const Text('Expanded 2 份'),
                ),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  color: Colors.purple,
                  alignment: Alignment.center,
                  child: const Text(
                    'Expanded 1 份',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // SizedBox：最轻量的固定间距
        ],
      ),
    );
  }

  /// 生成一个带数字标签的色块；高度不同便于观察交叉轴对齐效果。
  Widget _box(Color color, double height, String label) {
    return Container(
      width: 56,
      height: height,
      color: color,
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
