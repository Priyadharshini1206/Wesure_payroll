//  PayrollAPIClient.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation

/// Network abstraction for payroll operations.
/// Concrete implementations can talk to a real backend or a local mock.
protocol PayrollAPIClient {
    func fetchPayrolls() async throws -> [Payroll]
    func fetchPayroll(id: UUID) async throws -> Payroll
    func createPayroll(_ payroll: Payroll) async throws -> Payroll
}

/// Simulates a remote API with artificial latency and an in-memory store.
/// Data is also mirrored through `PayrollStore` for offline use.
actor MockPayrollAPIClient: PayrollAPIClient {
    private var payrolls: [Payroll]
    private let delayNanoseconds: UInt64
    private let shouldSimulateNetworkFailure: Bool

    init(
        seed: [Payroll] = SampleData.examplePayrolls,
        delayNanoseconds: UInt64 = 350_000_000,
        shouldSimulateNetworkFailure: Bool = false
    ) {
        self.payrolls = seed
        self.delayNanoseconds = delayNanoseconds
        self.shouldSimulateNetworkFailure = shouldSimulateNetworkFailure
    }

    func fetchPayrolls() async throws -> [Payroll] {
        try await simulateNetwork()
        return payrolls.sorted { $0.createdAt > $1.createdAt }
    }

    func fetchPayroll(id: UUID) async throws -> Payroll {
        try await simulateNetwork()
        guard let payroll = payrolls.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return payroll
    }

    func createPayroll(_ payroll: Payroll) async throws -> Payroll {
        try await simulateNetwork()
        guard !payroll.employees.isEmpty else {
            throw APIError.invalidRequest("A payroll must include at least one employee.")
        }
        payrolls.insert(payroll, at: 0)
        return payroll
    }

    private func simulateNetwork() async throws {
        try await Task.sleep(nanoseconds: delayNanoseconds)
        if shouldSimulateNetworkFailure {
            throw APIError.networkUnavailable
        }
    }
}
