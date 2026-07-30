//  PayrollStore.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation

/// Local persistence used for offline support.
protocol PayrollStore {
    func loadPayrolls() throws -> [Payroll]
    func savePayrolls(_ payrolls: [Payroll]) throws
}

final class FilePayrollStore: PayrollStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager

    init(
        fileName: String = "payrolls.json",
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = documents.appendingPathComponent(fileName)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func loadPayrolls() throws -> [Payroll] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([Payroll].self, from: data)
    }

    func savePayrolls(_ payrolls: [Payroll]) throws {
        let data = try encoder.encode(payrolls)
        try data.write(to: fileURL, options: [.atomic])
    }
}
