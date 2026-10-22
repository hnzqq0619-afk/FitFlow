# 实施说明

## 数据流

资料填写／编辑 → UserProfile 校验 → 用户同意发送资料 → Gemini REST → AIWorkoutResponse → PlanValidator → WeeklyPlan → PlanRepository 原子保存 → 复用饮食与训练卡片。

先保存资料、暂不使用 AI 的路径不需要密钥或网络。AI 请求失败不会进入一个伪装为成功的计划，也不会替换已有计划。

## 模型与兼容性

| 文件 | 职责 |
| --- | --- |
| Model/UserProfile.swift | 身体资料、目标和偏好；默认不同意上传；兼容旧字段缺失 |
| Model/MacroGoals.swift | 用户填写的每日目标及数值校验 |
| Model/AIWorkoutResponse.swift | 网络和旧存档 DTO；原有 MealPlan 更名为 AIMealPlanDTO，避免同名冲突 |
| Model/MealPlan.swift、MealPlanDay.swift | 带具体日期、时区和目标的饮食计划 |
| Model/WorkoutPlan.swift、WorkoutPlanDay.swift | 训练、休息日与时长 |
| Model/WeeklyPlan.swift | 一次生成的饮食与训练组合、资料快照、版本；适配原有页面 |
| Model/WeightEntry.swift | 体重、训练完成记录与进度计算 |

WeeklyPlan.id 是同一次生成的共同标识。计划、天、餐食和动作的 ID 一起保存，不再每次打开生成新 ID。日期按日历递增，不按固定 24 小时相加，避免夏令时造成错日。时区保存在计划中。

AI 响应要求 day_index=1...7 和明确日期；不按返回数组顺序推断。新的饮食计划验证三餐、外卖数量、营养合计；运动计划验证训练天数、休息日与时长。数值校验只检查一致性，不证明真实营养或健康适用性。

## 存储

设备应用目录 Application Support/FitFlow/archive.json 包含 schemaVersion、profile、initialWeight、plans、currentPlanID、weights、completions 和可选 legacyPlan。

先编码并原子写入成功，再发布新内存状态。读取失败或版本不兼容时停止写入，保护原文件。iOS 写入使用设备文件保护；没有添加云同步或自动导出。

首次启动且不存在新存档时，会尝试读取原 UserDefaults 的 SavedWorkoutPlan；读取后保存稳定 ID，仍保留原数据。旧计划没有日期和资料，不转换成有虚构日期的新周计划。

原 CompletedWorkouts 使用有碰撞的整数 ID，无法可靠关联到新计划。本版保留其原数据，不自动映射为新的完成记录。HasSeenDashboard 不再决定首次启动流程。

## 页面与依赖

FitFlowApp 将 PlanRepository、HealthManager 和 TrackingManager 注册为共享实例。页面通过 ObservableObject 观察健康和完成状态，避免只读取一次注入对象而不刷新。

首页可以编辑资料、选择新计划开始日期、重试生成、切换历史计划和进入体重页。首次引导始终允许手填，并仅在明确点击时从健康数据补充空字段。

## 这一版没有实现的功能

- 真实外卖平台连接、下单或实时营养数据库。
- 实际饮食摄入日志、替换餐重新计算和食物识别。
- 根据周复盘自动推算热量目标或自动调整下一周。
- 健康体重历史的批量导入和写回 Apple 健康。
- 后端代理、账户、云同步、App Store／TestFlight 发布。
- 正式 App 图标及全部语言的完整界面翻译；新增流程主要面向中文。

## 下一步

先在 macOS 运行核心测试和模拟器构建，修复真实日志中出现的问题；之后在 iPhone 验证健康授权、钥匙串、持久保存和中文输入。完成这些验证后，再增加实际饮食日志和每周复盘。
