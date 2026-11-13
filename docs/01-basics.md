# 初级阶段：Dart 与 Widget 基础

> 对应目录：`lib/01_basics/`，共 10 个可交互示例。

## 一、本阶段学习目标

1. 掌握 Dart 语言核心语法：变量、函数、集合、空安全。
2. 理解 Flutter「一切皆 Widget」与 Widget 树的构建方式。
3. 分清 StatelessWidget 与 StatefulWidget，掌握 `setState` 驱动界面更新。
4. 掌握常用布局：Row / Column / Stack / Container，以及 ListView / GridView。
5. 掌握页面导航（push / pop / 传参 / 返回值）。

## 二、环境准备与运行方式

```bash
flutter doctor        # 检查环境，确保没有红色 ✗
flutter pub get       # 拉取依赖
flutter run           # 启动应用（需已连接设备或模拟器）
```

启动后进入首页「Flutter 学习示例」，在列表或左上角抽屉中选择「初级」分组下的任意示例即可进入；每个示例内都有操作说明。

## 三、文件清单

| 文件名 | 主题 | 核心知识点 | 建议阅读顺序 |
| --- | --- | --- | --- |
| 01_hello_world.dart | 第一个页面 | runApp/MaterialApp/Scaffold、热重载 | 1 |
| 02_dart_basics.dart | Dart 语法 | var/final/const、函数、List/Map/Set、插值 | 2 |
| 03_null_safety.dart | 空安全 | `?`、`!`、`??`、`??=`、late、条件渲染 | 3 |
| 04_stateless_widget.dart | 无状态组件 | build、Widget 树、const 性能意义 | 4 |
| 05_stateful_widget.dart | 有状态组件 | State、setState、initState/dispose | 5 |
| 06_layout_row_column.dart | 线性布局 | 主轴/交叉轴对齐、Expanded/Flexible | 6 |
| 07_container_stack.dart | 容器与层叠 | padding/margin/decoration、Stack/Positioned | 7 |
| 08_listview_gridview.dart | 滚动列表 | builder 惰性构建、GridView、滚动性能 | 8 |
| 09_textfield_input.dart | 文本输入 | TextEditingController、onChanged/onSubmitted、FocusNode | 9 |
| 10_navigation.dart | 页面导航 | push/pop、传参、pop(result)、命名路由 | 10 |

## 四、逐文件详解

### 01_hello_world.dart —— 第一个页面与热重载

- **带你认识**：`runApp`（在 main.dart）、MaterialApp、Scaffold、Center、Text 如何拼出一个页面。
- **运行后操作**：点击「点我切换文字」观察文字与颜色变化；然后保持 App 运行，修改源码中的字符串并保存，体验热重载「秒级更新且不丢状态」。
- **关键代码**：`setState(() => _excited = !_excited)` —— 数据变化必须包在 `setState` 里，框架才会重建界面。
- **常见坑**：
  1. 直接改字段不调用 `setState`，界面不会刷新。
  2. 把 `main()` 写到示例文件里会导致多个入口冲突 —— 本项目入口统一在 `lib/main.dart`。
- **动手练习**：把文字换成你的名字并热重载；再加一个按钮把颜色改成绿色。

### 02_dart_basics.dart —— Dart 语言基础

- **带你认识**：`var` 类型推断、`final`（运行期一次赋值）、`const`（编译期常量）；命名参数与默认值；List/Map/Set；字符串插值 `$a` 与 `${a+b}`。
- **运行后操作**：依次点击「变量 / 函数 / 集合 / 插值」按钮，观察下方日志输出。
- **关键代码**：`final widgets = ['基础', if (list.length > 2) '进阶', ...set.take(1)]` —— 集合里可写条件与展开运算符，这也是 Flutter 构建 Widget 列表的常用手法。
- **常见坑**：
  1. 对 `final` 变量二次赋值会编译报错。
  2. `const` 只能接收编译期常量，`const DateTime.now()` 是错误写法。
- **动手练习**：写一个带默认参数的函数 `int add(int a, [int b = 10])`，在日志里验证 `add(1)` 与 `add(1, 2)`。

### 03_null_safety.dart —— 空安全

- **带你认识**：`String?` 可空类型；`?.` 安全调用、`??` 默认值、`??=` 懒初始化、`!` 非空断言、`late` 延迟初始化。
- **运行后操作**：点击「加载成功 / 加载失败 / ??=」三个按钮，观察昵称与长度的展示变化。
- **关键代码**：`final displayName = _nickname ?? '（未设置昵称）';` —— 可空字段在构建 UI 前转成非空值，是空安全时代的标准姿势。
- **常见坑**：
  1. 对可空值滥用 `!`，数据一旦为 null 直接红屏崩溃。
  2. `late` 变量在赋值前被读取会抛 `LateInitializationError`。
- **动手练习**：把昵称改成 `String? _nickname;` 字段的输入框版本：输入为空时显示「（未设置昵称）」。

### 04_stateless_widget.dart —— StatelessWidget 与 const

- **带你认识**：StatelessWidget 的 `build` 方法、Widget 树是「不可变配置」、const 构造函数的复用价值。
- **运行后操作**：观察两张由同一个 `_ProfileCard` 类渲染出的不同卡片。
- **关键代码**：`const _ProfileCard(...)` —— const Widget 在编译期创建，重建时 Flutter 直接复用并跳过整棵子树。
- **常见坑**：
  1. 在 StatelessWidget 里声明可变字段（非 final）会直接编译报错——可变状态属于 StatefulWidget。
  2. 能加 const 却不加，会白白增加重建成本（分析器也会提示）。
- **动手练习**：给 `_ProfileCard` 增加一个 `String email` 字段并在卡片上显示。

### 05_stateful_widget.dart —— StatefulWidget 与 setState

- **带你认识**：StatefulWidget + State 的两段式结构、`setState` 触发重建、`initState`/`dispose` 生命周期。
- **运行后操作**：点击「+1」与「清零」，观察下方日志中每次 setState 的记录；退出页面看控制台 dispose 输出。
- **关键代码**：`setState(() { _count++; })` —— 状态变更必须在 setState 闭包内完成，重建是「只重建当前 Widget 子树」而非整个 App。
- **常见坑**：
  1. 在 `dispose` 里调用 `setState` 会抛异常。
  2. 在 `build` 里修改状态（如 `++_count`）会造成无限重建循环。
- **动手练习**：增加一个「-1」按钮，并保证计数不会小于 0。

### 06_layout_row_column.dart —— 线性布局

- **带你认识**：MainAxisAlignment / CrossAxisAlignment 的全部取值、Expanded 与 Flexible 的差异、SizedBox 间距。
- **运行后操作**：用两组 ChoiceChip 切换主轴/交叉轴对齐，观察顶部三个色块的位置变化；下方对比 Expanded 的 flex 比例分配。
- **关键代码**：`Expanded(flex: 2, child: ...)` —— Expanded 强制子项按份数瓜分剩余空间；Flexible 则允许子项小于分得的空间。
- **常见坑**：
  1. 在 Column 里放 ListView/Expanded 之外的无限高 Widget 会报「Vertical viewport was given unbounded height」类溢出错误。
  2. Row 里文字过长不换行会右侧黄黑条溢出，用 Expanded/Flexible 包一层即可。
- **动手练习**：把实验画布换成 Column，验证主轴方向随之变为纵向。

### 07_container_stack.dart —— Container 与 Stack

- **带你认识**：Container 的 `margin`（外间距）/`padding`（内边距）/`decoration`（渐变、圆角、阴影）；Stack + Positioned 层叠定位。
- **运行后操作**：拖动滑块实时改变卡片圆角；用开关控制 NEW 角标的显示。
- **关键代码**：`Positioned(top: 0, right: 0, child: Chip(...))` —— Stack 的非定位子项默认堆在左上角，自由摆放必须包 Positioned 或 Align。
- **常见坑**：
  1. `Container` 同时设置 `color` 和 `decoration.color` 会断言失败——颜色只能写一处。
  2. Positioned 只给 `top/right` 时子项尺寸由自身决定；想拉伸需同时给 `left/right`。
- **动手练习**：在卡片左下角再加一个 Positioned 的「有效期」文本。

### 08_listview_gridview.dart —— 滚动列表

- **带你认识**：`ListView.builder` / `GridView.builder` 的 itemBuilder 惰性构建机制；运行时切换两种布局。
- **运行后操作**：用 SegmentedButton 切换列表/网格，快速滑动 1000 条数据感受流畅度；点击列表项弹出 SnackBar。
- **关键代码**：`itemBuilder: (context, index) => ...` —— 只有即将进入屏幕的条目才会被构建，这是大列表流畅的根本原因。
- **常见坑**：
  1. 用 `ListView(children: [...1000 个])` 一次性构建会明显卡顿。
  2. 在 Column 中直接放 ListView 必须包 Expanded，否则高度无界报错。
- **动手练习**：把网格改成 4 列，并给网格项加上不同的背景色（按 index 取色）。

### 09_textfield_input.dart —— 文本输入

- **带你认识**：TextEditingController 读写输入、onChanged（逐字符）与 onSubmitted（回车）的时机差异、FocusNode 控制焦点。
- **运行后操作**：输入文字观察实时预览；回车或点「提交」把内容加入留言列表；「收起键盘」演示主动释放焦点。
- **关键代码**：`dispose` 中 `_controller.dispose(); _focusNode.dispose();` —— 控制器持有系统资源，不释放会内存泄漏。
- **常见坑**：
  1. 忘记 dispose 控制器（分析器不报错，但属于泄漏）。
  2. 用 `onChanged` 做网络请求却不防抖，会每敲一个字发一次请求（中级网络示例再深入）。
- **动手练习**：给留言加「删除」按钮（trailing IconButton），点击后从列表移除。

### 10_navigation.dart —— 页面导航

- **带你认识**：路由栈模型、`Navigator.push/pop`、构造函数传参、`pop(result)` 带回结果、嵌套 Navigator 实现命名路由。
- **运行后操作**：依次点三个按钮：打开带参详情页 → pop 返回；打开选择页 → 选水果 → 看 SnackBar 显示返回值；进入命名路由演示体验 `pushNamed`。
- **关键代码**：`final result = await Navigator.of(context).push<String>(...)` —— await 之前页面挂起等待，pop 后恢复执行并拿到返回值。
- **常见坑**：
  1. await 之后未判 `context.mounted` 就使用 context，页面若已销毁会抛异常。
  2. 嵌套 Navigator 里点系统返回键会先弹内层路由，注意返回层级。
- **动手练习**：给 `_PickerPage` 增加一个「都不喜欢」按钮，pop 时返回 null 以外的特殊字符串并在 SnackBar 中区分显示。

## 五、本阶段小结与进阶条件

你已经掌握：Dart 基础语法与空安全、两类 Widget 与 setState、四大布局、滚动列表、输入与导航。**进入中级的条件**（自评）：

- 能不查文档写出一个带输入框和列表的 StatefulWidget 页面；
- 能解释 const 为什么能提升性能；
- 能在两个页面间双向传值。

## 六、自测题（附答案）

1. **final 和 const 的区别？**
   答：final 是运行期常量（可赋运行时计算的值，只能赋一次）；const 是编译期常量（值在编译期确定，还能触发 Widget 复用优化）。
2. **`String? name` 与 `String name` 有何不同？下面代码哪行报错：`print(name.length)`？**
   答：`String?` 可为 null，直接访问 `.length` 编译报错，必须 `name?.length` 或先判空；非空 `String` 可直接访问。
3. **为什么在 Column 里放 ListView 会报错，怎么解决？**
   答：Column 给子项的高度约束是无界的，ListView 需要确定高度；用 Expanded（或固定高度）包裹。
4. **setState 做了什么？为什么直接改字段不刷新界面？**
   答：setState 把当前 State 标记为 dirty 并调度一次 build；在 setState 之外改字段，框架不知道数据变了，不会重建。
5. **如何把数据从详情页带回列表页？**
   答：详情页 `Navigator.pop(context, result)`，列表页 `final result = await Navigator.push(...)`，注意判 `context.mounted`。
