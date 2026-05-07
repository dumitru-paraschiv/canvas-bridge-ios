//
//  ServiceAssembly.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject
import CanvasBridgeCore

final class ServiceAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(WebViewService.self) { _ in
            WebViewService()
        }
        .inObjectScope(.container)
        
        container.register(StorageProvider.self) { _ in
            IOSStorageProvider()
        }
        .inObjectScope(.container)
    }
}
