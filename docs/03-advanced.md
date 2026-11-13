# 高级阶段：架构、并发、平台通道与性能

> 对应目录：`lib/03_advanced/`，共 10 个可交互示例。

## 一、本阶段学习目标

1. 掌握整洁架构的分层与依赖方向，写出可测试、可替换的业务代码。
2. 掌握 Repository、依赖注入、常见设计模式的落地方式。
3. 理解 Dart 并发模型（Isolate）与平台通道（Platform Channel）。
4. 掌握 CustomPaint 自定义绘制与 Slivers 高级滚动。
5. 建立性能优化方法论：const、RepaintBoundary、itemExtent 与 DevTools。

## 二、环境准备与运行方式

```bash
flutter doctor
flutter pub get
flutter run           # 首页 →「高级」分组选择示例
```

性能示例建议配合 DevTools：运行 `flutter run` 后按提示打开 DevTools 链接，切到 Performance 页签录制帧耗时。

## 三、文件清单

| 文件名 | 主题 | 核心知识点 | 建议阅读顺序 |
| --- | --- | --- | --- |
| 01_clean_architecture.dart | 整洁架构 | 三层划分、用例类、依赖向内 | 1 |
| 02_repository_pattern.dart | 仓库模式 | 接口与实现、数据源切换、错误映射 | 2 |
| 03_dependency_injection.dart | 依赖注入 | 构造函数注入、手写 Service Locator | 3 |
| 04_isolate.dart | 并发计算 | Isolate.run、内存隔离、UI 卡顿原理 | 4 |
| 05_platform_channel.dart | 平台通道 | MethodChannel、原生端配合、异常兜底 | 5 |
| 06_custom_paint.dart | 自定义绘制 | CustomPainter、Canvas/Paint、shouldRepaint | 6 |
| 07_slivers_advanced.dart | 高级滚动 | CustomScrollView、SliverAppBar、SliverGrid/List | 7 |
| 08_performance_optimization.dart | 性能优化 | const、RepaintBoundary、itemExtent、DevTools | 8 |
| 09_design_patterns.dart | 设计模式 | 工厂/单例/Builder/装饰器/观察者 | 9 |
| 10_real_world_app.dart | 综合实战 | Provider + 路由 + 持久化模拟 + 列表交互 | 10 |

## 四、逐文件详解

### 01_clean_architecture.dart —— 整洁架构分层

- **带你认识**：domain（实体 + 仓库接口 + 用例）、data（仓库实现）、presentation（页面）三层同文件对照，强调依赖只朝内。
- **运行后操作**：点「通过用例加载商品」，观察商品按价格升序出现——排序规则在用例里，不在 UI 里。
- **关键代码**：`class GetProductsUseCase { ... call() }` —— 一个用例一个业务动作，UI 只与用例对话。
- **常见坑**：
  1. domain 层 import 了 Flutter 包，导致业务逻辑无法在纯 Dart 环境测试。
  2. UI 直接 new 数据层实现，换数据源时大面积改代码——应依赖接口。
- **动手练习**：新增 `SearchProductsUseCase`（按关键词过滤），在页面加一个搜索框调用它。

### 02_repository_pattern.dart —— Repository 模式

- **带你认识**：`NoteRepository` 接口 + 内存/远程两实现 + `SafeNoteRepository` 装饰层做错误映射（底层异常 → 业务错误）。
- **运行后操作**：开关切换数据源；远程源有 1 秒延迟且约 30% 概率失败，多点几次看统一的业务错误提示。
- **关键代码**：`on Exception { throw const NetworkNoteError(); }` —— UI 永远只见业务错误类型。
- **常见坑**：
  1. 把 `TimeoutException` 等底层异常直接抛给 UI，各处都要认识 N 种异常。
  2. sealed class 做错误族却不穷举处理，遗漏分支不报错（用 switch 表达式可让编译器检查穷尽性）。
- **动手练习**：新增 `CacheFirstNoteRepository`：先读内存，为空再回源远程。

### 03_dependency_injection.dart —— 依赖注入

- **带你认识**：构造函数注入（首选）与手写 Service Locator（get_it 核心思路：Map<Type, Object>）。
- **运行后操作**：两个按钮分别通过 Locator 与构造函数记日志，界面实时展示两条日志流。
- **关键代码**：`T get<T>() { ... if (service == null) throw StateError(...) }` —— 未注册给明确错误，比空指针好排查。
- **常见坑**：
  1. Locator 隐藏依赖关系，类需要什么都看不出来；能构造函数注入就别用 Locator。
  2. 忘记 reset/清理，测试之间或示例之间状态互相污染。
- **动手练习**：给 ServiceLocator 加 `registerFactory<T>`（每次取都新建实例）。

### 04_isolate.dart —— Isolate 并发计算

- **带你认识**：Dart 单线程事件循环；`Isolate.run` 把 fib(38) 这类 CPU 密集任务移到 Worker 线程。
- **运行后操作**：先点「主线程计算」——滑块卡死数秒；再点「Isolate 计算」——滑块全程丝滑。这是最直观的对比。
- **关键代码**：`await Isolate.run(() => _fib(_n))` —— 入口必须是顶层/静态函数，因为 Isolate 间内存隔离、捕获不了闭包变量。
- **常见坑**：
  1. 在 Isolate 回调里操作 UI 或访问 State 字段——编译或运行期直接失败。
  2. 给几毫秒的小任务也开 Isolate，线程启动成本反而更慢；只给重任务用。
- **动手练习**：把 07 号 JSON 示例的大段解析放进 `Isolate.run`，对比界面流畅度。

### 05_platform_channel.dart —— 平台通道

- **带你认识**：MethodChannel Dart 端定义与调用；`MissingPluginException` 兜底；文件内附 Kotlin/Swift 原生实现样板。
- **运行后操作**：点「调用原生：获取电量」；在未实现原生端的项目里会看到 MissingPluginException 提示与实现指引。
- **关键代码**：`MethodChannel('com.example.flutter_dart/battery')` —— 通道名两端必须完全一致。
- **常见坑**：
  1. 通道名拼写不一致 → MissingPluginException。
  2. 原生回调里忘记 `result.success/error/notImplemented`，Dart 端 Future 永远不完成。
- **动手练习**：新增 `getDeviceModel` 方法，Dart 端与（如有的）原生端各写一半。

### 06_custom_paint.dart —— CustomPaint 自定义绘制

- **带你认识**：CustomPainter 的 `paint`/`shouldRepaint`；Canvas 画线/矩形/文字（TextPainter）；Paint 对象复用。
- **运行后操作**：点「随机换一组数据」，柱状图整体重绘。
- **关键代码**：`shouldRepaint: oldDelegate.values != values` —— 数据没变就跳过重绘。
- **常见坑**：
  1. 在 paint 里创建大对象/做网络请求——paint 每帧都可能被调用，必须轻。
  2. 忘记给 CustomPaint 设 size 或父约束，画布尺寸塌缩为 0。
- **动手练习**：给柱子加圆角（drawRRect），并在柱顶画数值（已有 TextPainter 示例可参考改样式）。

### 07_slivers_advanced.dart —— Slivers 高级滚动

- **带你认识**：CustomScrollView 组合 SliverAppBar（折叠头部）、SliverGrid、SliverList；普通 Widget 用 SliverToBoxAdapter 混入。
- **运行后操作**：上下滚动，观察头部折叠钉顶、网格与列表无缝衔接。
- **关键代码**：`SliverAppBar(pinned: true, expandedHeight: 180, flexibleSpace: ...)` —— 折叠效果三要素。
- **常见坑**：
  1. 用 SliverAppBar 同时还给 Scaffold 配 AppBar，出现两个标题栏。
  2. 把普通 Widget 直接塞进 slivers 列表——类型不匹配，编译报错，需 SliverToBoxAdapter。
- **动手练习**：给 SliverAppBar 加 `floating: true, snap: true`，对比滚动行为差异。

### 08_performance_optimization.dart —— 性能优化实践

- **带你认识**：RepaintBoundary 隔离高频动画的重绘、itemExtent 固定行高、const 行内容、build 中重复创建对象的反面教材。
- **运行后操作**：开关切换「优化写法/反面教材」，用 DevTools Performance 录制对比帧耗时（`flutter run` 后按终端提示打开 DevTools，进入 Performance → Record）。
- **关键代码**：`itemExtent: 56` —— 省掉逐行测量，滚动偏移直接乘算。
- **常见坑**：
  1. 到处乱包 RepaintBoundary——图层过多反而增加内存与合成成本，只隔离高频重绘区。
  2. 用 DevTools 时开着 debug 模式断言卡顿，性能分析请用 `flutter run --profile`。
- **动手练习**：把反面教材的 `List.generate` 移到字段缓存，用 DevTools 验证改善。

### 09_design_patterns.dart —— 常用设计模式

- **带你认识**：工厂（ShapeFactory）、单例（AppConfig）、Builder（PizzaBuilder 链式）、装饰器（Widget 逐层组合）、观察者（setState/ChangeNotifier 回顾）。
- **运行后操作**：点四个按钮看日志输出；观察装饰器演示区的四层包装效果。
- **关键代码**：`PizzaBuilder().size('大号').addTopping('蘑菇').build()` —— 链式调用的秘诀是每个方法返回 this。
- **常见坑**：
  1. 单例滥用成全局变量垃圾桶，测试无法隔离。
  2. 为简单对象硬上 Builder——字段少时直接构造函数更清晰。
- **动手练习**：用装饰器思路封装一个 `BadgeWrapper` Widget，给任意 child 右上角加红点。

### 10_real_world_app.dart —— 综合实战：待办清单

- **带你认识**：TodoStore（ChangeNotifier）+ TodoStorage 接口（内存模拟持久化）+ Provider + 路由 + Dismissible 滑动删除的完整串联。
- **运行后操作**：勾选完成（删除线）、左滑删除、右下角 FAB 新增待办；标题栏实时显示完成度。
- **关键代码**：push 新路由时用 `ChangeNotifierProvider.value` 把 Store 显式带入——新路由与原页面是兄弟节点，默认访问不到 Provider。
- **常见坑**：
  1. 以为 push 的页面能直接 read 到上一页的 Provider（继承链不跨路由），需 Provider.value 传递。
  2. 状态变更后忘了 save()，重启后数据与界面不一致。
- **动手练习**：把 InMemoryTodoStorage 换成 shared_preferences 实现（需自行加依赖），验证上层零改动。

## 五、本阶段小结

至此你已覆盖：架构分层、仓库与 DI、并发、平台互调、自定义绘制、高级滚动、性能调优、设计模式与综合实战。**毕业标准**（自评）：

- 能把一个混乱的单文件页面重构出 domain/data/presentation 三层；
- 能判断一个耗时任务该不该进 Isolate；
- 能用 DevTools 定位并修掉一个卡顿点。

## 六、自测题（附答案）

1. **为什么整洁架构要求依赖方向「只能向内」？**
   答：内层（domain）最稳定、不依赖任何框架细节；外层依赖内层使得 UI、数据库、网络都可替换而不影响业务核心。
2. **错误映射解决了什么问题？**
   答：底层异常类型五花八门（超时、解析、权限），映射成统一的业务错误族后，UI 只需处理有限的几种情况，替换数据源时 UI 不用改。
3. **为什么 Isolate 入口函数不能是闭包？**
   答：Isolate 之间不共享内存，闭包捕获的外部变量无法跨 Isolate 传递；入口必须是顶层或静态函数，参数按值传递。
4. **itemExtent 为什么能优化长列表？**
   答：固定行高让列表跳过逐行测量，滚动偏移可用乘法直接算出，快速滚动时布局成本大幅降低。
5. **什么时候用 RepaintBoundary，什么时候不用？**
   答：页面上有局部高频重绘（动画、视频、Canvas）且周边内容静态时使用，隔离重绘区域；静态页面乱用反而增加图层内存开销。
