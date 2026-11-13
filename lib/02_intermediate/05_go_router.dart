// ============================================================
// 文件：05_go_router.dart
// 阶段：中级
// 主题：GoRouter 声明式路由（路由表 / 路径参数 / 重定向 / ShellRoute）
// 学习目标：
//   1. 掌握用路由表集中声明页面，替代分散的 Navigator.push
//   2. 掌握路径参数 :id 与 context.go / context.push
//   3. 掌握 redirect 登录守卫与 ShellRoute 常驻底栏
// 运行方式：flutter run 后，在首页选择“05 GoRouter 声明式路由”
// 预计阅读时间：18 分钟
// ============================================================
import 'package:go_router/go_router.dart'; // 本文件是允许使用第三方包的示例之一
import 'package:material_ui/material_ui.dart';

/// 模拟登录状态：ValueNotifier 变化时通知 GoRouter 重新评估 redirect。
final ValueNotifier<bool> _loggedIn = ValueNotifier(false);

/// 路由表：页面与 URL 的映射集中在这里，一目了然。
final GoRouter _router = GoRouter(
  initialLocation: '/',
  // redirect 在每次导航前执行：返回 null 放行，返回路径则改道。
  // 这是实现“登录守卫”的标准位置。
  redirect: (context, state) {
    final goingAdmin = state.uri.path == '/admin';
    if (goingAdmin && !_loggedIn.value) return '/login'; // 未登录去登录页
    return null;
  },
  // 登录态变化时重新跑 redirect（比如刚登录完，/admin 就放行了）
  refreshListenable: _loggedIn,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _GoHome()),
    // 路径参数：/detail/7 里的 7 会被解析进 pathParameters
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) =>
          _GoDetail(id: state.pathParameters['id'] ?? '?'),
    ),
    GoRoute(path: '/login', builder: (context, state) => const _GoLogin()),
    GoRoute(path: '/admin', builder: (context, state) => const _GoAdmin()),
    // ShellRoute：多个子路由共享同一副“骨架”（这里是底栏），切换 tab 时骨架不重建
    ShellRoute(
      builder: (context, state, child) => _GoShell(child: child),
      routes: [
        GoRoute(
          path: '/tabs/news',
          builder: (context, state) => const _TabPage('新闻'),
        ),
        GoRoute(
          path: '/tabs/video',
          builder: (context, state) => const _TabPage('视频'),
        ),
      ],
    ),
  ],
);

/// 示例入口：内嵌一个 MaterialApp.router，与主应用互不干扰。
class GoRouterExample extends StatelessWidget {
  const GoRouterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GoRouter 演示',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      routerConfig: _router,
    );
  }
}

/// 首页：演示 context.go / push 与参数跳转。
class _GoHome extends StatelessWidget {
  const _GoHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoRouter 首页'),
        // 关闭整个演示：操作外层（根）导航器
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            // context.go：替换式跳转，适合“导航到某页”
            onPressed: () => context.go('/detail/7'),
            child: const Text('go 到 /detail/7（路径参数）'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            // context.push：压栈式跳转，返回键可退回
            onPressed: () => context.push('/detail/99'),
            child: const Text('push 到 /detail/99'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go('/admin'),
            child: const Text('去 /admin（会被重定向到登录页）'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go('/tabs/news'),
            child: const Text('进入 ShellRoute 底栏布局'),
          ),
        ],
      ),
    );
  }
}

/// 详情页：展示从路径参数解析出的 id。
class _GoDetail extends StatelessWidget {
  const _GoDetail({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('详情页 id=$id')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/'),
          child: const Text('回首页'),
        ),
      ),
    );
  }
}

/// 登录页：登录后 _loggedIn 变化 → redirect 重新评估 → 可访问 /admin。
class _GoLogin extends StatelessWidget {
  const _GoLogin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录页（重定向至此）')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            _loggedIn.value = true;
            context.go('/admin'); // 登录成功后再次访问，redirect 放行
          },
          child: const Text('一键登录并进入 /admin'),
        ),
      ),
    );
  }
}

class _GoAdmin extends StatelessWidget {
  const _GoAdmin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin 后台')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            _loggedIn.value = false; // 退出登录
            context.go('/');
          },
          child: const Text('退出登录回首页'),
        ),
      ),
    );
  }
}

/// ShellRoute 的骨架：常驻底栏 + 当前子路由内容。
class _GoShell extends StatelessWidget {
  const _GoShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 根据当前路径决定底栏选中项
    final location = GoRouterState.of(context).uri.path;
    final index = location.contains('video') ? 1 : 0;
    return Scaffold(
      appBar: AppBar(title: const Text('ShellRoute 演示')),
      body: child, // 子路由内容嵌入骨架
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            context.go(i == 0 ? '/tabs/news' : '/tabs/video'),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.article), label: '新闻'),
          NavigationDestination(icon: Icon(Icons.video_library), label: '视频'),
        ],
      ),
    );
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$name Tab 内容（底栏在切换时不重建）'));
  }
}
