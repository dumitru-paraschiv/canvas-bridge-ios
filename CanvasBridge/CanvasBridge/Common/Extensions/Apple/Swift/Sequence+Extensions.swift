//
//  Sequence+Extensions.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

public extension Sequence {
    
    func compactMap<T>(_ type: T.Type) -> [T] {
        compactMap { $0 as? T }
    }
    
    func sorted<Key: Comparable>(by keyPath: (Element) -> Key,
                                 _ comparator: (Key, Key) -> Bool = { $0 < $1 }) -> [Element] {
        sorted { comparator(keyPath($0), keyPath($1)) }
    }
    
    func unique(_ comparator: (Element, Element) -> Bool) -> [Element] {
        reduce([]) { result, element in
            result.contains { comparator($0, element) } ? result : result + [element]
        }
    }
    
    func unique<Key: Equatable>(by keyPath: (Element) -> Key) -> [Element] {
        unique { keyPath($0) == keyPath($1) }
    }
}

public extension Sequence where Element: Equatable {
    
    @inline(__always)
    func intersects<C: Collection>(with other: C) -> Bool where C.Element == Element {
        contains(where: other.contains)
    }
    
    @inline(__always)
    func notContains(_ element: Element) -> Bool {
        !contains(element)
    }
    
    @inline(__always)
    func unique() -> [Element] {
        reduce([]) { $0.contains($1) ? $0 : $0 + [$1] }
    }
}
