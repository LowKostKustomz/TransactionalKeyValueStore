//
//  KeyValuesRepo.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/23/23.
//

import Foundation
import Combine

protocol KeyValuesRepo {
    typealias Key = String
    typealias Value = String
    
    /// Most up-to-date key-values container.
    var keyValuesContainer: KeyValuesContainer { get }
    
    /// If there is in-progress transaction.
    var transactionInProgress: Bool { get }
    
    /// Sets new value for the given key.
    func set(value: Value, for key: Key)
    
    /// Returns value for the given key.
    /// - Throws: `KeyValuesRepoAccessError`
    func get(key: Key) throws -> Value
    
    /// Deletes value for the given key.
    func delete(key: Key)
    
    /// Returns count of given value entries.
    func count(value: Value) -> Int
    
    /// Begins new transaction.
    func begin()
    
    /// Commits transaction.
    /// - Throws: `KeyValuesRepoTransactionError`
    func commit() throws
    
    /// Rollbacks transaction.
    /// - Throws: `KeyValuesRepoTransactionError`
    func rollback() throws
    
    /// Publishes value when `transactionInProgress` changes it's value.
    func observeTransactionInProgress() -> AnyPublisher<Bool, Never>
    
    /// Publishes most up-to-date key-values container when it's changed.
    func observeKeyValues() -> AnyPublisher<KeyValuesContainer, Never>
}

/// Errors thrown when access by key is not possible.
enum KeyValuesRepoAccessError: Error {
    /// Value for the given key is not set.
    case keyNotSet
}

/// Errors throws when operating with transactions.
enum KeyValuesRepoTransactionError: Error {
    /// No pending transaction.
    case noTransaction
}
