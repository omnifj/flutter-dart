// ============================================================
// 文件：10_real_world_app.dart
// 阶段：高级
// 主题：综合实战 —— 待办清单（状态管理 + 路由 + 持久化模拟 + 列表交互）
// 学习目标：
//   1. 串联 Provider 状态管理、页面路由、列表增删改查
//   2. 理解「内存模拟持久化」的接口设计，日后可平滑替换为
//      shared_preferences / 数据库
//   3. 体验一个完整小应用的代码组织方式
// 运行方式：flutter run 后，在首页选择“10 综合实战：待办清单”
// 预计阅读时间：25 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

// ---------------- 数据层：实体 + 存储接口 + 内存实现 ----------------

class Todo {
  const Todo({required this.id, required this.title, this.done = false});

  final int id;
  final String title;
  final bool done;

  /// copyWith：不可变对象的“修改”方式是创建一个替换了部分字段的新对象。
  Todo copyWith({bool? done}) =>
      Todo(id: id, title: title, done: done ?? this.done);
}

/// 存储接口：当前是内存实现；换成 shared_preferences 时实现此接口即可，
/// 上层（Store/UI）零改动 —— 这就是接口隔离的价值。
abstract class TodoStorage {
  Future<List<Todo>> load();
  Future<void> save(List<Todo> todos);
}

/// 内存模拟持久化：进程内有效，重启丢失；带一点延迟模拟真实 IO。
class InMemoryTodoStorage implements TodoStorage {
  List<Todo> _cache = const [
    Todo(id: 1, title: '学会 Flutter 基础'),
    Todo(id: 2, title: '读完中级阶段文档', done: true),
  ];

  @override
  Future<List<Todo>> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.of(_cache);
  }

  @override
  Future<void> save(List<Todo> todos) async {
    _cache = List.of(todos);
  }
}

// ---------------- 状态层：Store 协调存储与 UI ----------------

class TodoStore extends ChangeNotifier {
  TodoStore(this._storage);

  final TodoStorage _storage;
  List<Todo> _todos = [];
  bool _loading = false;

  List<Todo> get todos => _todos;
  bool get loading => _loading;
  int get doneCount => _todos.where((t) => t.done).length;

  /// 初始化加载：读存储 → 更新状态 → 广播。
  Future<void> init() async {
    _loading = true;
    notifyListeners(); // 先广播“加载中”，UI 立刻显示进度条
    _todos = await _storage.load();
    _loading = false;
    notifyListeners(); // await 之后广播“加载完成”
  }

  Future<void> add(String title) async {
    final id = _todos.isEmpty
        ? 1
        : _todos.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    _todos = [..._todos, Todo(id: id, title: title)];
    await _storage.save(_todos); // 先存后广播，保证状态与持久层一致
    notifyListeners();
  }

  Future<void> toggle(int id) async {
    _todos = [
      for (final t in _todos) t.id == id ? t.copyWith(done: !t.done) : t,
    ];
    await _storage.save(_todos);
    notifyListeners();
  }

  Future<void> remove(int id) async {
    _todos = _todos.where((t) => t.id != id).toList();
    await _storage.save(_todos);
    notifyListeners();
  }
}

// ---------------- 表现层：列表页 + 新增页 ----------------

/// 示例入口：提供 Store，并负责启动时初始化一次。
class RealWorldAppExample extends StatelessWidget {
  const RealWorldAppExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoStore(InMemoryTodoStorage())..init(),
      child: const _TodoListPage(),
    );
  }
}

class _TodoListPage extends StatelessWidget {
  const _TodoListPage();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TodoStore>();
    return Scaffold(
      appBar: AppBar(
        title: Text('待办清单（${store.doneCount}/${store.todos.length} 完成）'),
      ),
      body: store.loading
          ? const Center(child: CircularProgressIndicator())
          : store.todos.isEmpty
          ? const Center(child: Text('暂无待办，点右下角添加'))
          : ListView.builder(
              itemCount: store.todos.length,
              itemBuilder: (context, i) {
                final todo = store.todos[i];
                // Dismissible：滑动删除，典型列表交互
                return Dismissible(
                  key: ValueKey(todo.id),
                  background: const ColoredBox(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  onDismissed: (_) => context.read<TodoStore>().remove(todo.id),
                  child: CheckboxListTile(
                    value: todo.done,
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        // 完成项加删除线，视觉反馈立即可见
                        decoration: todo.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    onChanged: (_) => context.read<TodoStore>().toggle(todo.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ⚠️ 注意：push 出来的新路由与当前页面是“兄弟”而非“后代”，
          // 默认访问不到这里的 Provider；用 Provider.value 把同一个
          // Store 实例显式带进新路由，新页面才能正常 read/watch。
          final store = context.read<TodoStore>();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider<TodoStore>.value(
                value: store,
                child: const _TodoAddPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 新增页：输入标题，返回前写入 Store。
class _TodoAddPage extends StatefulWidget {
  const _TodoAddPage();

  @override
  State<_TodoAddPage> createState() => _TodoAddPageState();
}

class _TodoAddPageState extends State<_TodoAddPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新增待办')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '待办内容',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('保存')),
          ],
        ),
      ),
    );
  }

  void _save() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    // Store 通过 Provider.value 传进了本路由，这里可以直接 read
    context.read<TodoStore>().add(title);
    Navigator.of(context).pop();
  }
}
