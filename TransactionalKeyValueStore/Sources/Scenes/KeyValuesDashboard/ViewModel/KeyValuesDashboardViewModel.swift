//
//  KeyValuesDashboardViewModel.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/25/23.
//

import Foundation
import SwiftUI
import Combine

class KeyValuesDashboardViewModel: ObservableObject {
    
    private enum ParsedAction {
        case set(key: KeyValuesRepo.Key, value: KeyValuesRepo.Value)
        case get(key: KeyValuesRepo.Key)
        case delete(key: KeyValuesRepo.Key)
        case count(value: KeyValuesRepo.Value)
    }
    
    @Published var log: [String] = []
    
    @Published var keyValues: [KeyValuesList.KeyValueRowModel] = []
    
    @Published var isCommitTransactionEnabled: Bool = false
    @Published var isRollbackTransactionEnabled: Bool = false
    
    @Published var selectedCommand: CommandControl.CommandAction?
    @Published var isInputRequired: Bool = false
    @Published var inputTitle: String = ""
    @Published var input: String = ""
    
    @Published var showConfirmation: Bool = false
    @Published var confirmationTitle: String = ""
    
    private var onConfirmed: (() -> Void)?
    private var cancellables: Set<AnyCancellable> = []
    
    /// If set to `true` disables transaction commit/rollback buttons if there is no transaction.
    private let userFriendlyInterface: Bool = false
    private let logger: KeyValuesDashboardActionsLogger
    private let repo: KeyValuesRepo
    
    init(
        repo: KeyValuesRepo,
        logger: KeyValuesDashboardActionsLogger
    ) {
        self.repo = repo
        self.selectedCommand = nil
        self.logger = logger
        
        self.observeKeyValuesRepo()
        self.observeLogger()
        self.observeCommandChanges()
        self.observeInputChanges()
    }
}

// MARK: Internal methods

extension KeyValuesDashboardViewModel {
    func transactionAction(_ action: TransactionControl.TransactionAction) {
        handleTransactionAction(action)
    }
    
    func clearLogs() {
        logger.clearLogs()
    }
    
    func submit() {
        handleSubmittion()
    }
    
    func confirm() {
        onConfirmed?()
        resetConfirmation()
    }
    
    func decline() {
        resetConfirmation()
    }
}

// MARK: Private methods

extension KeyValuesDashboardViewModel {
    private func observeLogger() {
        logger
            .observeLog()
            .assign(to: &$log)
    }
    
    private func observeKeyValuesRepo() {
        repo
            .observeKeyValues()
            .map({ container -> [KeyValuesList.KeyValueRowModel] in
                container.mapToRowModels()
            })
            .assign(to: &$keyValues)
        
        repo
            .observeTransactionInProgress()
            .sink { [weak self] inProgress in
                if self?.userFriendlyInterface == true {
                    self?.isCommitTransactionEnabled = inProgress
                    self?.isRollbackTransactionEnabled = inProgress
                } else {
                    self?.isCommitTransactionEnabled = true
                    self?.isRollbackTransactionEnabled = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func observeCommandChanges() {
        $selectedCommand.sink { command in
            switch command {
            case .get, .delete:
                self.isInputRequired = true
                self.inputTitle = "Enter key"
                
            case .set:
                self.isInputRequired = true
                self.inputTitle = "Enter key and value"
                
            case .count:
                self.isInputRequired = true
                self.inputTitle = "Enter value"
                
            case .none:
                self.isInputRequired = false
                self.inputTitle = ""
                self.input = ""
            }
            
            self.logger.logCommand(command)
        }
        .store(in: &cancellables)
    }
    
    private func observeInputChanges() {
        $input.sink { input in
            self.logger.logInput(input)
        }
        .store(in: &cancellables)
    }
    
    private func handleTransactionAction(
        _ action: TransactionControl.TransactionAction
    ) {
        if action.requiresConfirmation && repo.transactionInProgress {
            confirmationTitle = action.confirmationTitle
            onConfirmed = { [weak self] in
                self?.processTransactionAction(action)
            }
            
            showConfirmation = true
        } else {
            processTransactionAction(action)
        }
    }
    
    private func processTransactionAction(
        _ action: TransactionControl.TransactionAction
    ) {
        do {
            logger.logTransactionAction(action)
            
            switch action {
            case .begin:
                repo.begin()
                
            case .rollback:
                try repo.rollback()
                
            case .commit:
                try repo.commit()
            }
        } catch let repoTransactionError as KeyValuesRepoTransactionError {
            switch repoTransactionError {
            case .noTransaction:
                logger.logMessage("no transaction")
            }
        } catch {
            // All types of possible errors should be handled.
            assertionFailure("Should never happen")
        }
    }
    
    private func handleSubmittion() {
        do {
            let parsedAction = try parseAction()
            
            if selectedCommand?.requiresConfirmation == true {
                showConfirmation = true
                confirmationTitle = selectedCommand?.confirmationTitle ?? ""
                onConfirmed = { [weak self] in
                    self?.processSubmussion(parsedAction)
                }
            } else {
                processSubmussion(parsedAction)
            }
        } catch let parsingError as ParsingError {
            logger.saveInProgressLog()
            switch parsingError {
            case .wrongInputItems:
                logger.logMessage("wrong input")
            case .commandNotSelected:
                logger.logMessage("select command")
            }
        } catch {
            // All types of possible errors should be handled.
            assertionFailure("Should never happen")
        }
        
        clearInputs()
    }
    
    private func processSubmussion(
        _ parsedAction: ParsedAction
    ) {
        do {
            logger.saveInProgressLog()
            
            switch parsedAction {
                
            case .set(let key, let value):
                repo.set(value: value, for: key)
                
            case .get(let key):
                logger.logMessage(try repo.get(key: key))
                
            case .delete(let key):
                repo.delete(key: key)
                
            case .count(let value):
                logger.logMessage("\(repo.count(value: value))")
            }
        } catch let repoAccessError as KeyValuesRepoAccessError {
            switch repoAccessError {
            case .keyNotSet:
                logger.logMessage("key not set")
            }
        } catch {
            // All types of possible errors should be handled.
            assertionFailure("Should never happen")
        }
    }
    
    private enum ParsingError: Error {
        case commandNotSelected
        case wrongInputItems
    }
    private func parseAction() throws -> ParsedAction {
        guard let selectedCommand else {
            throw ParsingError.commandNotSelected
        }
        
        let inputItems: [String] = input.components(separatedBy: " ")
        
        switch selectedCommand {
        case .set:
            try checkInputItemsCount(inputItems, equals: 2)
            return .set(key: inputItems[0], value: inputItems[1])
            
        case .get:
            try checkInputItemsCount(inputItems, equals: 1)
            return .get(key: inputItems[0])
            
        case .delete:
            try checkInputItemsCount(inputItems, equals: 1)
            return .delete(key: inputItems[0])
            
        case .count:
            try checkInputItemsCount(inputItems, equals: 1)
            return .count(value: inputItems[0])
        }
    }
    
    private func checkInputItemsCount(_ items: [String], equals count: Int) throws {
        guard items.filter({ !$0.isEmpty }).count == count else {
            throw ParsingError.wrongInputItems
        }
    }
    
    private func clearInputs() {
        selectedCommand = nil
        input = ""
    }
    
    private func resetConfirmation() {
        showConfirmation = false
        confirmationTitle = ""
        onConfirmed = nil
    }
}

// MARK: Extensions

private extension TransactionControl.TransactionAction {
    var requiresConfirmation: Bool {
        switch self {
        case .begin: return false
        case .commit, .rollback: return true
        }
    }
    
    var confirmationTitle: String {
        switch self {
        case .begin: return ""
        case .rollback: return "Are you sure you want to rollback transaction?"
        case .commit: return "Are you sure you want to commit transaction?"
        }
    }
}

private extension CommandControl.CommandAction {
    var requiresConfirmation: Bool {
        switch self {
        case .count, .get, .set: return false
        case .delete: return true
        }
    }
    
    var confirmationTitle: String {
        switch self {
        case .count, .get, .set: return ""
        case .delete: return "Are you sure you want to delete value?"
        }
    }
}

private extension KeyValuesContainer {
    func mapToRowModels() -> [KeyValuesList.KeyValueRowModel] {
        keyValues.map {
            .init(key: $0.key, value: $0.value)
        }
    }
}
