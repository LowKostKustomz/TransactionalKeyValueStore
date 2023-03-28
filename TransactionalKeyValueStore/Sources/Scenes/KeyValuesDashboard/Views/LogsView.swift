//
//  LogsView.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/24/23.
//

import SwiftUI

struct LogsView: View {
    
    let logs: [String]
    
    var body: some View {
        ScrollView {
            ScrollViewReader { reader in
                ForEach(Array(logs.enumerated()), id: \.offset) { index, log in
                    HStack {
                        Text(log)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .font(.system(size: 11.0, design: .monospaced))
                            .textSelection(.enabled)
                            .id(index)
                        Spacer()
                    }
                }
                .rotationEffect(Angle(degrees: 180))
                .onChange(of: logs, perform: { _ in
                    reader.scrollTo(logs.count, anchor: .bottom)
                })
            }
        }
        .scrollIndicators(.hidden)
        .rotationEffect(Angle(degrees: -180))
    }
}

struct LogsView_Previews: PreviewProvider {
    static var previews: some View {
        LogsView(logs: [
            "> BEGIN",
            "> GET foo",
            "123",
            "> DELETE foo",
            "12_"
        ])
    }
}
