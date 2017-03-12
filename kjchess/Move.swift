//
//  Move.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// A chess move.
public enum Move {
    case move(piece: Piece, from: Location, to: Location)
    case capture(piece: Piece, from: Location, to: Location, capturedPiece: Piece)
    case enPassantCapture(piece: Piece, from: Location, to: Location, capturedPiece: Piece)
    case castleKingside(player: Player)
    case castleQueenside(player: Player)
    case resign(player: Player)

    /// Return the `Player` that made the move.
    public var player: Player {
        switch self {
        case .move(let piece, _, _),
             .capture(let piece, _, _, _),
             .enPassantCapture(let piece, _, _, _):
            return piece.player
        case .castleKingside(let player),
             .castleQueenside(let player),
             .resign(let player):
            return player
        }
    }
}

extension Move: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .move(piece, from, to):
            return "\(piece.symbol)\(from.symbol)-\(to.symbol)"
        case let .capture(piece, from, to, capturedPiece):
            return "\(piece.symbol)\(from.symbol)x\(capturedPiece.symbol)\(to.symbol)"
        case let .enPassantCapture(piece, from, to, capturedPiece):
            return "\(piece.symbol)\(from.symbol)x\(capturedPiece.symbol)\(to.symbol)e.p."
        case .castleKingside:
            return "O-O"
        case .castleQueenside:
            return "O-O-O"
        case .resign:
            return "resigns"
        }
    }
}
