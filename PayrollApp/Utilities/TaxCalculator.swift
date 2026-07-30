//  TaxCalculator.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation

enum TaxCalculator {
    /// Tax rate applied when wages exceed the threshold and the employee is not exempt.
    static let rate: Decimal = Decimal(string: "0.05")!
    /// Wages must be strictly greater than this amount for tax to apply.
    static let wageThreshold: Decimal = 1_000

    /// If wages > 1,000 and the employee is not exempt, apply 5% tax.
    static func taxes(for wages: Decimal, isExempt: Bool) -> Decimal {
        guard !isExempt, wages > wageThreshold else {
            return 0
        }
        return (wages * rate).rounded(scale: 2)
    }
}

extension Decimal {
    func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, mode)
        return result
    }
}
