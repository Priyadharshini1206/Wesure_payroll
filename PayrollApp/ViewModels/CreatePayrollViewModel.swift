//  CreatePayrollViewModel.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class CreatePayrollViewModel {
    struct DraftEmployee: Identifiable, Equatable {
        let id = UUID()
        var name: String = ""
        var wagesText: String = ""
        var isExempt: Bool = false

        var wages: Decimal? {
            let cleaned = wagesText
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleaned.isEmpty, let number = Decimal(string: cleaned) else {
                return nil
            }
            return number
        }

        var isValid: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && (wages ?? -1) >= 0
        }
    }

    var employees: [DraftEmployee] = [DraftEmployee()]
    private(set) var isSaving = false
    private(set) var errorMessage: String?
    private(set) var createdPayroll: Payroll?

    private let repository: PayrollRepository

    init(repository: PayrollRepository) {
        self.repository = repository
    }

    var canSave: Bool {
        !isSaving && employees.contains(where: \.isValid)
    }

    func addEmployee() {
        employees.append(DraftEmployee())
    }

    func removeEmployee(id: UUID) {
        employees.removeAll { $0.id == id }
        if employees.isEmpty {
            employees = [DraftEmployee()]
        }
    }

    func save() async -> Bool {
        errorMessage = nil
        let validEmployees = employees.compactMap { draft -> Employee? in
            guard draft.isValid, let wages = draft.wages else { return nil }
            return Employee(
                name: draft.name.trimmingCharacters(in: .whitespacesAndNewlines),
                wages: wages,
                isExempt: draft.isExempt
            )
        }

        guard !validEmployees.isEmpty else {
            errorMessage = "Add at least one employee with a name and wages."
            return false
        }

        isSaving = true
        defer { isSaving = false }

        do {
            createdPayroll = try await repository.createPayroll(employees: validEmployees)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
