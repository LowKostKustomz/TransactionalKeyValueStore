//
//  TransactionControl.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/24/23.
//

import SwiftUI

struct TransactionControl: View {
    enum TransactionAction {
        case begin
        case commit
        case rollback
    }
    
    let commitEnabled: Bool
    let rollbackEnabled: Bool
    let action: ((TransactionAction) -> Void)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Transaction management")
                .font(.footnote)
            HStack {
                Button("Begin") {
                    action(.begin)
                }
                .buttonStyle(LargeButtonStyle())
                Button("Commit") {
                    action(.commit)
                }
                .buttonStyle(LargeButtonStyle())
                .disabled(!commitEnabled)
                .animation(.easeInOut, value: commitEnabled)
                Button("Rollback") {
                    action(.rollback)
                }
                .buttonStyle(LargeButtonStyle())
                .disabled(!rollbackEnabled)
                .animation(.easeInOut, value: rollbackEnabled)
            }
        }
    }
}

struct LargeButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .controlSize(.regular)
    }
}

struct TransactionControl_Previews: PreviewProvider {
    static var previews: some View {
        TransactionControl(
            commitEnabled: false,
            rollbackEnabled: true,
            action: { _ in }
        )
    }
}
