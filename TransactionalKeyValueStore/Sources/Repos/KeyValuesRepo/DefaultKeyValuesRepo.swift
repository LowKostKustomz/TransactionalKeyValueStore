//
//  DefaultKeyValuesRepo.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/23/23.
//

import Foundation
import Combine

class DefaultKeyValuesRepo {
    let storage: KeyValuesStorage
    let transactionsSubject: CurrentValueSubject<[Transaction], Never> = .init([])
    
    init(
        storage: KeyValuesStorage
    ) {
        self.storage = storage
    }
}

// MARK: Internal methods

extension DefaultKeyValuesRepo {
    func throwNoTransactionIfNeeded() throws {
        guard !transactionsSubject.value.isEmpty else {
            throw KeyValuesRepoTransactionError.noTransaction
        }
    }
    
    func storageKeyValuesContainer() -> KeyValuesStorageContainer {
        do {
            return try storage.getContainer()
        } catch let e as KeyValuesStorageAccessError {
            switch e {
            case .noContainer:
                return .init()
            }
        } catch {
            // All types of possible errors should be handled.
            assertionFailure("Should never happen")
            return .init()
        }
    }
    
    func mostUpToDateKeyValuesContainer() -> KeyValuesStorageContainer {
        if let lastTransaction = transactionsSubject.value.last {
            return lastTransaction.keyValuesContainer
        } else {
            return storageKeyValuesContainer()
        }
    }
    
    func dropLastTransaction() {
        transactionsSubject.value = Array(transactionsSubject.value.dropLast(1))
    }
    
    func modify(
        value: Value?,
        for key: Key
    ) {
        if transactionInProgress {
            transactionsSubject.value[transactionsSubject.value.count - 1].keyValuesContainer[key] = value
        } else {
            var container: KeyValuesStorageContainer = storageKeyValuesContainer()
            container[key] = value
            storage.save(container: container)
        }
    }
}

// MARK: Extensions

private extension KeyValuesStorageContainer {
    func mapToContainer() -> KeyValuesContainer {
        .init(
            keyValues: keyValues.map({ $0.mapToKeyValue() })
        )
    }
}

private extension KeyValuesStorageContainer.KeyValue {
    func mapToKeyValue() -> KeyValuesContainer.KeyValue {
        .init(key: key, value: value)
    }
}

// MARK: KeyValuesRepo

extension DefaultKeyValuesRepo: KeyValuesRepo {
    var keyValuesContainer: KeyValuesContainer {
        mostUpToDateKeyValuesContainer()
            .mapToContainer()
    }
    
    var transactionInProgress: Bool {
        !transactionsSubject.value.isEmpty
    }
    
    func set(
        value: Value,
        for key: Key
    ) {
        modify(value: value, for: key)
    }
    
    func get(
        key: Key
    ) throws -> Value {
        guard let value = mostUpToDateKeyValuesContainer()[key]
        else {
            throw KeyValuesRepoAccessError.keyNotSet
        }

        return value
    }
    
    func delete(
        key: Key
    ) {
        modify(value: nil, for: key)
    }
    
    func count(
        value: Value
    ) -> Int {
        mostUpToDateKeyValuesContainer()
            .keyValues
            .filter { $0.value == value }
            .count
    }
    
    func begin() {
        let transaction: Transaction = .init(
            keyValuesContainer: mostUpToDateKeyValuesContainer()
        )
        
        transactionsSubject.value.append(transaction)
    }
    
    func commit() throws {
        try throwNoTransactionIfNeeded()
        guard let transactionToCommit = transactionsSubject.value.last else {
            throw KeyValuesRepoTransactionError.noTransaction
        }
        
        dropLastTransaction()
        if transactionsSubject.value.isEmpty {
            storage.save(container: transactionToCommit.keyValuesContainer)
        } else {
            // Apply commited changes only for the previous transaction.
            transactionsSubject.value[transactionsSubject.value.count - 1].keyValuesContainer = transactionToCommit.keyValuesContainer
        }
    }
    
    func rollback() throws {
        try throwNoTransactionIfNeeded()
        dropLastTransaction()
    }
    
    func observeKeyValues() -> AnyPublisher<KeyValuesContainer, Never> {
        let storageContainerPublisher = storage.observeContainer()
        let latestTransactionContainerPublisher = transactionsSubject.map { $0.last?.keyValuesContainer }
        
        return Publishers
            .CombineLatest(latestTransactionContainerPublisher, storageContainerPublisher)
            .map { latestTransactionContainer, storageContainer -> KeyValuesContainer in
                // Transaction is most up-to-date source, if no transaction then storage is most up-to-date.
                let container = latestTransactionContainer ?? storageContainer ?? .init()
                return container.mapToContainer()
            }
            .eraseToAnyPublisher()
    }
    
    func observeTransactionInProgress() -> AnyPublisher<Bool, Never> {
        transactionsSubject
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
}
