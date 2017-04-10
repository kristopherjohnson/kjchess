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
    case fenStringRequiresExactlySixFields(fen: String)
    case fenStringRequiresExactlyEightRanks(fenBoard: String)
    case fenBoardContainsInvalidCharacter(character: Character)
    case fenInvalidPlayerToMove(fenPlayerToMove: String)
    case fenInvalidHalfmoveClock(fenHalfmoveClock: String)
    case fenInvalidMoveNumber(fenMoveNumber: String)
}

// MARK:- LocalizedError

extension ChessError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCoordinateMove(let move):
            return "\"\(move)\" is not a valid move"
        case .noMatchingCoordinateMoves(let from, let to, let promotedKind):
            return "\(from)\(to)\(promotedKind?.lowercaseSymbol ?? "") is not valid from this position"
        case .fenStringRequiresExactlySixFields(let fen):
            return "FEN string does not have six fields: \"\(fen)\""
        case .fenStringRequiresExactlyEightRanks(let fenBoard):
            return "FEN board does not have eight ranks: \"\(fenBoard)\""
        case .fenBoardContainsInvalidCharacter(let character):
            return "FEN board contains unexpected character \"\(character)\""
        case .fenInvalidPlayerToMove(let fenPlayerToMove):
            return "FEN contains unexpected player-to-move value: \"\(fenPlayerToMove)\""
        case .fenInvalidHalfmoveClock(let fenHalfmoveClock):
            return "FEN contains invalid halfmove clock: \"\(fenHalfmoveClock)\""
        case .fenInvalidMoveNumber(let fenMoveNumber):
            return "FEN contains invalid move number: \"\(fenMoveNumber)\""
        }
    }
}
