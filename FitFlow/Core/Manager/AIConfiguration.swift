import Foundation
import Security

enum AIConfiguration {
    static let defaultModel = "gemini-3.5-flash-lite"
    static var model: String {
        let value = UserDefaults.standard.string(forKey: "GeminiModel") ?? defaultModel
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    static var apiKey: String {
        let saved = (try? KeychainAPIKey.read()) ?? ""
        let bundled = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? ""
        let value = saved.isEmpty ? bundled : saved
        return value.contains("$(") ? "" : value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum KeychainAPIKey {
    private static var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: "FitFlow.Gemini",
         kSecAttrAccount as String: "personal-api-key"]
    }
    static func read() throws -> String? {
        var q = query
        q[kSecReturnData as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else {
            throw AppError.message("无法读取钥匙串中的 API Key。")
        }
        return String(data: data, encoding: .utf8)
    }
    static func save(_ value: String) throws {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, value.count <= 500,
              !value.contains("\n"), !value.contains("\r") else {
            throw AppError.message("请填写有效的 API Key。")
        }
        let attributes: [String: Any] = [kSecValueData as String: Data(value.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            let inserted = SecItemAdd(query.merging(attributes) { _, new in new } as CFDictionary, nil)
            guard inserted == errSecSuccess else { throw AppError.message("API Key 保存失败。") }
        } else if status != errSecSuccess {
            throw AppError.message("API Key 保存失败。")
        }
    }
}
