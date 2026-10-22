import SwiftUI

struct AISettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var key = ""
    @State private var model = AIConfiguration.model
    @State private var message: String?
    @State private var didSave = false

    var body: some View {
        Form {
            Section {
                SecureField("输入新的 Gemini API Key", text: $key)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                Text(AIConfiguration.apiKey.isEmpty ? "尚未配置密钥" : "已配置密钥，留空可保留现有密钥")
                    .font(.caption).foregroundStyle(.secondary)
                TextField("模型名称", text: $model)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
            } header: { Text("私人 Gemini 配置") } footer: {
                Text("密钥保存在此设备的钥匙串。App 直接连接 Google，需要网络和可用额度。请使用自己的密钥；分享 App 前应改为私人后端代理。")
            }
            Button("保存设置") {
                do {
                    let normalized = model.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard normalized.range(of: #"^[A-Za-z0-9][A-Za-z0-9._-]{0,99}$"#, options: .regularExpression) != nil else {
                        throw AppError.message("模型名称只允许字母、数字、点、短横线和下划线。")
                    }
                    if !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { try KeychainAPIKey.save(key) }
                    UserDefaults.standard.set(normalized, forKey: "GeminiModel")
                    key = ""
                    didSave = true
                    message = "设置已保存。"
                } catch { didSave = false; message = error.localizedDescription }
            }
        }
        .navigationTitle("AI 设置")
        .toolbar { Button("完成") { dismiss() } }
        .alert(didSave ? "已保存" : "未能保存", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("好") { message = nil }
        } message: { Text(message ?? "") }
    }
}
