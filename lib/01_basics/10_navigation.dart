// ============================================================
// 文件：10_navigation.dart
// 阶段：初级
// 主题：Navigator 页面跳转与传值
// 学习目标：
//   1. 掌握 Navigator.push / pop 的基本用法
//   2. 学会用构造函数参数向新页面传值
//   3. 学会用 pop(result) 把结果带回上一页（配合 await）
// 运行方式：flutter run 后，在首页选择“10 页面导航 Navigator”
// 预计阅读时间：15 分钟
// ============================================================
import 'package:material_ui/material_ui.dart';

/// 导航示例首页：演示 push 打开详情页、await 接收返回值、命名路由三种方式。
class NavigationExample extends StatelessWidget {
  const NavigationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('10 页面导航')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- 方式 1：push + 构造函数传参 ----
            FilledButton(
              onPressed: () {
                // push 把新页面压入路由栈；MaterialPageRoute 提供平台风格转场动画
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const _DetailPage(itemId: 42, title: '来自上一页的参数'),
                  ),
                );
              },
              child: const Text('push 打开详情页（带参数）'),
            ),
            const SizedBox(height: 12),
            // ---- 方式 2：await push，接收 pop 带回的结果 ----
            FilledButton.tonal(
              onPressed: () async {
                // await 之前：当前页面暂停等待；push 打开选择页
                final result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => const _PickerPage()),
                );
                // await 之后：选择页 pop 返回，result 即其返回值（可能为 null）
                // ⚠️ 注意：跨 async 间隙使用 context 前必须先判 mounted，
                //    等待期间页面可能已被销毁。
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('选择页返回了：${result ?? "（用户直接返回，未选择）"}')),
                );
              },
              child: const Text('打开选择页并等待返回结果'),
            ),
            const SizedBox(height: 12),
            // ---- 方式 3：命名路由（在嵌套 Navigator 里注册） ----
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _NamedRouteDemo(),
                ),
              ),
              child: const Text('进入命名路由演示（内部子导航）'),
            ),
            const SizedBox(height: 24),
            const Text(
              '要点：\n'
              '1. 路由是栈结构：push 入栈，pop 出栈；\n'
              '2. 传参最简单的方式是构造函数；pop(result) 可带回结果；\n'
              '3. 大型应用建议用命名路由或 go_router（见中级 05）。',
            ),
          ],
        ),
      ),
    );
  }
}

/// 详情页：通过构造函数接收参数，这是最简单可靠的传参方式。
class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.itemId, required this.title});

  final int itemId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('详情页')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('收到的参数：itemId=$itemId, title=$title'),
            const SizedBox(height: 16),
            FilledButton(
              // pop 出栈，返回上一页
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('pop 返回'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 选择页：点击任意一项后 pop 并把该项作为结果带回上一页。
class _PickerPage extends StatelessWidget {
  const _PickerPage();

  @override
  Widget build(BuildContext context) {
    const options = ['苹果', '香蕉', '橙子'];
    return Scaffold(
      appBar: AppBar(title: const Text('挑一个水果')),
      body: ListView(
        children: [
          for (final o in options)
            ListTile(
              title: Text(o),
              // pop(result)：泛型参数就是 await push<T> 拿到的值
              onTap: () => Navigator.of(context).pop(o),
            ),
        ],
      ),
    );
  }
}

/// 命名路由演示：用一个嵌套 Navigator 注册路由表，展示 onGenerateRoute 思路。
class _NamedRouteDemo extends StatelessWidget {
  const _NamedRouteDemo();

  @override
  Widget build(BuildContext context) {
    // 嵌套 Navigator：不影响外层 App 的路由栈，演示更纯粹
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // settings.name 是路由名；真实项目还可以读 settings.arguments 传参
        final Widget page = switch (settings.name) {
          '/about' => const _NamedAbout(),
          _ => const _NamedHome(), // '/' 与未知名称都回退到首页
        };
        return MaterialPageRoute<void>(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }
}

class _NamedHome extends StatelessWidget {
  const _NamedHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('命名路由 / 首页'),
        // ⚠️ 注意：这是嵌套 Navigator 的首页，自动返回按钮不会出现；
        // 用 rootNavigator 找到外层导航器来退出整个演示页。
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ),
      body: Center(
        child: FilledButton(
          // pushNamed：用字符串路由名跳转
          onPressed: () => Navigator.of(context).pushNamed('/about'),
          child: const Text('pushNamed("/about")'),
        ),
      ),
    );
  }
}

class _NamedAbout extends StatelessWidget {
  const _NamedAbout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('命名路由 /about')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('返回'),
        ),
      ),
    );
  }
}
