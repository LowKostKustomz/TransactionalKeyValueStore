//
//  KeyValuesDashboardActionsLogger.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/27/23.
//

import Foundation
import Combine

protocol KeyValuesDashboardActionsLogger {
    
    func logInput(_ input: String)
    func logCommand(_ command: CommandControl.CommandAction?)
    func saveInProgressLog()
    
    func logTransactionAction(_ action: TransactionControl.TransactionAction)
    
    func logMessage(_ message: String)
    
    func observeLog() -> AnyPublisher<[String], Never>
    func clearLogs()
}
