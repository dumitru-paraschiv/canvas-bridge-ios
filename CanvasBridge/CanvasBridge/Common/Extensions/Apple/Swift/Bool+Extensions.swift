//
//  Bool+Extensions.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

public extension Bool {
    
    @inline(__always)
    var isFalse: Bool {
        !self
    }
}
