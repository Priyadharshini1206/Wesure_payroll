//  SampleData.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation

enum SampleData {
    static let examplePayrollID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!

    /// Matches the interview brief example payroll.
    static let exampleEmployees: [Employee] = [
        Employee(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Sarah Mitchell",
            wages: 900,
            isExempt: false
        ),
        Employee(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "James Caldwell",
            wages: 1_900,
            isExempt: true
        ),
        Employee(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            name: "Laura Nguyen",
            wages: 2_000,
            isExempt: false
        )
    ]

    static var examplePayroll: Payroll {
        let createdAt = Calendar.current.date(
            from: DateComponents(year: 2026, month: 7, day: 28, hour: 10, minute: 0)
        ) ?? Date()

        return Payroll(
            id: examplePayrollID,
            createdAt: createdAt,
            employees: exampleEmployees
        )
    }

    static var examplePayrolls: [Payroll] {
        [examplePayroll]
    }
}
