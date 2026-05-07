//
//  MainViewModel.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Combine
import Foundation

@MainActor
final class MainViewModel: ObservableObject {
    
    enum Action {
        
        case viewDidLoad
    }
    
    @Published private(set) var model: MainModel
    
    private weak var output: MainViewOutput?
    
    init(model: MainModel) {
        self.model = model
    }
    
    func send(_ action: Action) {
        switch action {
        case .viewDidLoad: break
        }
    }
}

extension MainViewModel: MainViewInput {
    
    func bind(output: any MainViewOutput) {
        self.output = output
    }
}
