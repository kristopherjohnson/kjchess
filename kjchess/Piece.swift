//
//  Piece.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// The type of piece.
public enum PieceKind {
    case pawn
    case knight
    case bishop
    case rook
    case queen
    case king

    public var symbol: String {
        switch self {
        case .pawn:   return "P"
        case .knight: return "N"
        case .bishop: return "B"
        case .rook:   return "R"
        case .queen:  return "Q"
        case .king:   return "K"
        }
    }
}

/// A chess piece.
public struct Piece {
    public let player: Player
    public let kind: PieceKind

    public init(_ player: Player, _ kind: PieceKind) {
        self.player = player
        self.kind = kind
    }

    public var symbol: String {
        return "\(player.symbol)\(kind.symbol)"
    }
}

extension Piece: Equatable {}
public func ==(lhs: Piece, rhs: Piece) -> Bool {
    return lhs.player == rhs.player && lhs.kind == rhs.kind
}
