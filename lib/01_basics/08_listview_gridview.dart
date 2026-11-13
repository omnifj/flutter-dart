// ============================================================
// 文件：08_listview_gridview.dart
// 阶段：初级
// 主题：ListView 与 GridView 的惰性构建
// 学习目标：
//   1. 掌握 ListView.builder 与 GridView.builder 的用法
//   2. 理解 itemBuilder 的惰性构建与滚动性能的关系
//   3. 学会在运行时切换列表/网格两种布局
// 运行方式：flutter run 后，在首页选择“08 ListView 与 GridView”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 生成 1000 条假数据，用 SegmentedButton 在列表/网格间切换。
class ListViewGridViewExample extends StatefulWidget {
  const ListViewGridViewExample({super.key});

  @override
  State<ListViewGridViewExample> createState() =>
      _ListViewGridViewExampleState();
}

class _ListViewGridViewExampleState extends State<ListViewGridViewExample> {
  // 1000 条数据：如果用 Column 一次性创建会卡死，builder 模式只创建可见项
  final List<String> _items = List.generate(1000, (i) => '条目 ${i + 1}');
  bool _gridMode = false; // false=列表，true=网格

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('08 ListView / GridView')),
      body: Column(
        children: [
          // ---- 布局切换开关 ----
          Padding(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.view_list),
                  label: Text('列表'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.grid_view),
                  label: Text('网格'),
                ),
              ],
              selected: {_gridMode},
              onSelectionChanged: (s) => setState(() => _gridMode = s.first),
            ),
          ),
          // ---- 滚动区域：Expanded 占满剩余高度，否则 Column 内滚动视图会溢出 ----
          Expanded(
            // itemBuilder 只在条目即将进入屏幕时被调用 —— 这就是“惰性构建”。
            // 1000 条数据同一时刻只创建十几个 Widget，内存与流畅度才有保障。
            child: _gridMode
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 每行 3 列
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    padding: const EdgeInsets.all(8),
                    itemCount: _items.length,
                    itemBuilder: (context, index) =>
                        _GridCard(label: _items[index]),
                  )
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(_items[index]),
                      subtitle: Text('这是第 ${index + 1} 行的副标题'),
                      onTap: () {
                        // SnackBar 需要最近的 Scaffold 上下文
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('点击了 ${_items[index]}')),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 网格项卡片：抽成独立 Widget 让 build 主体更易读。
class _GridCard extends StatelessWidget {
  const _GridCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Center(child: Text(label)),
    );
  }
}
