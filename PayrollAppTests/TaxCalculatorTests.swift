//  TaxCalculatorTests.swift
//  PayrollAppTests
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import XCTest
@testable import PayrollApp

final class TaxCalculatorTests: XCTestCase {
    func testTaxesNotAppliedWhenWagesAreNotGreaterThanThreshold() {
        XCTAssertEqual(TaxCalculator.taxes(for: 900, isExempt: false), 0)
        XCTAssertEqual(TaxCalculator.taxes(for: 1_000, isExempt: false), 0)
    }

    func testTaxesNotAppliedWhenExempt() {
        XCTAssertEqual(TaxCalculator.taxes(for: 1_900, isExempt: true), 0)
    }

    func testTaxesAppliedAtFivePercent() {
        XCTAssertEqual(TaxCalculator.taxes(for: 2_000, isExempt: false), 100)
    }

    func testInterviewBriefExamplePayroll() {
        let payroll = SampleData.examplePayroll

        XCTAssertEqual(payroll.employees[0].taxes, 0)
        XCTAssertEqual(payroll.employees[0].net, 900)

        XCTAssertEqual(payroll.employees[1].taxes, 0)
        XCTAssertEqual(payroll.employees[1].net, 1_900)

        XCTAssertEqual(payroll.employees[2].taxes, 100)
        XCTAssertEqual(payroll.employees[2].net, 1_900)

        XCTAssertEqual(payroll.totalWages, 4_800)
        XCTAssertEqual(payroll.totalTaxes, 100)
        XCTAssertEqual(payroll.totalNet, 4_700)
    }
}
