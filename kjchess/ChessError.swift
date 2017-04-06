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
    case noMatchingCoordinateMoves(from: Location, to: Location, promotedKind: PieceKind?)
}

// MARK:- LocalizedError

extension ChessError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCoordinateMove(let move):
            return "\"\(move)\" is not a valid move"
        case .noMatchingCoordinateMoves(let from, let to, let promotedKind):
            return "\(from)\(to)\(promotedKind?.lowercaseSymbol ?? "") is not valid from this position"
        }
    }
}
