//
//  Trace.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Foundation

func trace(_ args: Any...,
           caller: Any? = nil,
           file: String = #file,
           function: String = #function) {
    var timestamp: String {
        Date.now.string(format: "HH:mm:ss.SSS")
    }
    var prettyCaller: String? {
        if let string = caller as? String {
            return string
        }
        return caller.flatMap {
            String(describing: type(of: $0))
        }
    }
    var prettyFile: String {
        file
            .nsString.deletingPathExtension
            .nsString.lastPathComponent
    }
    var prettyFunction: String {
        let splits = function.components(separatedBy: CharacterSet(charactersIn: "()"))
        if splits.count == 2 {
            return splits[0] + splits[1].components(separatedBy: ":").map(\.capitalized).joined()
        }
        return function
    }
    var context: String {
        [prettyCaller ?? prettyFile, prettyFunction]
            .filter(\.isNotEmpty)
            .joined(.space)
    }
    var prefix: String {
        [timestamp, context]
            .filter(\.isNotEmpty)
            .map(\.wrappedIntoBrackets)
            .joined(" • ")
    }
    var prettyArguments: String {
        args
            .map(String.init(describing:))
            .joined(.space)
    }
    var format: String {
        [prefix, prettyArguments]
            .filter(\.isNotEmpty)
            .joined(.space)
    }
    #if DEBUG
    print(format)
    #endif
}
