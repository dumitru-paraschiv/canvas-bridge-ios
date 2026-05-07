//
//  MainView.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Combine

enum MainViewSteps {
    
}

protocol MainViewOutput: AnyObject {
    
    var steps: PassthroughSubject<MainViewSteps, Never> { get }
}

protocol MainViewInput {
    
    func bind(output: MainViewOutput)
    func send(_ action: MainViewModel.Action)
}

protocol MainView: Presentable, MainViewOutput {
    
    var viewModel: MainViewInput! { get set }
}
