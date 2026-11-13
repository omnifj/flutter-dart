# flutter-dart：Flutter 渐进式学习项目

一个**开箱即跑**的 Flutter / Dart 学习项目：30 个可交互示例，按「初级 → 中级 → 高级」三个阶段组织，每个文件都配有详细中文注释和对应文档。

- **Flutter 3.x（stable）/ Dart 3.x**，空安全强制开启
- **Material 3** 组件（经由官方 `material_ui` 包），无废弃 API
- **零业务第三方依赖**：仅使用 `provider`、`go_router` 两个官方推荐包（版本已在 pubspec.yaml 中精确锁定），其余示例只用 SDK 自带能力
- 每个示例是一个**独立可交互**的 Widget，由首页导航统一加载

## 学习路径

```
01_basics（初级）       → 02_intermediate（中级）      → 03_advanced（高级）
Dart 语法与 Widget 基础    状态管理 / 动画 / 路由 / 网络    架构 / 并发 / 绘制 / 性能
```

建议按顺序学习；每个阶段对应一份文档：[docs/01-basics.md](docs/01-basics.md)、[docs/02-intermediate.md](docs/02-intermediate.md)、[docs/03-advanced.md](docs/03-advanced.md)，文档与 `lib/` 下文件一一对应。

## 目录结构

```
flutter-dart/
├── pubspec.yaml                  # 依赖声明（仅 provider / go_router 两个第三方包）
├── analysis_options.yaml         # 静态分析配置（仅用内置 lint 规则）
├── README.md
├── .gitignore
├── lib/
│   ├── main.dart                 # 统一入口：抽屉/列表导航到全部 30 个示例
│   ├── 01_basics/                # 初级：Dart 与 Widget 基础（10 个示例）
│   ├── 02_intermediate/          # 中级：状态管理、动画、路由、网络（10 个示例）
│   └── 03_advanced/              # 高级：架构、并发、平台通道、性能（10 个示例）
├── test/
│   ├── unit/counter_test.dart    # 纯 Dart 单元测试示例
│   └── widget/counter_widget_test.dart  # Widget 测试示例
└── docs/                         # 三个阶段的学习文档
```

## 运行步骤

```bash
flutter doctor          # 1. 确认环境可用
flutter pub get         # 2. 拉取依赖（provider / go_router）
flutter run             # 3. 启动应用
```

## 如何切换示例

启动后进入首页（AppBar 标题为「Flutter 学习示例」）：

1. 首页列表按阶段分组展示全部 30 个示例，点击任意条目即可进入；
2. 也可以点击左上角菜单打开抽屉，同样按阶段选择示例；
3. 每个示例页面自带操作说明，可反复交互。

## 常用命令

```bash
dart format .                          # 统一格式化代码
dart format --set-exit-if-changed .    # CI 校验：有未格式化文件则失败
flutter analyze                        # 静态分析：应无 warning / error
flutter test                           # 运行 test/ 下的单元测试与 Widget 测试
```

## 依赖说明

| 包 | 版本 | 用途 | 使用位置 |
| --- | --- | --- | --- |
| material_ui | 1.11.0 | Flutter 官方 Material 组件库（Flutter 3.47+ 起从 SDK 拆分为第一方独立包，替代已废弃的 `package:flutter/material.dart`） | 全部示例 |
| provider | 6.1.5+1 | 官方推荐的依赖注入 + 状态共享方案（第三方） | `lib/02_intermediate/02_provider.dart`、`lib/03_advanced/10_real_world_app.dart` |
| go_router | 18.1.4 | 官方推荐的声明式路由方案（第三方） | `lib/02_intermediate/05_go_router.dart` |

除 material_ui（Flutter 团队官方组件库）与 provider / go_router 外，项目不使用任何第三方依赖；网络请求示例用 `dart:io` 的 `HttpClient` 实现，并发示例用 `dart:isolate`，JSON 解析用 `dart:convert`。
