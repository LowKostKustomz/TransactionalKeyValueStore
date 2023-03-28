//
//  TransactionalKeyValueStoreApp.swift
//  TransactionalKeyValueStore
//
//  Created by Yehor Miroshnychenko on 3/23/23.
//

import SwiftUI

@main
struct TransactionalKeyValueStoreApp: App {
    let storage: KeyValuesStorage
    let repo: KeyValuesRepo
    let logger: KeyValuesDashboardActionsLogger
    
    init() {
        let storage = DefaultKeyValuesStorage()
        self.storage = storage
        self.repo = DefaultKeyValuesRepo(storage: storage)
        self.logger = DefaultActionsLogger()
    }
    
    var body: some Scene {
        WindowGroup {
            KeyValuesDashboard(
                viewModel: .init(
                    repo: repo,
                    logger: logger
                )
            )
        }
    }
}
