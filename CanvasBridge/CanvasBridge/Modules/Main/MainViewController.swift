//
//  MainViewController.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Combine
import SwiftUI

final class MainViewController: BaseHostingController<MainViewUI>, MainView {
    
    let steps = PassthroughSubject<MainViewSteps, Never>()
    var viewModel: MainViewInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.send(.viewDidLoad)
    }
}

struct MainViewUI: View {
    
    @ObservedObject private var viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Text("Main")
    }
}
