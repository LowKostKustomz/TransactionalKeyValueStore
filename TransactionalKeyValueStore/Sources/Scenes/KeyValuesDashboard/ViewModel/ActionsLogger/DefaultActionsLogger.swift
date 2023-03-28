//
//  DefaultActionsLogger.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/27/23.
//

import Foundation
import Combine

class DefaultActionsLogger {
    private let logsSubject: CurrentValueSubject<[String], Never> = .init([])
    
    private var logs: [String] = [] {
        didSet { updateLog() }
    }
    private var command: CommandControl.CommandAction? = nil {
        didSet { updateLog() }
    }
    private var input: String? = nil {
        didSet { updateLog() }
    }
    
    init() {
        self.updateLog()
    }
}

// MARK: Internal methods

extension DefaultActionsLogger {
    /// Recalculates `logsSubject`.
    func updateLog() {
        let commandInProgress: String = buildInProgressLog().appending("_")
        logsSubject.value = logs + [commandInProgress]
    }
    
    /// Builds current action log from `command` and `input`.
    func buildInProgressLog() -> String {
        var commandInProgress: String = ""
        
        if let command {
            commandInProgress += [command.commandLogName, " "].joined()
        }
        
        if let input, !input.isEmpty {
            commandInProgress += input
        }
        
        return commandInProgress
    }
    
    /// Appends new line to the log with `>` prefix.
    /// - Parameter newLine: line to append.
    func appendUserInputLog(_ newLine: String) {
        appendLog([">", newLine].joined(separator: " "))
    }
    
    /// Appends new line to the log.
    /// - Parameter newLine: line to append.
    func appendLog(_ newLine: String) {
        logs.append(newLine)
    }
}

// MARK: Extensions

private extension CommandControl.CommandAction {
    var commandLogName: String {
        switch self {
        case .count:
            return "COUNT"
        case .delete:
            return "DELETE"
        case .get:
            return "GET"
        case .set:
            return "SET"
        }
    }
}

private extension TransactionControl.TransactionAction {
    var actionLogName: String {
        switch self {
        case .commit:
            return "COMMIT"
        case .rollback:
            return "ROLLBACK"
        case .begin:
            return "BEGIN"
        }
    }
}

// MARK: KeyValuesDashboardActionsLogger

extension DefaultActionsLogger: KeyValuesDashboardActionsLogger {
    func logInput(_ input: String) {
        self.input = input
    }
    
    func logCommand(_ command: CommandControl.CommandAction?) {
        self.command = command
    }
    
    func saveInProgressLog() {
        appendUserInputLog(buildInProgressLog())
    }
    
    func logTransactionAction(_ action: TransactionControl.TransactionAction) {
        appendUserInputLog(action.actionLogName)
    }
    
    func logMessage(_ message: String) {
        appendLog(message)
    }
    
    func observeLog() -> AnyPublisher<[String], Never> {
        logsSubject.eraseToAnyPublisher()
    }
    
    func clearLogs() {
        logs = []
    }
}
