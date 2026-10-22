# FitFlow 私人 AI 减脂助手

基于 [enginbolat/FitFlow](https://github.com/enginbolat/FitFlow) 的本地改进版，复用 SwiftUI 导航、计划卡片和详情页面。

**当前验证状态：已在 Windows 进行静态检查；尚未在 macOS/Xcode 编译、运行 XCTest、验证真机或联调真实 Gemini。** 配置了后续自动构建流程，不代表该流程已经执行成功。

## 已实现的代码

- 中文资料填写和编辑；身高、体重、年龄、目标体重、营养目标、饮食偏好、忌口、预算、外卖频率和运动条件。
- 完全手动使用：不连接 Apple 健康、不配置 AI，也能保存资料和记录体重。
- Gemini REST 请求、结构化 JSON 输出、失败提示和重试；不再依赖已弃用的 GoogleGenerativeAI Swift SDK。
- 从指定日期开始的七天饮食与每周运动；验证日期、三餐、外卖次数、训练天数、营养合计及休息日。
- 中式餐食与外卖搜索菜名、份量和点单备注。没有外卖平台接口，不提供实时门店、价格、库存或自动下单。
- 历史计划切换；按完整训练 ID 和计划日期记录完成／撤销。
- 手动体重记录、趋势图、按记录日期计算的七日平均与目标进度。
- Apple 健康可选只读接入：步数、活动消耗、运动记录、身高、体重和生日。未读取到数据显示 --，不把授权请求完成等同于读取授权。
- 本地版本化 JSON 存档、原子写入；损坏存档停止写入，原始旧数据保留。

每日营养目标由用户填写；本版不自动推算个人热量处方。所有 AI 营养值均为估算，结构验证不能保证食材、过敏判断或运动建议正确。使用前需自行核对。

## Windows 上从哪里开始

源代码可在 Windows 编辑。本地检查仅需要已经可用的 Node.js，不需要安装第三方依赖：

    node scripts/check-project.mjs

该命令检查工程语法和引用、配置、本地化键、JSON 资源及常见密钥模式，**不会编译 Swift**。

- 工程入口：FitFlow/FitFlowApp.swift
- AI 请求：FitFlow/Core/Manager/GeminiManager.swift
- 数据存储：FitFlow/Core/Manager/PlanRepository.swift
- 模型：FitFlow/Model/
- 资料页面：FitFlow/View/Profile/
- 体重页面：FitFlow/View/Progress/
- 实施说明：[docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md)
- 测试说明：[docs/TESTING.md](docs/TESTING.md)

## macOS/Xcode 上构建

- iPhone App 最低系统版本保持为 **iOS 18.6**。
- 建议使用 **Xcode 26.1 或更高版本**，与原项目工程格式相匹配。
- 项目使用自动生成的 Info.plist，不再引用缺失的 FitFlow/Info.plist。
- 用 Xcode 打开 FitFlow.xcodeproj，或执行：

    xcodebuild -project FitFlow.xcodeproj -scheme FitFlow -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

核心测试使用独立 Swift Package：

    swift test

根目录 Package.swift 只用于核心库测试；App 仍从 FitFlow.xcodeproj 构建。

GitHub Actions 配置在 .github/workflows/ios.yml：运行静态检查、核心测试和无签名模拟器构建。文件需要先提交到你自己的 GitHub 仓库才会触发；当前没有推送或执行远程构建。该流程不生成可直接安装到 iPhone 的签名包。

## 真机签名与配置

复制 Config/Local.example.xcconfig 为 Config/Local.xcconfig，填写自己的 Apple Team ID 和唯一 Bundle Identifier。Local.xcconfig 已被 Git 忽略；请不要使用原作者的开发团队配置。

真机安装需要 macOS/Xcode 或已配置签名的 macOS 构建环境，以及对应的 Apple 开发配置。模拟器构建成功不能替代真机健康权限验证。

App 图标仍是上游资源占位，需要后续补充正式图标。

## Gemini 配置与隐私

进入 App 的「AI 设置」，填写自己的 Gemini API Key。密钥保存在当前设备的 Keychain（钥匙串），不会写进源码、UserDefaults 或存档。模型名称可以在界面修改，初始值为 gemini-3.5-flash-lite；实际可用性取决于账号和服务状态。

兼容旧工程的 GEMINI_API_KEY Info 字典读取，但本版默认不往 App 包中写入密钥。不要把真实密钥、签名私钥、证书密码、健康数据或本地存档提交到 GitHub。

生成前需要开启资料中的 AI 数据使用开关。请求会发送身体资料、目标、营养目标、预算、饮食及运动偏好；不发送姓名、完整生日、原始 HealthKit 样本或体重历史。最新手动体重会作为本次生成的当前体重使用。

此私人版本由 App 直接调用 Google。钥匙串降低本地明文暴露，但不能把客户端当作服务器端密钥保险箱。分享给别人之前，建议在 GeminiServiceProtocol 后增加私人后端代理。

相关官方资料：

- [Gemini REST 接口](https://ai.google.dev/api/generate-content)
- [结构化输出](https://ai.google.dev/gemini-api/docs/structured-output)
- [模型列表](https://ai.google.dev/gemini-api/docs/models)
- [API 密钥安全](https://ai.google.dev/gemini-api/docs/api-key)

## 许可证

上游 README 声称采用 MIT，但本次下载版本没有独立 LICENSE 文件。这里没有补写或虚构作者的许可文本；正式再分发前应核实上游许可。
