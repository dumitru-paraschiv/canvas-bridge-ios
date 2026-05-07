//
//  AppFlow.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//


import Combine
import Swinject
import UIKit

protocol AppFlow: NavigationFlow {
    
}

final class DefaultAppFlow: NavigationFlow, AppFlow, FlowFactory, ModuleFactory {
    
    private let window: UIWindow
    
    init(r: Resolver,
         window: UIWindow,
         controller: UINavigationController) {
        self.window = window
        super.init(r: r, controller: controller)
    }
    
    override func start() {
        removeAllChildren()
        
        showMainFlow()
    }
}

private extension DefaultAppFlow {
    
    func showMainFlow() {
        let mainflow = makeMainFlow(navigationController: self.controller)
        addChild(mainflow)
        push(mainflow)
    }
}
