//
//  ModuleAssembly.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject

final class ModuleAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(MainView.self) { r, model in
            let viewModel = MainViewModel(
                model: model
            )
            let webViewModel = WebViewModel()
            let viewUI = MainViewUI(
                viewModel: viewModel,
                webViewModel: webViewModel
            )
            let view = MainViewController(rootView: viewUI)
            viewModel.bind(output: view)
            view.viewModel = viewModel
            return view
        }
    }
}
