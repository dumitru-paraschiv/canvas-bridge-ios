//
//  App.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject
import UIKit

@main
final class App: AppDelegate {
    
    private let container: Container
    
    override init() {
        self.container = DIContainer.main.container
        super.init()
        services = [
            
        ]
    }
}
