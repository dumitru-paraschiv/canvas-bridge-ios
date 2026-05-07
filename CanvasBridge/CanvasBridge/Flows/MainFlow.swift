//
//  MainFlow.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Combine

protocol MainFlow: Flow {
    
}

final class DefaultMainFlow: NavigationFlow, MainFlow, ModuleFactory {
    
    override func start() {
        showMainView(with: MainModel())
    }
}

private extension DefaultMainFlow {
    
    func showMainView(with model: MainModel) {
        let mainView = makeMainView(with: model)
        mainView.steps.sink { [weak self] in
            switch $0 {
                
            }
        }
        .store(in: &mainView.stepsBag)
        setRoot(mainView)
    }
}
