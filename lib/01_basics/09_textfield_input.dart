// ============================================================
// 文件：09_textfield_input.dart
// 阶段：初级
// 主题：TextField 输入与焦点管理
// 学习目标：
//   1. 掌握 TextEditingController 的创建、读取与释放
//   2. 区分 onChanged 与 onSubmitted 的触发时机
//   3. 学会用 FocusNode 管理键盘焦点
// 运行方式：flutter run 后，在首页选择“09 TextField 输入”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 一个迷你留言板：输入内容后按回车或按钮提交，展示在下方列表。
class TextFieldInputExample extends StatefulWidget {
  const TextFieldInputExample({super.key});

  @override
  State<TextFieldInputExample> createState() => _TextFieldInputExampleState();
}

class _TextFieldInputExampleState extends State<TextFieldInputExample> {
  // 控制器负责读写输入框内容；与 Widget 不同，它需要手动 dispose
  final TextEditingController _controller = TextEditingController();
  // FocusNode 用来程序化地请求/释放键盘焦点
  final FocusNode _focusNode = FocusNode();
  final List<String> _messages = [];
  String _preview = ''; // onChanged 实时回显

  @override
  void dispose() {
    // dispose 在页面销毁时调用：控制器与焦点节点都持有系统资源，必须释放
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final text = value.trim();
    if (text.isEmpty) return; // 忽略空白输入
    setState(() {
      _messages.insert(0, text); // 新消息插到最上面
      _preview = '';
    });
    _controller.clear(); // 通过控制器清空输入框
    _focusNode.requestFocus(); // 提交后保持焦点，方便连续输入
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('09 TextField 输入')),
      // resizeToAvoidBottomInset 默认 true：键盘弹出时自动顶起内容
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- 输入区 ----
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.text, // 键盘类型：text/number/email…
              textInputAction: TextInputAction.send, // 回车键显示为“发送”
              decoration: const InputDecoration(
                labelText: '说点什么…',
                hintText: '回车或点击按钮提交',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              // onChanged：每敲一个字符就触发，适合做实时预览/搜索联想
              onChanged: (v) => setState(() => _preview = v),
              // onSubmitted：按下回车/发送键时触发，适合提交
              onSubmitted: _submit,
            ),
            const SizedBox(height: 8),
            Text('onChanged 实时预览：$_preview'),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton(
                  onPressed: () => _submit(_controller.text),
                  child: const Text('提交'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _focusNode.unfocus, // 主动收起键盘
                  child: const Text('收起键盘'),
                ),
              ],
            ),
            const Divider(height: 32),
            // ---- 留言列表 ----
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text('暂无留言，先输入一条吧'))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, i) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.message),
                          title: Text(_messages[i]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
