//  Employee.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation

struct Employee: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var wages: Decimal
    var isExempt: Bool

    init(
        id: UUID = UUID(),
        name: String,
        wages: Decimal,
        isExempt: Bool
    ) {
        self.id = id
        self.name = name
        self.wages = wages
        self.isExempt = isExempt
    }

    var taxes: Decimal {
        TaxCalculator.taxes(for: wages, isExempt: isExempt)
    }

    var net: Decimal {
        wages - taxes
    }
}
