//  PayrollRepositoryTests.swift
//  PayrollAppTests
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import XCTest
@testable import PayrollApp

final class PayrollRepositoryTests: XCTestCase {
    func testCreatePayrollPersistsOfflineWhenAPIFails() async throws {
        let api = MockPayrollAPIClient(
            seed: [],
            delayNanoseconds: 0,
            shouldSimulateNetworkFailure: true
        )
        let store = InMemoryPayrollStore()
        let repository = DefaultPayrollRepository(api: api, store: store)

        let created = try await repository.createPayroll(
            employees: [Employee(name: "Alex Rivera", wages: 1_200, isExempt: false)]
        )

        let cached = try store.loadPayrolls()
        XCTAssertEqual(cached.count, 1)
        XCTAssertEqual(cached.first?.id, created.id)
        XCTAssertEqual(created.totalTaxes, 60)
    }

    func testGetPayrollsFallsBackToLocalStore() async throws {
        let api = MockPayrollAPIClient(
            seed: [],
            delayNanoseconds: 0,
            shouldSimulateNetworkFailure: true
        )
        let store = InMemoryPayrollStore(payrolls: SampleData.examplePayrolls)
        let repository = DefaultPayrollRepository(api: api, store: store)

        let payrolls = try await repository.getPayrolls()
        XCTAssertEqual(payrolls.count, 1)
        XCTAssertEqual(payrolls.first?.totalNet, 4_700)
    }

    func testGetPayrollsKeepsOfflineCreatesWhenRemoteSucceeds() async throws {
        let remoteOnly = SampleData.examplePayroll
        let offlineOnly = Payroll(
            employees: [Employee(name: "Offline User", wages: 1_500, isExempt: false)]
        )
        let api = MockPayrollAPIClient(
            seed: [remoteOnly],
            delayNanoseconds: 0,
            shouldSimulateNetworkFailure: false
        )
        let store = InMemoryPayrollStore(payrolls: [offlineOnly])
        let repository = DefaultPayrollRepository(api: api, store: store)

        let payrolls = try await repository.getPayrolls()
        let ids = Set(payrolls.map(\.id))

        XCTAssertEqual(payrolls.count, 2)
        XCTAssertTrue(ids.contains(remoteOnly.id))
        XCTAssertTrue(ids.contains(offlineOnly.id))
    }
}

final class InMemoryPayrollStore: PayrollStore {
    private var payrolls: [Payroll]

    init(payrolls: [Payroll] = []) {
        self.payrolls = payrolls
    }

    func loadPayrolls() throws -> [Payroll] {
        payrolls
    }

    func savePayrolls(_ payrolls: [Payroll]) throws {
        self.payrolls = payrolls
    }
}
