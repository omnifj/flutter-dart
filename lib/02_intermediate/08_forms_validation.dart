// ============================================================
// 文件：08_forms_validation.dart
// 阶段：中级
// 主题：表单与校验（Form + TextFormField + validator）
// 学习目标：
//   1. 掌握 Form + GlobalKey<FormState> 统一管理多个输入项
//   2. 掌握 validator 校验规则与 autovalidateMode
//   3. 掌握 FocusNode 实现“下一项”焦点流转
// 运行方式：flutter run 后，在首页选择“08 表单与校验”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 注册表单：用户名 / 邮箱 / 密码，演示统一校验与焦点流转。
class FormsValidationExample extends StatefulWidget {
  const FormsValidationExample({super.key});

  @override
  State<FormsValidationExample> createState() => _FormsValidationExampleState();
}

class _FormsValidationExampleState extends State<FormsValidationExample> {
  // GlobalKey<FormState> 是操控表单的“遥控器”：校验、保存、重置都靠它
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String _name = '';
  String _email = '';
  String _password = '';

  @override
  void dispose() {
    // FocusNode 同样持有资源，页面销毁时必须释放
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    // validate() 会依次调用所有 TextFormField 的 validator，
    // 全部返回 null（通过）才返回 true
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // 触发所有 onSaved，把值收进字段
      // onSaved 修改了字段但不在 setState 里，这里补一次重建刷新底部展示
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('注册成功：$_name / $_email')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('08 表单与校验')),
      body: Form(
        key: _formKey, // 把遥控器绑到 Form 上
        // 用户交互过一次后实时校验，体验比提交时才报错好
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- 用户名 ----
            TextFormField(
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
              // validator 返回 null 表示通过，返回字符串即错误提示
              validator: (v) {
                if (v == null || v.trim().length < 2) return '用户名至少 2 个字符';
                return null;
              },
              onSaved: (v) => _name = v!.trim(),
              textInputAction: TextInputAction.next,
              // 回车跳到邮箱输入框
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            ),
            const SizedBox(height: 12),
            // ---- 邮箱 ----
            TextFormField(
              focusNode: _emailFocus,
              decoration: const InputDecoration(
                labelText: '邮箱',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null ||
                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                  return '请输入合法邮箱';
                }
                return null;
              },
              onSaved: (v) => _email = v!.trim(),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 12),
            // ---- 密码 ----
            TextFormField(
              focusNode: _passwordFocus,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // 密码掩码
              validator: (v) {
                if (v == null || v.length < 6) return '密码至少 6 位';
                if (!RegExp(r'[0-9]').hasMatch(v)) return '密码需包含数字';
                return null;
              },
              onSaved: (v) => _password = v!,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: const Text('提交注册')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _formKey.currentState!.reset(), // 一键清空并清除错误
              child: const Text('重置'),
            ),
            // ⚠️ 注意：_password 在本例仅用于演示保存流程，
            // 真实项目不要在内存中长时间持有明文密码。
            Text('当前已保存：name=$_name, email=$_email, 密码长度=${_password.length}'),
          ],
        ),
      ),
    );
  }
}
