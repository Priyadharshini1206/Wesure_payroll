//  PayrollRepository.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation

/// Coordinates the network layer and local store so the app works offline.
protocol PayrollRepository {
    func getPayrolls() async throws -> [Payroll]
    func getPayroll(id: UUID) async throws -> Payroll
    func createPayroll(employees: [Employee]) async throws -> Payroll
}

actor DefaultPayrollRepository: PayrollRepository {
    private let api: PayrollAPIClient
    private let store: PayrollStore

    init(api: PayrollAPIClient, store: PayrollStore) {
        self.api = api
        self.store = store
    }

    func getPayrolls() async throws -> [Payroll] {
        do {
            let remote = try await api.fetchPayrolls()
            let local = (try? store.loadPayrolls()) ?? []
            // Keep any payrolls created offline that are not yet on the remote.
            let merged = merge(remote: remote, local: local)
            try store.savePayrolls(merged)
            return merged
        } catch {
            let local = try store.loadPayrolls()
            if local.isEmpty {
                throw error
            }
            return local.sorted { $0.createdAt > $1.createdAt }
        }
    }

    private func merge(remote: [Payroll], local: [Payroll]) -> [Payroll] {
        var byID = Dictionary(uniqueKeysWithValues: remote.map { ($0.id, $0) })
        for payroll in local where byID[payroll.id] == nil {
            byID[payroll.id] = payroll
        }
        return byID.values.sorted { $0.createdAt > $1.createdAt }
    }

    func getPayroll(id: UUID) async throws -> Payroll {
        do {
            let remote = try await api.fetchPayroll(id: id)
            var cached = (try? store.loadPayrolls()) ?? []
            if let index = cached.firstIndex(where: { $0.id == id }) {
                cached[index] = remote
            } else {
                cached.append(remote)
            }
            try store.savePayrolls(cached)
            return remote
        } catch {
            let local = try store.loadPayrolls()
            guard let payroll = local.first(where: { $0.id == id }) else {
                throw error
            }
            return payroll
        }
    }

    func createPayroll(employees: [Employee]) async throws -> Payroll {
        let payroll = Payroll(employees: employees)

        do {
            let created = try await api.createPayroll(payroll)
            var cached = (try? store.loadPayrolls()) ?? []
            cached.insert(created, at: 0)
            try store.savePayrolls(cached)
            return created
        } catch {
            // Offline-first write: persist locally so the list updates immediately.
            var cached = (try? store.loadPayrolls()) ?? []
            cached.insert(payroll, at: 0)
            try store.savePayrolls(cached)
            return payroll
        }
    }
}
