//
//  KeyValuesStorageSpy.swift
//  TransactionalKeyValueStoreTests
//
//  Created by Yehor Miroshnychenko on 3/27/23.
//

import Foundation
@testable import TransactionalKeyValueStore
import Combine

class KeyValuesStorageSpy {
    private(set) var calledSaveWith: [KeyValuesStorageContainer] = []
    
    struct Stub {
        let errorForGetContainer: Error?
        let container: KeyValuesStorageContainer
    }
    
    private var returnStub: Stub = .init(errorForGetContainer: nil, container: .mock12)
    
    func stub(
        errorForGetContainer: Error? = nil,
        container: KeyValuesStorageContainer = .mock12
    ) {
        returnStub = .init(
            errorForGetContainer: errorForGetContainer,
            container: container
        )
    }
}

extension KeyValuesStorageSpy: KeyValuesStorage {
    func save(container: KeyValuesStorageContainer) {
        calledSaveWith.append(container)
    }
    
    func removeContainer() { }
    func getContainer() throws -> KeyValuesStorageContainer {
        if let error = returnStub.errorForGetContainer {
            throw error
        }
        
        return returnStub.container
    }
    
    func observeContainer() -> AnyPublisher<KeyValuesStorageContainer?, Never> {
        CurrentValueSubject(returnStub.container).eraseToAnyPublisher()
    }
}
