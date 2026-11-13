// ============================================================
// 文件：02_dart_basics.dart
// 阶段：初级
// 主题：Dart 语言基础（变量、函数、集合、字符串插值）
// 学习目标：
//   1. 掌握 var / final / const 的区别与类型推断
//   2. 掌握函数定义、可选命名参数与默认值
//   3. 熟练使用 List / Map / Set 与字符串插值
// 运行方式：flutter run 后，在首页选择“02 Dart 语言基础”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 用交互按钮演示 Dart 语法：每次点击执行一段代码，把结果追加到屏幕日志里。
class DartBasicsExample extends StatefulWidget {
  const DartBasicsExample({super.key});

  @override
  State<DartBasicsExample> createState() => _DartBasicsExampleState();
}

class _DartBasicsExampleState extends State<DartBasicsExample> {
  // 日志列表：所有演示的输出都追加到这里，用 ListView 展示
  final List<String> _logs = [];

  void _log(String message) {
    // 修改了会影响 UI 的数据，必须包在 setState 里框架才会重绘
    setState(() => _logs.add(message));
  }

  // ---------- 演示 1：变量与常量 ----------
  void _demoVariables() {
    var name = 'Flutter'; // var + 类型推断：编译器推断为 String
    final year = DateTime.now().year; // final：运行期只能赋值一次
    const pi = 3.14159; // const：编译期常量，⚠️ 不能赋运行时计算的值
    // year = 2025; // ❌ 编译错误：final 变量不能二次赋值
    _log('var 推断: $name (String)；final: $year；const: $pi');
  }

  // ---------- 演示 2：函数与可选参数 ----------
  // 命名参数用大括号，required 表示必传，其余可给默认值
  String greet(String name, {String prefix = '你好', bool shout = false}) {
    final text = '$prefix，$name！';
    return shout ? text.toUpperCase() : text;
  }

  void _demoFunctions() {
    _log(greet('Dart')); // 使用默认参数
    _log(greet('Flutter', prefix: '欢迎', shout: true)); // 覆盖默认值
  }

  // ---------- 演示 3：集合 ----------
  void _demoCollections() {
    final list = <String>['Dart', 'Flutter', 'Dart']; // List：有序、可重复
    final set = list.toSet(); // Set：自动去重（重复元素只保留一个）
    final map = {'language': 'Dart', 'ui': 'Flutter'}; // Map：键值对
    // 集合里可以直接写展开运算符与条件元素，非常适合构建 Widget 列表
    final widgets = ['基础', if (list.length > 2) '进阶', ...set.take(1)];
    _log('List(${list.length})=$list');
    _log('Set(${set.length})=$set  ← 重复的 Dart 被去掉了');
    _log('Map: language=${map['language']}');
    _log('集合内 if/展开: $widgets');
  }

  // ---------- 演示 4：字符串插值 ----------
  void _demoInterpolation() {
    const a = 6;
    const b = 7;
    _log('简单插值: a=$a'); // $变量名
    _log('表达式插值: a*b=${a * b}'); // ${表达式}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('02 Dart 语言基础')),
      body: Column(
        children: [
          // ---- 按钮区：每个按钮执行一段语法演示 ----
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: _demoVariables,
                child: const Text('变量'),
              ),
              FilledButton.tonal(
                onPressed: _demoFunctions,
                child: const Text('函数'),
              ),
              FilledButton.tonal(
                onPressed: _demoCollections,
                child: const Text('集合'),
              ),
              FilledButton.tonal(
                onPressed: _demoInterpolation,
                child: const Text('插值'),
              ),
              OutlinedButton(
                onPressed: () => setState(_logs.clear),
                child: const Text('清空'),
              ),
            ],
          ),
          const Divider(),
          // ---- 日志区：Expanded 占满剩余空间，内部可滚动 ----
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '${_logs.length - index}. ${_logs[_logs.length - 1 - index]}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
