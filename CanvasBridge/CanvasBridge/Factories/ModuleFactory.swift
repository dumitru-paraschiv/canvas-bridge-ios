//
//  ModuleFactory.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject

protocol ModuleFactory {
    
    func makeMainView(with model: MainModel) -> MainView
}

extension ModuleFactory where Self: AnyFactory {
    
    func makeMainView(with model: MainModel) -> MainView {
        r.resolve(with: model)
    }
}

final class DefaultModuleFactory: BaseFactory, ModuleFactory {}
