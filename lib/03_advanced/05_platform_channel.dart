// ============================================================
// 文件：05_platform_channel.dart
// 阶段：高级
// 主题：Platform Channel —— Dart 与原生代码互调
// 学习目标：
//   1. 掌握 MethodChannel 的 Dart 端定义与异步调用
//   2. 理解原生端（Android/iOS）需要配合实现的步骤
//   3. 掌握 MissingPluginException 的成因与兜底处理
// 运行方式：flutter run 后，在首页选择“05 Platform Channel 平台通道”
// 预计阅读时间：18 分钟
// ============================================================
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Dart 端通道定义。
/// ⚠️ 注意：通道名（含包名前缀）必须与原生端注册的名称完全一致，
/// 就像对讲机两端要调到同一频率。
class NativeBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.example.flutter_dart/battery',
  );

  /// 获取电量百分比；未实现的原生端会抛 MissingPluginException。
  static Future<int> getBatteryLevel() async {
    // invokeMethod 是异步的：await 之前请求被序列化发到原生侧；
    // await 之后拿到原生返回的结果（自动反序列化为 Dart 类型）。
    final level = await _channel.invokeMethod<int>('getBatteryLevel');
    return level ?? -1;
  }
}

/// 页面：调用通道并展示结果；捕获未实现异常时给出原生端实现指引。
class PlatformChannelExample extends StatefulWidget {
  const PlatformChannelExample({super.key});

  @override
  State<PlatformChannelExample> createState() => _PlatformChannelExampleState();
}

class _PlatformChannelExampleState extends State<PlatformChannelExample> {
  String _result = '尚未调用';
  bool _calling = false;

  Future<void> _callNative() async {
    setState(() => _calling = true);
    try {
      final level = await NativeBridge.getBatteryLevel();
      if (!mounted) return;
      setState(() => _result = '当前电量：$level%');
    } on MissingPluginException {
      // 本教学项目没有配套的原生工程，走到这里属于预期行为
      if (!mounted) return;
      setState(() => _result = '原生端未实现（MissingPluginException）\n请看下方指引补齐原生代码');
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _result = '原生端报错：${e.message}');
    } finally {
      if (mounted) setState(() => _calling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('05 Platform Channel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: _calling ? null : _callNative,
            child: Text(_calling ? '调用中…' : '调用原生：获取电量'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_result),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '原生端实现步骤（本项目未包含，按需自行添加）：\n\n'
            'Android（MainActivity.kt）：\n'
            '  override fun configureFlutterEngine(fe: FlutterEngine) {\n'
            '    MethodChannel(fe.dartExecutor.binaryMessenger,\n'
            '      "com.example.flutter_dart/battery")\n'
            '      .setMethodCallHandler { call, result ->\n'
            '        if (call.method == "getBatteryLevel") {\n'
            '          val bm = getSystemService(BATTERY_SERVICE)\n'
            '            as BatteryManager\n'
            '          result.success(bm.getIntProperty(\n'
            '            BatteryManager.BATTERY_PROPERTY_CAPACITY))\n'
            '        } else result.notImplemented()\n'
            '      }\n'
            '  }\n\n'
            'iOS（AppDelegate.swift）：\n'
            '  let channel = FlutterMethodChannel(\n'
            '    name: "com.example.flutter_dart/battery",\n'
            '    binaryMessenger: controller.binaryMessenger)\n'
            '  channel.setMethodCallHandler { call, result in\n'
            '    if call.method == "getBatteryLevel" {\n'
            '      UIDevice.current.isBatteryMonitoringEnabled = true\n'
            '      result.success(Int(UIDevice.current.batteryLevel * 100))\n'
            '    } else { result(FlutterMethodNotImplemented) }\n'
            '  }',
          ),
        ],
      ),
    );
  }
}
