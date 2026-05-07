import Foundation
import Combine

/// A protocol defining the core operations for data persistence.
public protocol StorageProvider {
    
    /// Saves binary data to the underlying storage mechanism.
    /// - Parameter data: The data to persist.
    /// - Throws: An error if the write operation fails.
    func saveData(_ data: Data) throws
    
    /// Loads binary data from the underlying storage mechanism.
    /// - Returns: The persisted data, or nil if no data exists.
    /// - Throws: An error if the read operation fails.
    func loadData() throws -> Data?
}
