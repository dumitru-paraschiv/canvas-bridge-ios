//
//  Date+Extensions.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Foundation

public extension Date {
    
    var seconds: Int {
        Int(timeIntervalSince1970)
    }
    
    var milliseconds: Int {
        Int(timeIntervalSince1970 * 1000)
    }
    
    init(seconds: Int) {
        self.init(timeIntervalSince1970: TimeInterval(seconds))
    }
    
    init(milliseconds: Int) {
        self.init(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func string(format dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = .gregorian
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}
