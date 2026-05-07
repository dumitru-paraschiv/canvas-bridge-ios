//
//  Collection+Extensions.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

public extension Collection {
    
    @inline(__always)
    var isNotEmpty: Bool {
        !isEmpty
    }
    
    @inline(__always)
    var nonEmpty: Self? {
        isEmpty ? nil : self
    }
    
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - RandomAccessCollection

public extension RandomAccessCollection where Self: MutableCollection {
    
    mutating func mutate(_ mutation: (inout Element) -> Void) {
        indices.forEach { mutation(&self[$0]) }
    }
}
