//
//  Swinject+Extensions.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject

extension Resolver {
    
    private func failure<T>() -> T {
        fatalError("Can't resolve \(T.self)")
    }
    
    func resolve<T>(_ type: T.Type = T.self,
                    name: String? = nil) -> T {
        resolve(type, name: name) ?? failure()
    }
    
    func resolve<T, Arg>(_ type: T.Type = T.self,
                         name: String? = nil,
                         with argument: Arg) -> T {
        resolve(T.self, name: name, argument: argument) ?? failure()
    }
    
    func resolve<T, Arg1, Arg2>(_ type: T.Type = T.self,
                                name: String? = nil,
                                with arg1: Arg1,
                                _ arg2: Arg2) -> T {
        resolve(T.self, name: name, arguments: arg1, arg2) ?? failure()
    }
}
