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

    /// Kinds to which a pawn can be promoted.
    public static let promotionKinds: [PieceKind]
        = [.knight, .bishop, .rook, .queen]

    /// Return alphabetic character to represent piece kind.
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

    /// Return lowercase alphabetic character to represent piece kind.
    public var lowercaseSymbol: String {
        switch self {
        case .pawn:   return "p"
        case .knight: return "n"
        case .bishop: return "b"
        case .rook:   return "r"
        case .queen:  return "q"
        case .king:   return "k"
        }
    }

    /// Given a character, return associated `PieceKind`.
    ///
    /// - returns: `nil` if character is not a valid piece kind.
    static func fromCharacter(_ character: Character) -> PieceKind? {
        switch character {
        case "P", "p", "♙", "♟": return .pawn
        case "N", "n", "♘", "♞": return .knight
        case "B", "b", "♗", "♝": return .bishop
        case "R", "r", "♖", "♜": return .rook
        case "Q", "q", "♕", "♛": return .queen
        case "K", "k", "♔", "♚": return .king
        default:  return nil
        }
    }

}

extension PieceKind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pawn:   return "pawn"
        case .knight: return "knight"
        case .bishop: return "bishop"
        case .rook:   return "rook"
        case .queen:  return "queen"
        case .king:   return "king"
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

    /// Return Unicode character for this piece.
    public var figurine: String {
        switch (player, kind) {
        case (.white, .king):   return "♔"
        case (.white, .queen):  return "♕"
        case (.white, .rook):   return "♖"
        case (.white, .bishop): return "♗"
        case (.white, .knight): return "♘"
        case (.white, .pawn):   return "♙"
        case (.black, .king):   return "♚"
        case (.black, .queen):  return "♛"
        case (.black, .rook):   return "♜"
        case (.black, .bishop): return "♝"
        case (.black, .knight): return "♞"
        case (.black, .pawn):   return "♟"
        }
    }
}

extension Piece: CustomStringConvertible {
    public var description: String {
        return "\(player) \(kind)"
    }
}

extension Piece: CustomDebugStringConvertible {
    public var debugDescription: String {
        return symbol
    }
}

extension Piece: Equatable {}
public func ==(lhs: Piece, rhs: Piece) -> Bool {
    return lhs.player == rhs.player && lhs.kind == rhs.kind
}
public func ==(lhs: Piece?, rhs: Piece?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let l), .some(let r)):
        return l == r
    case (.none, .none):
        return true
    default:
        return false
    }
}

extension Piece: Hashable {
    public var hashValue: Int {
        return (player.hashValue << 3) | kind.hashValue
    }
}

public let WP = Piece(.white, .pawn)
public let WN = Piece(.white, .knight)
public let WB = Piece(.white, .bishop)
public let WR = Piece(.white, .rook)
public let WQ = Piece(.white, .queen)
public let WK = Piece(.white, .king)

public let BP = Piece(.black, .pawn)
public let BN = Piece(.black, .knight)
public let BB = Piece(.black, .bishop)
public let BR = Piece(.black, .rook)
public let BQ = Piece(.black, .queen)
public let BK = Piece(.black, .king)
