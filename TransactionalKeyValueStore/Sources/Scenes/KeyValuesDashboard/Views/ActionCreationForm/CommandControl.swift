//
//  CommandControl.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/24/23.
//

import SwiftUI

struct CommandControl: View {
    enum CommandAction: String, CaseIterable, Identifiable {
        case get
        case set
        case delete
        case count
        
        var id: String { rawValue }
    }
    
    @Binding var selectedAction: CommandAction?
    
    var body: some View {
        HStack {
            ForEach(CommandAction.allCases) { command in
                Button(command.commandName) {
                    if selectedAction != command {
                        selectedAction = command
                    } else {
                        selectedAction = nil
                    }
                }
                .buttonStyle(ToggleButtonStyle(isSelected: selectedAction == command))
            }
        }
    }
}

struct ToggleButtonStyle: PrimitiveButtonStyle {
    
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            .isSelected(isSelected)
            .buttonBorderShape(.roundedRectangle)
            .controlSize(.regular)
    }
}

extension Button {
    @ViewBuilder func isSelected(_ selected: Bool) -> some View {
        if selected {
            self.buttonStyle(.borderedProminent)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}

fileprivate extension CommandControl.CommandAction {
    var commandName: String {
        switch self {
        case .get: return "GET"
        case .set: return "SET"
        case .delete: return "DELETE"
        case .count: return "COUNT"
        }
    }
}

struct CommandControl_Previews: PreviewProvider {
    static var previews: some View {
        CommandControl(selectedAction: .constant(.set))
    }
}
