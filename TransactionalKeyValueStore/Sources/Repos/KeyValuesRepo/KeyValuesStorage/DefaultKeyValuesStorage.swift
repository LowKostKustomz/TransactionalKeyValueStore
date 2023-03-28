//
//  DefaultKeyValuesStorage.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/23/23.
//

import Foundation
import Combine

class DefaultKeyValuesStorage {
    let keyValuesContainerSubject: CurrentValueSubject<KeyValuesStorageContainer?, Never> = .init(nil)
}

// MARK: KeyValuesStorage

extension DefaultKeyValuesStorage: KeyValuesStorage {
    func save(container: KeyValuesStorageContainer) {
        keyValuesContainerSubject.send(container)
    }
    
    func removeContainer() {
        keyValuesContainerSubject.send(nil)
    }
    
    func getContainer() throws -> KeyValuesStorageContainer {
        guard let keyValuesContainer = keyValuesContainerSubject.value else {
            throw KeyValuesStorageAccessError.noContainer
        }
        
        return keyValuesContainer
    }
    
    func observeContainer() -> AnyPublisher<KeyValuesStorageContainer?, Never> {
        keyValuesContainerSubject.eraseToAnyPublisher()
    }
}
