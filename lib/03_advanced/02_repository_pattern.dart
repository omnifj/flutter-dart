// ============================================================
// 文件：02_repository_pattern.dart
// 阶段：高级
// 主题：Repository 模式与数据源切换、错误映射
// 学习目标：
//   1. 掌握「接口 + 多实现」的仓库模式
//   2. 学会在运行期切换内存 / 模拟远程数据源
//   3. 掌握把底层异常映射为业务友好的错误类型
// 运行方式：flutter run 后，在首页选择“02 Repository 模式”
// 预计阅读时间：18 分钟
// ============================================================
import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

/// 业务错误：UI 只需要认识这一种错误，不用关心底层是网络错还是解析错。
sealed class NoteError implements Exception {
  const NoteError();

  String get message;
}

class NetworkNoteError extends NoteError {
  const NetworkNoteError();

  @override
  String get message => '网络异常，请稍后重试';
}

class Note {
  const Note({required this.id, required this.text});

  final int id;
  final String text;
}

/// 仓库接口：对上层屏蔽数据来源。
abstract class NoteRepository {
  Future<List<Note>> fetchNotes();
}

/// 内存数据源：即时返回，模拟缓存/离线场景。
class InMemoryNoteRepository implements NoteRepository {
  @override
  Future<List<Note>> fetchNotes() async => const [
    Note(id: 1, text: '内存笔记：响应最快'),
    Note(id: 2, text: '内存笔记：适合离线兜底'),
  ];
}

/// 模拟远程数据源：有延迟，且 30% 概率抛底层异常。
class RemoteNoteRepository implements NoteRepository {
  final _random = Random();

  @override
  Future<List<Note>> fetchNotes() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_random.nextDouble() < 0.3) {
      throw TimeoutException('模拟网络超时'); // 底层异常类型
    }
    return const [
      Note(id: 101, text: '远程笔记：来自服务器'),
      Note(id: 102, text: '远程笔记：有延迟、可能失败'),
    ];
  }
}

/// 带错误映射的仓库装饰：把底层异常统一翻译成 NoteError。
/// 这样 UI 层只需要 catch NoteError，无需认识 TimeoutException 等细节。
class SafeNoteRepository implements NoteRepository {
  SafeNoteRepository(this._inner);

  final NoteRepository _inner;

  @override
  Future<List<Note>> fetchNotes() async {
    try {
      return await _inner.fetchNotes();
    } on NoteError {
      rethrow; // 已是业务错误，直接透传
    } on Exception {
      throw const NetworkNoteError(); // 错误映射：底层异常 → 业务错误
    }
  }
}

/// 页面：可在运行期切换数据源，观察错误映射后的统一提示。
class RepositoryPatternExample extends StatefulWidget {
  const RepositoryPatternExample({super.key});

  @override
  State<RepositoryPatternExample> createState() =>
      _RepositoryPatternExampleState();
}

class _RepositoryPatternExampleState extends State<RepositoryPatternExample> {
  bool _useRemote = false;

  // 当前生效的仓库：外层包 SafeNoteRepository 做错误映射
  NoteRepository get _repo => SafeNoteRepository(
    _useRemote ? RemoteNoteRepository() : InMemoryNoteRepository(),
  );

  List<Note>? _notes;
  String? _error;
  bool _loading = false;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notes = await _repo.fetchNotes();
      if (!mounted) return;
      setState(() => _notes = notes);
    } on NoteError catch (e) {
      // UI 只认 NoteError：无论底层什么异常，提示都是业务友好的
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('02 Repository 模式')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- 数据源切换：页面无需知道实现差异 ----
          SwitchListTile(
            title: Text(
              '数据源：${_useRemote ? "模拟远程（1s 延迟，30% 失败）" : "内存（立即返回）"}',
            ),
            value: _useRemote,
            onChanged: (v) => setState(() {
              _useRemote = v;
              _notes = null;
              _error = null;
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: _loading ? null : _load,
              child: Text(_loading ? '加载中…' : '加载笔记'),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _notes == null
                ? const Center(child: Text('尚未加载'))
                : ListView(
                    children: [
                      for (final n in _notes!)
                        ListTile(
                          leading: Text('#${n.id}'),
                          title: Text(n.text),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
