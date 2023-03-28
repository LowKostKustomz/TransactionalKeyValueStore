//
//  KeyValuesStorageContainer.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/23/23.
//

import Foundation

struct KeyValuesStorageContainer: Equatable {
    struct KeyValue: Equatable {
        typealias Key = String
        typealias Value = String
        
        let key: Key
        fileprivate(set) var value: Value
    }
    
    var keyValues: [KeyValue] = []
    
    subscript(key: KeyValue.Key) -> KeyValue.Value? {
        get {
            keyValues.first(where: { $0.key == key })?.value
        }
        set {
            if let index = keyValues.firstIndex(where: { $0.key == key }) {
                if let newValue {
                    keyValues[index].value = newValue
                } else {
                    keyValues.remove(at: index)
                }
            } else if let newValue {
                keyValues.append(.init(key: key, value: newValue))
            }
        }
    }
}
