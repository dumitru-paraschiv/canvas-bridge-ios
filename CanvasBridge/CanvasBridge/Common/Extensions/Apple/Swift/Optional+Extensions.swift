//
//  Optional+Extensions.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

public extension Optional {
    
    @inline(__always)
    var isNone: Bool {
        self == nil
    }
    
    @inline(__always)
    var isSome: Bool {
        self != nil
    }
    
    @inline(__always)
    func or(_ optional: Self) -> Self {
        self ?? optional
    }
    
    @inline(__always)
    func orJust(_ value: Wrapped) -> Wrapped {
        self ?? value
    }
}

public extension Optional where Wrapped: ExpressibleByIntegerLiteral {
    
    @inline(__always)
    var orZero: Wrapped {
        self ?? 0
    }
}

public extension Optional where Wrapped: ExpressibleByStringLiteral {
    
    @inline(__always)
    var orEmpty: Wrapped {
        self ?? ""
    }
}

public extension Optional where Wrapped: ExpressibleByArrayLiteral {
    
    @inline(__always)
    var orEmpty: Wrapped {
        self ?? []
    }
}
