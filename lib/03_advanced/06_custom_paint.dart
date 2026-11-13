// ============================================================
// 文件：06_custom_paint.dart
// 阶段：高级
// 主题：CustomPaint 自定义绘制（Canvas / Paint / shouldRepaint）
// 学习目标：
//   1. 掌握 CustomPainter 的 paint 方法与 Canvas 常用 API
//   2. 理解 Paint 对象：颜色、笔触、填充模式
//   3. 掌握 shouldRepaint 的返回值策略与性能关系
// 运行方式：flutter run 后，在首页选择“06 CustomPaint 自定义绘制”
// 预计阅读时间：18 分钟
// ============================================================
import 'dart:math';

import 'package:material_ui/material_ui.dart';

/// 交互：点击按钮生成新的随机数据，自定义柱状图随即重绘。
class CustomPaintExample extends StatefulWidget {
  const CustomPaintExample({super.key});

  @override
  State<CustomPaintExample> createState() => _CustomPaintExampleState();
}

class _CustomPaintExampleState extends State<CustomPaintExample> {
  final _random = Random();
  late List<double> _values = _randomValues();

  List<double> _randomValues() =>
      List.generate(7, (_) => 0.2 + _random.nextDouble() * 0.8); // 0.2~1.0

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('06 CustomPaint')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('自定义绘制的柱状图（7 天活跃度）：'),
            const SizedBox(height: 16),
            // CustomPaint 把一块画布交给我们的 Painter
            Expanded(
              child: CustomPaint(
                size: Size.infinite, // 画布占满父级给的全部空间
                painter: _BarChartPainter(_values),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _values = _randomValues()),
              child: const Text('随机换一组数据'),
            ),
            const SizedBox(height: 12),
            const Text(
              '要点：paint 里每次都在“全新画布”上从头画；\n'
              '数据不变时 shouldRepaint 返回 false 可避免整帧重绘。',
            ),
          ],
        ),
      ),
    );
  }
}

/// 柱状图画笔：负责把数值列表画成柱子 + 坐标轴。
class _BarChartPainter extends CustomPainter {
  _BarChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    // Paint 对象复用：先画轴线再改属性画柱子，避免重复创建
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final bottom = size.height - 24; // 底部留 24px 画轴与标签
    // ---- 画 X / Y 轴 ----
    canvas.drawLine(const Offset(24, 0), Offset(24, bottom), paint); // Y 轴
    canvas.drawLine(
      Offset(24, bottom),
      Offset(size.width, bottom),
      paint,
    ); // X 轴

    // ---- 画柱子 ----
    final barAreaWidth = size.width - 32;
    final barWidth = barAreaWidth / values.length * 0.6;
    final gap = barAreaWidth / values.length;
    paint
      ..color = Colors.deepPurple
      ..style = PaintingStyle.fill;
    for (var i = 0; i < values.length; i++) {
      final barHeight = (bottom - 16) * values[i];
      final left = 28 + gap * i + (gap - barWidth) / 2;
      // Rect 定义矩形范围；RRect 可加圆角，这里用直角柱
      final rect = Rect.fromLTWH(left, bottom - barHeight, barWidth, barHeight);
      canvas.drawRect(rect, paint);
    }

    // ---- 画数值标签（TextPainter 是 Canvas 里画文字的方式） ----
    for (var i = 0; i < values.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${(values[i] * 100).round()}',
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final barHeight = (bottom - 16) * values[i];
      tp.paint(
        canvas,
        Offset(28 + gap * i + (gap - tp.width) / 2, bottom - barHeight - 14),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) {
    // 只有数据引用变了才重绘；同一实例直接跳过重绘，省一帧
    return oldDelegate.values != values;
  }
}
