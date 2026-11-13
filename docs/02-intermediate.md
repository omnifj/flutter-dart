# 中级阶段：状态管理、动画、路由与网络

> 对应目录：`lib/02_intermediate/`，共 10 个可交互示例（其中 10 号含配套测试讲解文件）。

## 一、本阶段学习目标

1. 掌握 ChangeNotifier 与 Provider 两种状态管理思路，理解「数据与 UI 分离」。
2. 掌握隐式动画与显式动画的适用场景，能独立写出平滑动画。
3. 掌握声明式路由 go_router：路由表、路径参数、登录重定向、ShellRoute。
4. 掌握网络请求、JSON 序列化与表单校验这三大业务基本功。
5. 入门 Widget 测试，理解可测试性对代码结构的要求。

## 二、环境准备与运行方式

```bash
flutter doctor
flutter pub get        # 会拉取 provider 与 go_router（仅此两个第三方包）
flutter run            # 首页 →「中级」分组选择示例
flutter test           # 运行 test/ 下的单元测试与 Widget 测试
```

## 三、文件清单

| 文件名 | 主题 | 核心知识点 | 建议阅读顺序 |
| --- | --- | --- | --- |
| 01_change_notifier.dart | 手动状态管理 | ChangeNotifier、notifyListeners、ListenableBuilder | 1 |
| 02_provider.dart | 跨组件共享状态 | ChangeNotifierProvider、read/watch/select | 2 |
| 03_implicit_animations.dart | 隐式动画 | AnimatedContainer/Opacity/Switcher、Curve | 3 |
| 04_explicit_animations.dart | 显式动画 | AnimationController、Tween、vsync、状态监听 | 4 |
| 05_go_router.dart | 声明式路由 | 路由表、路径参数、redirect、ShellRoute | 5 |
| 06_http_requests.dart | 网络请求 | HttpClient、FutureBuilder 三态、超时与取消 | 6 |
| 07_json_serialization.dart | JSON 序列化 | jsonDecode/Encode、fromJson/toJson、嵌套模型 | 7 |
| 08_forms_validation.dart | 表单校验 | Form、GlobalKey、validator、焦点流转 | 8 |
| 09_theme_responsive.dart | 主题与响应式 | ThemeData、Material 3 配色、LayoutBuilder、断点 | 9 |
| 10_widget_test.dart | 测试被测对象 | Key 定位、可测试性写法 | 10 |
| 10_widget_test_test.dart | 测试写法精讲 | testWidgets、WidgetTester、find 断言 | 10（配套阅读） |

## 四、逐文件详解

### 01_change_notifier.dart —— 手动状态管理

- **带你认识**：把购物车状态抽成纯 Dart 类 `CartModel`，UI 用 `ListenableBuilder` 订阅。
- **运行后操作**：点「加入购物车」观察徽标与列表同步刷新；删除单项、清空。
- **关键代码**：`notifyListeners()` —— 数据变化后主动广播；没有它，订阅者不会重建。
- **常见坑**：
  1. 忘记 `cart.dispose()`，监听器泄漏。
  2. 直接暴露可变 List 让外部绕过 notifyListeners 改数据，UI 不刷新且状态失控——所以 `items` 返回 `List.unmodifiable`。
- **动手练习**：给 CartModel 加 `totalPrice`（商品带价格），在徽标旁显示总价。

### 02_provider.dart —— Provider 跨组件共享状态

- **带你认识**：`ChangeNotifierProvider` 在树上注入状态；`read`（不监听，用于事件）、`watch`（监听整体）、`select`（监听单字段）。
- **运行后操作**：切步长、点「按步长增加」，打开控制台观察 `_CountDisplay` / `_StepPicker` 的重建日志——改步长只重建步长区。
- **关键代码**：`context.select<CounterModel, int>((m) => m.count)` —— 精准订阅是 Provider 减少重建的核心武器。
- **常见坑**：
  1. 在 `build` 里用 `read` 读要展示的数据，数据变了界面不更新。
  2. Provider 只能从其**下游** context 读取，别把 Provider 建在用的页面同一层。
- **动手练习**：新增 `decrement` 方法和一个按钮，验证 select 订阅依然精准。

### 03_implicit_animations.dart —— 隐式动画

- **带你认识**：AnimatedContainer、AnimatedOpacity、AnimatedSwitcher；触发条件是「传给它的值变了」。
- **运行后操作**：点「随机变形」看色块平滑过渡；开关控制 FlutterLogo 淡入淡出；点「下一页」看文字交叉淡变。
- **关键代码**：`AnimatedSwitcher(child: Text(..., key: ValueKey(_page)))` —— Switcher 靠 key 识别新旧内容，不给 key 不播动画。
- **常见坑**：
  1. AnimatedOpacity 为 0 时子树仍占位，只是不可见；想不占位换 AnimatedSwitcher。
  2. 把 duration 设得过长（>1s）会让界面显得“卡”，常规反馈动画 200~500ms。
- **动手练习**：用 AnimatedAlign 让一个小球在两个角之间往返。

### 04_explicit_animations.dart —— 显式动画

- **带你认识**：AnimationController（+ vsync）、Tween 值域映射、CurvedAnimation 缓动、状态监听。
- **运行后操作**：依次点 播放/倒放/循环呼吸/停止/复位，观察球体缩放变色与底部状态文案。
- **关键代码**：`SingleTickerProviderStateMixin` 提供 vsync；`dispose` 里必须 `_controller.dispose()`。
- **常见坑**：
  1. Controller 不 dispose → Ticker 持续回调，泄漏且耗电。
  2. 一个 State 里多个 Controller 却用了 SingleTickerProviderStateMixin，运行期报错；改用 TickerProviderStateMixin。
- **动手练习**：把曲线换成 `Curves.bounceOut`，观察节奏变化；再加一个 Tween 控制透明度。

### 05_go_router.dart —— 声明式路由

- **带你认识**：集中式路由表、`:id` 路径参数、`context.go/push`、`redirect` 登录守卫、`ShellRoute` 常驻底栏。
- **运行后操作**：从首页尝试直达 `/admin`（被重定向到登录页）→ 一键登录 → 再进 `/admin`；进入 ShellRoute 演示切换底部 Tab。
- **关键代码**：`redirect` 返回 null 放行、返回路径改道；`refreshListenable` 让登录态变化时自动重新评估。
- **常见坑**：
  1. 在 redirect 里写死循环（如未登录页本身又被重定向）。
  2. `go` 是替换式导航（无返回栈），需要可返回时用 `push`。
- **动手练习**：新增 `/settings` 路由并加进首页按钮；给 `/detail/:id` 增加非法 id 的兜底页。

### 06_http_requests.dart —— 网络请求

- **带你认识**：用 SDK 自带 `HttpClient` 发 GET/POST；`FutureBuilder` 管理 空闲/加载/错误/成功 界面；超时与取消。
- **运行后操作**：点「GET 帖子」看真实网络数据；「POST 创建」看服务器回显；请求中点「取消请求」。
- **关键代码**：`client.connectionTimeout = const Duration(seconds: 8)` + `finally { client.close(); }` —— 超时防卡死，finally 保释放。
- **常见坑**：
  1. Dart 的 Future 不可取消，取消请求要关闭底层连接（`close(force: true)`）并让 UI 复位。
  2. 未处理 `hasError` 分支，弱网下用户只能看到永远转圈。
- **动手练习**：给 GET 请求加重试按钮（失败后显示）；把帖子标题渲染成 ListTile 列表。

### 07_json_serialization.dart —— JSON 序列化

- **带你认识**：`jsonDecode/jsonEncode`、手写 `fromJson/toJson`、嵌套模型分层解析、默认值兜底。
- **运行后操作**：点「jsonDecode → 对象」看结构化展示；点「对象 → jsonEncode」看编码回带缩进的 JSON。
- **关键代码**：`(json['id'] as num).toInt()` —— JSON 数字可能是 int/double，用 num 中转最稳。
- **常见坑**：
  1. 直接 `json['address']['city']` 链式取 dynamic，字段改名时运行期才崩；fromJson 让错误前移。
  2. 字段缺失不给默认值，空安全下直接抛 TypeError。
- **动手练习**：给 User 加 `List<String> tags` 字段，完成其 fromJson/toJson。

### 08_forms_validation.dart —— 表单与校验

- **带你认识**：`Form + GlobalKey<FormState>` 统一校验、`validator` 返回错误文案、`onSaved` 收集值、FocusNode 焦点流转。
- **运行后操作**：留空直接提交看全部报错；输入合法信息后提交看 SnackBar；「重置」一键清空。
- **关键代码**：`autovalidateMode: AutovalidateMode.onUserInteraction` —— 交互后实时校验，体验远好于提交时才报错。
- **常见坑**：
  1. 忘记 `formKey.currentState!.save()`，校验通过了值却没收集。
  2. validator 里做耗时操作（如网络请求）会卡输入——耗时校验应放提交时。
- **动手练习**：加「确认密码」字段，validator 校验两次输入一致（提示：用 TextEditingController）。

### 09_theme_responsive.dart —— 主题与响应式

- **带你认识**：`colorSchemeSeed` 派生 Material 3 配色、局部 Theme 覆盖、MediaQuery 与 LayoutBuilder、600dp 断点。
- **运行后操作**：切换深色模式、换种子色看整套配色联动变化；调整窗口宽度（或旋转屏幕）看单栏/双栏切换。
- **关键代码**：`LayoutBuilder` 用父级约束决定布局，比 MediaQuery 更适合可复用组件。
- **常见坑**：
  1. 在 Theme 同一层用 `Theme.of(context)` 拿到的是旧主题，要用 Builder 下沉 context。
  2. 写死颜色（`Colors.blue`）导致深色模式下对比度失控，应使用 ColorScheme 角色色。
- **动手练习**：把断点改成 840dp（Material 中屏断点），并增加三栏布局分支。

### 10_widget_test.dart + 10_widget_test_test.dart —— Widget 测试

- **带你认识**：如何写可测试的 Widget（显式 Key），以及 testWidgets 的四步流程：pumpWidget → find → tap/pump → expect。
- **运行后操作**：App 内操作计数器；命令行 `flutter test` 看 3 个用例通过。
- **关键代码**：`await tester.tap(find.byKey(const Key('increment-btn'))); await tester.pump();` —— 点击后必须 pump 一帧才能断言新界面。
- **常见坑**：
  1. 断言前忘记 `pump()`，界面还是旧状态。
  2. 有动画/定时器的页面用 `pumpAndSettle()`，否则帧没走完断言失败。
- **动手练习**：给 09 号示例写一个测试：点击深色开关后验证 `Theme.of(...).brightness` 变暗。

## 五、本阶段小结与进阶条件

你已掌握状态管理、动画、路由、网络、JSON、表单、主题与测试——足以写出完整的业务 App。**进入高级的条件**（自评）：

- 能解释 read/watch/select 的差异并说清何时用哪个；
- 能为一个表单页写出校验逻辑和对应 Widget 测试；
- 能用 redirect 实现登录守卫。

## 六、自测题（附答案）

1. **ChangeNotifier 里改了数据但 UI 没刷新，最可能的原因？**
   答：忘了调用 `notifyListeners()`；或 UI 侧没有用 ListenableBuilder/watch 订阅。
2. **`context.read` 和 `context.watch` 的区别？**
   答：read 只取引用不监听（用于事件回调）；watch 订阅变化，数据变则重建（只用在 build 里）。
3. **AnimatedSwitcher 不播动画，最常见的原因？**
   答：新旧 child 同类型且没有不同的 key，Switcher 以为是同一个 Widget；给 child 加 `ValueKey`。
4. **FutureBuilder 的 snapshot 有哪几种关键状态要处理？**
   答：waiting（加载中）、hasError（出错）、hasData 且非空（成功）、空数据态；生产代码四者都要有 UI。
5. **为什么推荐用 Key 而不是 find.text 定位测试目标？**
   答：文案属于 UI 表现层，改文案/多语言时测试会连带失败；Key 是稳定的测试契约。
