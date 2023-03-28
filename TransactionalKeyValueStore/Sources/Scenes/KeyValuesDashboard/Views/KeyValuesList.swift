//
//  KeyValuesList.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/27/23.
//

import SwiftUI

struct KeyValuesList: View {
    struct KeyValueRowModel: Identifiable, Hashable {
        var id: Int { key.hashValue }
        
        let key: String
        let value: String
    }
    
    let keyValues: [KeyValueRowModel]
    
    var body: some View {
        List() {
            Section {
                ForEach(keyValues, id: \.id) { keyValue in
                    KeyValueRow(key: keyValue.key, value: keyValue.value)
                }
            }
        }
        .listStyle(.plain)
        .animation(.easeInOut, value: keyValues)
    }
}

struct KeyValuesList_Previews: PreviewProvider {
    static var previews: some View {
        KeyValuesList(keyValues: [
            .init(key: "Key", value: "Value"),
            .init(key: "Long key", value: "Short value")
        ])
    }
}

struct KeyValueRow: View {
    let key: String
    let value: String
    
    var body: some View {
        HStack {
            Text(key)
                .font(.footnote)
            
            Spacer()
            
            Text(value)
                .font(.footnote)
        }
        .listRowSeparator(.visible, edges: .bottom)
    }
}
