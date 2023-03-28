//
//  KeyValuesStorageContainer+Extensions.swift
//  TransactionalKeyValueStoreTests
//
//  Created by Yehor Miroshnychenko on 3/27/23.
//

import Foundation
@testable import TransactionalKeyValueStore

extension KeyValuesStorageContainer {
    static var mock12: KeyValuesStorageContainer {
        .init(
            keyValues: [
                .mock1,
                .mock2
            ]
        )
    }
    
    static var mock123: KeyValuesStorageContainer {
        .init(
            keyValues: [
                .mock1,
                .mock2,
                .mock3
            ]
        )
    }
}

extension KeyValuesStorageContainer.KeyValue {
    static var mock1: KeyValuesStorageContainer.KeyValue {
        .init(key: "Key1", value: "Value1")
    }
    
    static var mock2: KeyValuesStorageContainer.KeyValue {
        .init(key: "Key2", value: "Value2")
    }
    
    static var mock3: KeyValuesStorageContainer.KeyValue {
        .init(key: "Key3", value: "Value3")
    }
}
