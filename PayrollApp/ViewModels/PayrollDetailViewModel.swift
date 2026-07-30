//  PayrollDetailViewModel.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class PayrollDetailViewModel {
    private(set) var payroll: Payroll?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let payrollID: UUID
    private let repository: PayrollRepository

    init(payrollID: UUID, repository: PayrollRepository, initialPayroll: Payroll? = nil) {
        self.payrollID = payrollID
        self.repository = repository
        self.payroll = initialPayroll
    }

    func load() async {
        if payroll == nil {
            isLoading = true
        }
        errorMessage = nil
        defer { isLoading = false }

        do {
            payroll = try await repository.getPayroll(id: payrollID)
        } catch {
            if payroll == nil {
                errorMessage = error.localizedDescription
            }
        }
    }
}
