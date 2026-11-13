// ============================================================
// 文件：07_json_serialization.dart
// 阶段：中级
// 主题：JSON 序列化（dart:convert + 手写 fromJson/toJson）
// 学习目标：
//   1. 掌握 jsonDecode / jsonEncode 的基本用法
//   2. 学会手写 fromJson / toJson（含嵌套模型与默认值）
//   3. 理解手动序列化与代码生成方案的取舍
// 运行方式：flutter run 后，在首页选择“07 JSON 序列化”
// 预计阅读时间：15 分钟
// ============================================================
import 'dart:convert';

import 'package:material_ui/material_ui.dart';

/// 嵌套模型：地址是用户的一部分，各自负责自己的序列化。
class Address {
  const Address({required this.city, required this.street});

  final String city;
  final String street;

  // fromJson：把 Map 翻译成对象；字段可能缺失时用 ?? 给默认值兜底
  factory Address.fromJson(Map<String, dynamic> json) => Address(
    city: json['city'] as String? ?? '未知城市',
    street: json['street'] as String? ?? '',
  );

  // toJson：与 fromJson 对称，保证能“往返”（encode 后再 decode 不丢信息）
  Map<String, dynamic> toJson() => {'city': city, 'street': street};
}

class User {
  const User({required this.id, required this.name, required this.address});

  final int id;
  final String name;
  final Address address;

  factory User.fromJson(Map<String, dynamic> json) => User(
    // ⚠️ 注意：JSON 数字可能是 int 也可能是 double，用 num 中转最稳
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    // 嵌套对象：先取出子 Map，再委托给子模型自己的 fromJson
    address: Address.fromJson(json['address'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address.toJson(),
  };
}

/// 交互演示：解析一段内置 JSON → 展示对象 → 再编码回 JSON 对比。
class JsonSerializationExample extends StatefulWidget {
  const JsonSerializationExample({super.key});

  @override
  State<JsonSerializationExample> createState() =>
      _JsonSerializationExampleState();
}

class _JsonSerializationExampleState extends State<JsonSerializationExample> {
  // 模拟服务器返回的原始 JSON 字符串
  static const _rawJson = '''
  {"id": 1, "name": "张三", "address": {"city": "上海", "street": "世纪大道 100 号"}}
  ''';

  User? _user;
  String _encoded = '';
  String? _error;

  void _decode() {
    try {
      // jsonDecode 的结果是 dynamic，必须先 as 成具体类型再使用
      final map = jsonDecode(_rawJson) as Map<String, dynamic>;
      setState(() {
        _user = User.fromJson(map);
        _encoded = '';
        _error = null;
      });
    } on FormatException catch (e) {
      // JSON 文本不合法会抛 FormatException，UI 上要兜底
      setState(() => _error = '解析失败：$e');
    }
  }

  void _encode() {
    final user = _user;
    if (user == null) return;
    // JsonEncoder.withIndent 让输出带缩进，便于阅读
    setState(
      () =>
          _encoded = const JsonEncoder.withIndent('  ').convert(user.toJson()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      appBar: AppBar(title: const Text('07 JSON 序列化')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('原始 JSON：'),
          // _rawJson 是编译期常量，这一整块 Card 都可以 const
          const Card(
            child: Padding(padding: EdgeInsets.all(12), child: Text(_rawJson)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                onPressed: _decode,
                child: const Text('jsonDecode → 对象'),
              ),
              FilledButton.tonal(
                onPressed: _encode,
                child: const Text('对象 → jsonEncode'),
              ),
            ],
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          const Divider(height: 32),
          if (user != null) ...[
            // ---- 解析结果展示 ----
            ListTile(
              title: Text('姓名：${user.name}'),
              subtitle: Text('ID：${user.id}'),
            ),
            ListTile(
              title: Text('城市：${user.address.city}'),
              subtitle: Text('街道：${user.address.street}'),
            ),
          ],
          if (_encoded.isNotEmpty) ...[
            const Text('重新编码结果：'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_encoded),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
