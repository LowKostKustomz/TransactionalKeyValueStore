//
//  KeyValuesDashboard.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/23/23.
//

import SwiftUI
import Combine

struct KeyValuesDashboard: View {
    @ObservedObject var viewModel: KeyValuesDashboardViewModel
    
    var body: some View {
        Form {
            CollapsibleSection(
                collapsedButtonTitle: "Show",
                expandedButtonTitle: "Hide",
                additionalAction: .init(
                    title: "Clear logs",
                    onTap: {
                        viewModel.clearLogs()
                    }
                )) {
                    Text(viewModel.log.last ?? "")
                        .lineLimit(1)
                        .font(.system(size: 11.0, design: .monospaced))
                } expanded: {
                    KeyValuesDebugView(
                        logs: viewModel.log,
                        keyValues: viewModel.keyValues
                    )
                    .frame(height: 100.0)
                }
            Section {
                TransactionControl(
                    commitEnabled: viewModel.isCommitTransactionEnabled,
                    rollbackEnabled: viewModel.isRollbackTransactionEnabled
                ) { action in
                    viewModel.transactionAction(action)
                }
            }
            Section {
                ActionCreationForm(
                    command: $viewModel.selectedCommand,
                    input: $viewModel.input,
                    isInputRequired: viewModel.isInputRequired,
                    inputTitle: viewModel.inputTitle
                ) {
                    viewModel.submit()
                }
            }
        }
        .overlay(alignment: .top, content: {
            Color.clear
                .background(.thinMaterial)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 0)
        })
        .scrollDismissesKeyboard(.interactively)
        .alert(viewModel.confirmationTitle, isPresented: $viewModel.showConfirmation) {
            Button("Confirm", role: .destructive) {
                viewModel.confirm()
            }
            Button("Cancel", role: .cancel) {
                viewModel.decline()
            }
        }
    }
}

struct KeyValuesDashboard_Previews: PreviewProvider {
    static var previews: some View {
        KeyValuesDashboard(viewModel: KeyValuesDashboardViewModel(repo: DefaultKeyValuesRepo(storage: DefaultKeyValuesStorage()), logger: DefaultActionsLogger()))
    }
}
