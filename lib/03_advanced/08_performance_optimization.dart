// ============================================================
// 文件：08_performance_optimization.dart
// 阶段：高级
// 主题：性能优化实践（const / RepaintBoundary / 对象复用 / itemExtent）
// 学习目标：
//   1. 掌握 const 构造函数减少重建的原理
//   2. 掌握 RepaintBoundary 隔离重绘区域
//   3. 认识 build 中重复创建对象的开销与 ListView itemExtent 优化
// 运行方式：flutter run 后，在首页选择“08 性能优化实践”
// 预计阅读时间：20 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 交互演示：一个高频动画旁边放着两组列表，对比「优化写法」与「反面教材」。
class PerformanceOptimizationExample extends StatefulWidget {
  const PerformanceOptimizationExample({super.key});

  @override
  State<PerformanceOptimizationExample> createState() =>
      _PerformanceOptimizationExampleState();
}

class _PerformanceOptimizationExampleState
    extends State<PerformanceOptimizationExample> {
  bool _optimized = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('08 性能优化')),
      body: Column(
        children: [
          SwitchListTile(
            title: Text(_optimized ? '当前：优化写法' : '当前：反面教材'),
            subtitle: const Text(
              '切换后用 flutter run --profile + DevTools 观察帧耗时差异',
            ),
            value: _optimized,
            onChanged: (v) => setState(() => _optimized = v),
          ),
          // ---- 高频动画：持续触发重绘，用来“放大”周边重绘成本 ----
          // RepaintBoundary：把动画隔离成独立图层，它的重绘不会波及兄弟节点。
          // 为什么有效：Flutter 按图层合成，边界内重绘只需重光栅化该图层。
          const RepaintBoundary(child: _SpinningBadge()),
          const Divider(),
          Expanded(
            child: _optimized ? const _OptimizedList() : const _NaiveList(),
          ),
        ],
      ),
    );
  }
}

/// 持续旋转的小徽标：模拟页面上的高频重绘源。
class _SpinningBadge extends StatefulWidget {
  const _SpinningBadge();

  @override
  State<_SpinningBadge> createState() => _SpinningBadgeState();
}

class _SpinningBadgeState extends State<_SpinningBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.settings, size: 64, color: Colors.deepPurple),
    );
  }
}

/// 优化版列表：itemExtent 固定行高 + const 行内容。
class _OptimizedList extends StatelessWidget {
  const _OptimizedList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 500,
      // itemExtent：告诉列表每行固定 56px。
      // 为什么快：省掉逐行测量，滚动位置可直接乘法计算，
      // 长列表快速滚动时布局成本显著下降。
      itemExtent: 56,
      itemBuilder: (context, i) => const SizedBox(
        height: 56,
        // const 行内容：编译期常量，重建零成本
        child: ListTile(
          title: Text('固定内容行（const）'),
          leading: Icon(Icons.check_circle),
        ),
      ),
    );
  }
}

/// 反面教材：build 里反复创建大对象 + 不固定行高。
class _NaiveList extends StatelessWidget {
  const _NaiveList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: (context, i) {
        // ⚠️ 注意（反面）：在 build 里 new 大列表/格式化对象，
        // 每次重建都重新分配，给 GC 制造压力。应缓存到字段或移到 initState。
        final wasteful = List.generate(200, (j) => j * i); // 纯粹浪费的计算
        return ListTile(
          leading: const Icon(Icons.warning_amber),
          title: Text('反面教材行 $i（每次重建都重算 200 个数字）'),
          subtitle: Text('wasteful 长度：${wasteful.length}'),
        );
      },
    );
  }
}
