//  Payroll.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation

struct Payroll: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let createdAt: Date
    var employees: [Employee]

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        employees: [Employee]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.employees = employees
    }

    var employeeCount: Int {
        employees.count
    }

    var totalWages: Decimal {
        employees.reduce(0) { $0 + $1.wages }
    }

    var totalTaxes: Decimal {
        employees.reduce(0) { $0 + $1.taxes }
    }

    var totalNet: Decimal {
        employees.reduce(0) { $0 + $1.net }
    }
}
