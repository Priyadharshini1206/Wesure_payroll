//  PayrollListViewModel.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class PayrollListViewModel {
    private(set) var payrolls: [Payroll] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private let repository: PayrollRepository

    init(repository: PayrollRepository) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            payrolls = try await repository.getPayrolls()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await load()
    }
}
