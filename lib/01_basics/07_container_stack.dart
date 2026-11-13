// ============================================================
// 文件：07_container_stack.dart
// 阶段：初级
// 主题：Container 装饰与 Stack 层叠布局
// 学习目标：
//   1. 掌握 Container 的 padding / margin / decoration
//   2. 掌握 Stack + Positioned 实现层叠效果
//   3. 理解 Align 定位与 Stack 的配合
// 运行方式：flutter run 后，在首页选择“07 Container 与 Stack”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 一张可交互的“会员卡片”：滑动条调整圆角，开关控制角标显示。
class ContainerStackExample extends StatefulWidget {
  const ContainerStackExample({super.key});

  @override
  State<ContainerStackExample> createState() => _ContainerStackExampleState();
}

class _ContainerStackExampleState extends State<ContainerStackExample> {
  double _radius = 16; // 卡片圆角，由滑块驱动
  bool _showBadge = true; // 是否显示右上角角标

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('07 Container 与 Stack')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---- Stack：让角标叠在卡片之上 ----
            Stack(
              // clipBehavior 控制角标超出卡片时是否裁剪
              clipBehavior: Clip.none,
              children: [
                // 第一层（底部）：卡片本体
                Container(
                  height: 180,
                  width: double.infinity,
                  // margin 是容器外间距，padding 是内边距，别搞混
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(24),
                  // decoration 负责背景渐变、圆角、阴影等视觉装饰
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.indigo, Colors.deepPurple],
                    ),
                    borderRadius: BorderRadius.circular(_radius),
                    boxShadow: const [
                      BoxShadow(blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIP 会员卡',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      Spacer(), // Spacer 吃掉剩余空间，把卡号推到底部
                      Text(
                        '**** **** 9527',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                // 第二层（顶部）：Positioned 精确放置角标
                // ⚠️ 注意：Stack 里的非定位子项默认堆在左上角，
                //    想自由摆放必须包一层 Positioned 或 Align。
                if (_showBadge)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Chip(
                      label: Text('NEW'),
                      backgroundColor: Colors.amber,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // ---- 交互控制区 ----
            Row(
              children: [
                const Text('圆角'),
                // Expanded 让 Slider 占满剩余宽度，避免溢出
                Expanded(
                  child: Slider(
                    value: _radius,
                    max: 60,
                    onChanged: (v) => setState(() => _radius = v),
                  ),
                ),
                Text(_radius.toStringAsFixed(0)),
              ],
            ),
            SwitchListTile(
              title: const Text('显示 NEW 角标'),
              value: _showBadge,
              onChanged: (v) => setState(() => _showBadge = v),
            ),
          ],
        ),
      ),
    );
  }
}
