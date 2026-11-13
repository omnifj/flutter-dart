// ============================================================
// 文件：07_slivers_advanced.dart
// 阶段：高级
// 主题：Slivers 高级滚动（SliverAppBar / SliverList / SliverGrid）
// 学习目标：
//   1. 理解 Sliver 与普通 Widget 的差异：Sliver 是“可滚动区域的分片”
//   2. 掌握 CustomScrollView 组合多种 Sliver
//   3. 掌握 SliverAppBar 的折叠（pinned/floating/snap）效果
// 运行方式：flutter run 后，在首页选择“07 Slivers 高级滚动”
// 预计阅读时间：18 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 页面：折叠头部 + 网格区 + 列表区共存于同一个滚动视图。
class SliversAdvancedExample extends StatelessWidget {
  const SliversAdvancedExample({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠️ 注意：用了 SliverAppBar 就不要再包一层 Scaffold 的 AppBar，
    // 标题栏由 SliverAppBar 在滚动中接管。
    return Scaffold(
      // CustomScrollView 的 slivers 列表：每一项都是 SliverXxx，
      // 普通 Widget 必须包一层 SliverToBoxAdapter 才能混入。
      body: CustomScrollView(
        slivers: [
          // ---- 折叠头部：下滑展开大图，上滑收缩成普通 AppBar ----
          SliverAppBar(
            expandedHeight: 180,
            pinned: true, // 收缩后标题栏钉在顶部
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('07 Slivers 高级滚动'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.indigo],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          // ---- 区段标题：普通 Widget 用 SliverToBoxAdapter 包一层 ----
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('网格区（SliverGrid）：', style: TextStyle(fontSize: 16)),
            ),
          ),
          // ---- 网格 Sliver ----
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Card(
                color: Colors.teal.shade100,
                child: Center(child: Text('G$i')),
              ),
              childCount: 8,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('列表区（SliverList）：', style: TextStyle(fontSize: 16)),
            ),
          ),
          // ---- 列表区：与网格区共享同一滚动，丝滑衔接 ----
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => ListTile(
                leading: CircleAvatar(child: Text('$i')),
                title: Text('列表条目 $i'),
                subtitle: const Text('与上方网格在同一个滚动视图里'),
              ),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
