//
//  IOSStorageProvider.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Foundation
import CanvasBridgeCore

final class IOSStorageProvider: StorageProvider {
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var saveFileURL: URL {
        getDocumentsDirectory().appendingPathComponent("canvas_state.json")
    }
    
    func saveData(_ data: Data) throws {
        try data.write(to: saveFileURL, options: [.atomic, .completeFileProtection])
    }
    
    func loadData() throws -> Data? {
        guard FileManager.default.fileExists(atPath: saveFileURL.path) else { return nil }
        return try Data(contentsOf: saveFileURL)
    }
}
