//  APIError.swift
//  PayrollApp
//
//  Created by Andal Priyadharshini on 30/07/26.
//

import Foundation

enum APIError: LocalizedError, Equatable {
    case notFound
    case invalidRequest(String)
    case decodingFailed
    case networkUnavailable
    case unknown

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested payroll was not found."
        case .invalidRequest(let message):
            return message
        case .decodingFailed:
            return "Failed to decode the server response."
        case .networkUnavailable:
            return "Network is unavailable. Showing offline data."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}
