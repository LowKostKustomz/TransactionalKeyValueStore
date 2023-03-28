//
//  KeyValuesContainer.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/27/23.
//

import Foundation

struct KeyValuesContainer: Equatable {
    struct KeyValue: Equatable {
        let key: String
        let value: String
    }
    
    let keyValues: [KeyValue]
}
