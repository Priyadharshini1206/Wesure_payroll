//  PayrollDetailView.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import SwiftUI

struct PayrollDetailView: View {
    @Bindable var viewModel: PayrollDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.payroll == nil {
                ProgressView("Loading payroll…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.payroll == nil {
                ContentUnavailableView(
                    "Unable to Load Payroll",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if let payroll = viewModel.payroll {
                detailContent(payroll)
            }
        }
        .navigationTitle("Payroll Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    private func detailContent(_ payroll: Payroll) -> some View {
        List {
            Section("Created") {
                Text(CurrencyFormatter.string(from: payroll.createdAt))
            }

            Section("Employees") {
                ForEach(payroll.employees) { employee in
                    EmployeeDetailRow(employee: employee)
                }
            }

            Section("Summary") {
                SummaryRow(title: "Total", value: payroll.totalWages)

                if payroll.totalTaxes > 0 {
                    SummaryRow(title: "Total Taxes", value: payroll.totalTaxes)
                }

                SummaryRow(title: "Total Net", value: payroll.totalNet)
                    .fontWeight(.semibold)
            }
        }
    }
}

private struct EmployeeDetailRow: View {
    let employee: Employee

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(employee.name)
                    .font(.headline)
                Spacer()
                if employee.isExempt {
                    Text("Exempt")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            gridRow(title: "Total Wages", value: employee.wages)
            gridRow(title: "Taxes", value: employee.taxes)
            gridRow(title: "Net", value: employee.net)
        }
        .padding(.vertical, 4)
    }

    private func gridRow(title: String, value: Decimal) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(CurrencyFormatter.string(from: value))
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}

private struct SummaryRow: View {
    let title: String
    let value: Decimal

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(CurrencyFormatter.string(from: value))
                .monospacedDigit()
        }
    }
}
