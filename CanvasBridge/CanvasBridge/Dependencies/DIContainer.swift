//
//  DIContainer.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject

final class DIContainer {
    
    static let main = DIContainer()
    
    let container: Container
    let asssembler: Assembler
    
    private init() {
        container = Container()
        asssembler = Assembler([
            FlowAssembly(),
            ModuleAssembly(),
            ServiceAssembly()
        ], container: container)
    }
}
