//
//  String+Extensions.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

public extension String {
    
    @inline(__always)
    static var empty: String { "" }
    
    @inline(__always)
    static var space: String { " " }
    
    @inline(__always)
    var wrappedIntoBrackets: String { "[\(self)]" }
}

import Foundation

public extension String {
    
    @inline(__always)
    var nsString: NSString {
        self as NSString
    }
    
    var urlValue: URL? {
        isEmpty ? nil : URL(string: self)
    }
    
    var initials: String {
        let words = self.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let initials = words.map { $0.prefix(1).uppercased() }
        return initials.joined()
    }
}
