//
//  KeyValuesStorage.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/23/23.
//

import Foundation
import Combine

protocol KeyValuesStorage {
    /// Saves given container to storage.
    /// - Parameter container: `KeyValuesStorageContainer`
    func save(container: KeyValuesStorageContainer)
    
    /// Removes saved container from storage.
    func removeContainer()
    
    /// Returns saved container with key-values.
    /// - Throws: `KeyValuesStorageAccessError`
    /// - Returns: `KeyValuesStorageContainer`
    func getContainer() throws -> KeyValuesStorageContainer
    
    /// Publishes key-values container from storage when it's changed.
    /// - Returns: `AnyPublisher` with saved key-values container.
    func observeContainer() -> AnyPublisher<KeyValuesStorageContainer?, Never>
}

enum KeyValuesStorageAccessError: Error {
    /// No key-values container in storage.
    case noContainer
}
