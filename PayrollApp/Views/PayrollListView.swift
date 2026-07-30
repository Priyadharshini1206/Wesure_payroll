//  PayrollListView.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import SwiftUI

struct PayrollListView: View {
    @Bindable var viewModel: PayrollListViewModel
    let repository: PayrollRepository
    @State private var isPresentingCreate = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.payrolls.isEmpty {
                ProgressView("Loading payrolls…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.payrolls.isEmpty {
                ContentUnavailableView(
                    "Unable to Load Payrolls",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if viewModel.payrolls.isEmpty {
                ContentUnavailableView(
                    "No Payrolls Yet",
                    systemImage: "doc.text",
                    description: Text("Create your first payroll to get started.")
                )
            } else {
                listContent
            }
        }
        .navigationTitle("Payrolls")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingCreate = true
                } label: {
                    Label("New Payroll", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingCreate) {
            NavigationStack {
                CreatePayrollView(
                    viewModel: CreatePayrollViewModel(repository: repository)
                ) {
                    isPresentingCreate = false
                    Task { await viewModel.refresh() }
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.load()
        }
    }

    private var listContent: some View {
        List(viewModel.payrolls) { payroll in
            NavigationLink(value: payroll) {
                PayrollRowView(payroll: payroll)
            }
        }
        .navigationDestination(for: Payroll.self) { payroll in
            PayrollDetailView(
                viewModel: PayrollDetailViewModel(
                    payrollID: payroll.id,
                    repository: repository,
                    initialPayroll: payroll
                )
            )
        }
    }
}

private struct PayrollRowView: View {
    let payroll: Payroll

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(CurrencyFormatter.string(from: payroll.createdAt))
                .font(.headline)

            HStack {
                Label("\(payroll.employeeCount) employees", systemImage: "person.2")
                Spacer()
                Text(CurrencyFormatter.string(from: payroll.totalWages))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
