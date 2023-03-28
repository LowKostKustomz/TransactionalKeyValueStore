//
//  KeyValuesDebugView.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/28/23.
//

import SwiftUI

struct KeyValuesDebugView: View {
    let logs: [String]
    let keyValues: [KeyValuesList.KeyValueRowModel]
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                LogsView(logs: logs)
                    .frame(
                        width: geometry.size.width * 3.0 / 5.0,
                        height: geometry.size.height
                    )
                
                Divider()
                
                KeyValuesList(keyValues: keyValues)
                    .frame(
                        width: geometry.size.width * 2.0 / 5.0,
                        height: geometry.size.height
                    )
            }
        }
    }
}

struct KeyValuesDebugView_Previews: PreviewProvider {
    static var previews: some View {
        KeyValuesDebugView(
            logs: ["One", "Two", "Three"],
            keyValues: [.init(key: "Key", value: "Value")]
        )
    }
}
