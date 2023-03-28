//
//  ActionCreationForm.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/27/23.
//

import SwiftUI

struct ActionCreationForm: View {
    
    @Binding var command: CommandControl.CommandAction?
    @Binding var input: String
    
    let isInputRequired: Bool
    let inputTitle: String
    
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select action")
                .font(.footnote)
            CommandControl(selectedAction: $command)
            
            if isInputRequired {
                Text(inputTitle)
                    .font(.footnote)
                TextField(inputTitle, text: $input)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.none)
                    .keyboardType(.asciiCapable)
                    .autocorrectionDisabled(true)
                    .submitLabel(.go)
                    .onSubmit(onSubmit)
                    .transition(.opacity)
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}

struct ActionCreationForm_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section {
                ActionCreationForm(
                    command: .constant(.get),
                    input: .constant("Input"),
                    isInputRequired: true,
                    inputTitle: "Title",
                    onSubmit: { }
                )
            }
        }
    }
}
