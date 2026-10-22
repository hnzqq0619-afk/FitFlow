//
//  DependencyContainer.swift
//  FitFlow
//
//  Created by Engin Bolat on 23.12.2025.
//

import Foundation

@MainActor
protocol DependencyContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T
}

@MainActor
final class DependencyContainer: DependencyContainerProtocol {
    static let shared = DependencyContainer()
    
    private var factories: [String: () -> Any] = [:]
    private var instances: [String: Any] = [:]
    
    private init() {}
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        if let instance = instances[key] as? T {
            return instance
        }
        
        guard let factory = factories[key] else {
            fatalError("No factory registered for type: \(type)")
        }
        
        let instance = factory() as! T
        instances[key] = instance
        return instance
    }
}

// MARK: - Property Wrapper for Easy Injection
@propertyWrapper
@MainActor
struct Injected<T> {
    private let type: T.Type
    
    init(_ type: T.Type) {
        self.type = type
    }
    
    var wrappedValue: T {
        DependencyContainer.shared.resolve(type)
    }
}
