//
//  FlowAssembly.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject

final class FlowAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(AppFlow.self) { r, window, navigationController in
            DefaultAppFlow(r: r, window: window, controller: navigationController)
        }
        .inObjectScope(.weak)
        
        container.register(MainFlow.self) { r, navigationController in
            DefaultMainFlow(r: r, controller: navigationController)
        }
    }
}
