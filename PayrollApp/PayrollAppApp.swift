//  PayrollAppApp.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import SwiftUI

@main
struct PayrollAppApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PayrollListView(
                    viewModel: PayrollListViewModel(repository: dependencies.repository),
                    repository: dependencies.repository
                )
            }
        }
    }
}

/// Composition root for dependency injection.
final class AppDependencies {
    let repository: PayrollRepository

    init(
        api: PayrollAPIClient = MockPayrollAPIClient(),
        store: PayrollStore = FilePayrollStore()
    ) {
        // Seed local store once so the sample payroll from the brief is available offline.
        if (try? store.loadPayrolls())?.isEmpty != false {
            try? store.savePayrolls(SampleData.examplePayrolls)
        }
        self.repository = DefaultPayrollRepository(api: api, store: store)
    }
}
