//
//  AnyFactory.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject

protocol AnyFactory {
    
    var r: Resolver { get }
}

class BaseFactory: AnyFactory {
    
    let r: Resolver
    
    init(r: Resolver) {
        self.r = r
    }
}
