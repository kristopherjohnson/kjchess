//
//  ChessError.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Errors thrown by the kjchess framework.
public enum ChessError: Error {
    case invalidCoordinateMove(move: String)
    case noMatchingCoordinateMoves(from: Location, to: Location)
}

// MARK:- LocalizedError

extension ChessError: LocalizedError {
    public var errorDescription: String {
        switch self {
        case .invalidCoordinateMove(let move):
            return "\"\(move)\" is not a valid move"
        case .noMatchingCoordinateMoves(let from, let to):
            return "No move available from \(from) to \(to)"
        }
    }
}
