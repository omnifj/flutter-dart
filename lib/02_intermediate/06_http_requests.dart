// ============================================================
// 文件：06_http_requests.dart
// 阶段：中级
// 主题：网络请求（dart:io HttpClient + FutureBuilder）
// 学习目标：
//   1. 用 SDK 自带的 HttpClient 发起 GET / POST，保持零第三方依赖
//   2. 掌握 FutureBuilder 的 加载/错误/空 三态处理
//   3. 掌握超时设置与请求取消
// 运行方式：flutter run 后，在首页选择“06 网络请求 HttpClient”
// 预计阅读时间：18 分钟
// ============================================================
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';

/// 请求公共 API jsonplaceholder，演示 GET 列表与 POST 创建。
class HttpRequestsExample extends StatefulWidget {
  const HttpRequestsExample({super.key});

  @override
  State<HttpRequestsExample> createState() => _HttpRequestsExampleState();
}

class _HttpRequestsExampleState extends State<HttpRequestsExample> {
  HttpClient? _client; // 持有引用以便“取消”时强制断开
  Future<String>? _future; // null 表示空闲；FutureBuilder 监听它

  /// 发起 GET：取回前 5 条帖子标题。
  Future<String> _fetchPosts() async {
    final client = HttpClient();
    _client = client;
    try {
      // 超时：连接过程最多 8 秒，防止弱网下无限转圈
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(
        Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'),
      );
      final response = await request.close();
      // await 之前：请求在网络上飞行；await 之后：拿到响应体字节流
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}');
      }
      final list = (jsonDecode(body) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      return list.map((e) => '• ${e['title']}').join('\n');
    } finally {
      client.close(); // 无论成败都释放连接资源
    }
  }

  /// 发起 POST：提交一条 JSON，服务器回显 id。
  Future<String> _createPost() async {
    final client = HttpClient();
    _client = client;
    try {
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.postUrl(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({'title': '你好', 'body': '来自 Flutter', 'userId': 1}),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      return 'POST 成功，服务器返回：\n$body';
    } finally {
      client.close();
    }
  }

  void _start(Future<String> Function() task) {
    setState(() => _future = task()); // 把 Future 交给 FutureBuilder 接管三态
  }

  void _cancel() {
    // ⚠️ 注意：Dart 的 Future 本身不可取消；取消网络请求的做法是
    // 强制关闭底层连接（让 Future 以异常结束），并把 UI 复位。
    _client?.close(force: true);
    setState(() => _future = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('06 网络请求')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () => _start(_fetchPosts),
                  child: const Text('GET 帖子'),
                ),
                FilledButton.tonal(
                  onPressed: () => _start(_createPost),
                  child: const Text('POST 创建'),
                ),
                OutlinedButton(onPressed: _cancel, child: const Text('取消请求')),
              ],
            ),
            const Divider(height: 32),
            // ---- 结果区：FutureBuilder 管理 空闲/加载/错误/成功 四种界面 ----
            Expanded(
              child: _future == null
                  ? const Center(child: Text('空闲状态：点击上方按钮发起请求'))
                  : FutureBuilder<String>(
                      future: _future,
                      builder: (context, snapshot) {
                        // connectionState 描述 Future 的进度
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        // 网络异常、超时、被取消都会进入 hasError 分支
                        if (snapshot.hasError) {
                          return Center(child: Text('出错了：${snapshot.error}'));
                        }
                        final data = snapshot.data;
                        if (data == null || data.isEmpty) {
                          return const Center(child: Text('空状态：服务器没返回内容'));
                        }
                        return SingleChildScrollView(child: Text(data));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
