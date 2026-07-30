//  CreatePayrollView.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import SwiftUI

struct CreatePayrollView: View {
    @Bindable var viewModel: CreatePayrollViewModel
    var onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                ForEach($viewModel.employees) { $employee in
                    EmployeeDraftSection(
                        employee: $employee,
                        canRemove: viewModel.employees.count > 1
                    ) {
                        viewModel.removeEmployee(id: employee.id)
                    }
                }

                Button {
                    viewModel.addEmployee()
                } label: {
                    Label("Add Employee", systemImage: "person.badge.plus")
                }
            } header: {
                Text("Employees")
            } footer: {
                Text("Taxes of 5% apply when wages are greater than $1,000 and the employee is not exempt.")
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("New Payroll")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Button("Save") {
                        Task {
                            if await viewModel.save() {
                                onComplete()
                            }
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

private struct EmployeeDraftSection: View {
    @Binding var employee: CreatePayrollViewModel.DraftEmployee
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Full name", text: $employee.name)
                .textContentType(.name)
                .autocorrectionDisabled()

            TextField("Wages", text: $employee.wagesText)
                .keyboardType(.decimalPad)

            Toggle("Tax exempt", isOn: $employee.isExempt)

            if canRemove {
                Button("Remove employee", role: .destructive, action: onRemove)
            }
        }
        .padding(.vertical, 4)
    }
}
