# 用全能签安装到 iPhone

需要 iOS 18.6 或更高版本、已安装的全能签，以及其中可用的签名证书和描述文件。这里的 IPA 是原生 iPhone 版本，尚未使用安装所需的个人证书签名。

## 下载正确文件

1. 登录 GitHub，打开 [Actions](https://github.com/hnzqq0619-afk/FitFlow/actions)。
2. 打开最新成功的 iOS checks 运行。
3. 在 Artifacts 中下载 FitFlow-iPhone-unsigned-开头的产物。
4. 解压 GitHub 下载的外层 ZIP，取出 FitFlow-unsigned.ipa。不要选择 FitFlow-simulator.zip，也不需要再解压 IPA 本身。

每次运行的产物保留七天；过期后可以在 GitHub Actions 重新运行工作流。

## 导入、签名和安装

全能签不同版本的菜单名称可能不同，以下按通用流程操作：

1. 将 FitFlow-unsigned.ipa 保存到 iPhone 的「文件」App；通过分享菜单打开全能签，或在全能签内导入这个文件。
2. 在全能签中选中 FitFlow，进入签名操作。
3. 选择你已有的有效证书和描述文件。一般分别对应 .p12 与 .mobileprovision 文件；已在全能签中配置好的，直接选择即可。
4. Bundle Identifier 默认是 com.personal.fitflow。若描述文件绑定了特定 App ID，需让签名后的标识与描述文件匹配。后续更新尽量保持相同标识。
5. 执行签名，成功后选择安装，按 iOS 提示完成。
6. 若出现「不受信任的开发者」，根据系统提示到「设置 → 通用 → VPN 与设备管理」处理对应开发者信任。
7. 如果系统明确要求开发者模式，再到「设置 → 隐私与安全性 → 开发者模式」开启，并按提示重启确认。该要求取决于签名方式。

证书、证书密码和描述文件留在你自己的签名工具里，不需要上传 GitHub。

## 首次打开

- 可先手填资料、保存并记录体重，无需连接 Apple 健康。
- 如需 AI 计划，在「AI 设置」填写自己的 Gemini API Key，并在资料中同意发送生成计划所需的数据。
- HealthKit 需要签名和描述文件支持对应能力；能完成签名不代表该权限一定可用。遇到权限不匹配或连接健康失败，应核对描述文件，不要把编译成功当成真机验证成功。

## 本产物验证范围

CI 使用 iphoneos SDK 编译 Release、arm64 App，检查 IPA 的 Payload 结构、Info.plist 的 iPhoneOS 平台标识，以及 Mach-O 的 PLATFORM_IOS 标记，防止把模拟器 App 当作真机包。

这些检查不能验证你的证书、设备注册、安装结果或 HealthKit 读取。最终是否可安装取决于你的签名配置和设备系统。

参考：[Apple 注册设备分发说明](https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices)、[开发者模式](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)、[企业 App 信任设置](https://support.apple.com/en-us/118254)、[HealthKit 配置](https://developer.apple.com/documentation/healthkit/setting-up-healthkit)。
