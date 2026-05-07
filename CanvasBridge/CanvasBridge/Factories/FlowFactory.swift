//
//  FlowFactory.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject
import UIKit

protocol FlowFactory {
    
    func makeMainFlow(navigationController: UINavigationController) -> MainFlow
}

extension FlowFactory where Self: AnyFactory {
    
    func makeMainFlow(navigationController: UINavigationController) -> MainFlow {
        r.resolve(with: navigationController)
    }
}

final class DefaultFlowFactory: BaseFactory, FlowFactory {}
