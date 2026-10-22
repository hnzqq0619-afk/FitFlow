//
//  StorageManager.swift
//  FitFlow
//
//  Created by Engin Bolat on 23.12.2025.
//

import Foundation

protocol StorageServiceProtocol {
    func saveToLocal<T: Encodable>(_ key: StorageEnum, value: T) -> Bool
    func getFromLocal<T: Decodable>(_ key: StorageEnum, as type: T.Type) -> T?
}

class StorageManager: StorageServiceProtocol {
    static let shared = StorageManager()
    
    init() {}
    
    
    func saveToLocal<T: Encodable>(_ key: StorageEnum, value: T) -> Bool {
        do {
            let encoded = try JSONEncoder().encode(value)
            UserDefaults.standard.set(encoded, forKey: key.rawValue)
            return true
        } catch {
            print("Kaydetme sırasında hata oluştu (\(key.rawValue)): \(error)")
            return false
        }
    }
    
    func getFromLocal<T: Decodable>(_ key: StorageEnum, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else {
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(type, from: data)
            return decoded
        } catch {
            print("Veri çekme sırasında hata oluştu (\(key.rawValue)): \(error)")
            return nil
        }
    }
    
    func removeFromLocal(_ key: StorageEnum) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
