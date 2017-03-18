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
    case promote(player: Player, from: Location, to: Location, promotedPiece: Piece)
    case promoteCapture(player: Player, from: Location, to: Location, capturedPiece: Piece, promotedPiece: Piece)
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

        case .promote(let player, _, _, _),
             .promoteCapture(let player, _, _, _, _),
             .castleKingside(let player),
             .castleQueenside(let player),
             .resign(let player):
            return player
        }
    }

    /// Return the `Piece` that made the move.
    public var piece: Piece {
        switch self {

        case .move(let piece, _, _),
             .capture(let piece, _, _, _),
             .enPassantCapture(let piece, _, _, _):
            return piece

        case .promote(let player, _, _, _),
             .promoteCapture(let player, _, _, _, _):
            return Piece(player, .pawn)

        case.castleKingside(let player),
            .castleQueenside(let player),
            .resign(let player):
            return Piece(player, .king)
        }
    }

    /// Return the "from" `Location` for this move.
    ///
    /// For most moves, this is the location where
    /// the piece moved from.
    ///
    /// For castling moves, this is the location where
    /// the king started.
    ///
    /// For resignation, this is the initial location of
    /// the king.  (This value is not really useful, but
    /// we have to return something.)
    public var from: Location {
        switch self {

        case .move(_, let from, _),
             .capture(_, let from, _, _),
             .promote(_, let from, _, _),
             .promoteCapture(_, let from, _, _, _),
             .enPassantCapture(_, let from, _, _):
            return from

        case .castleKingside(let player),
             .castleQueenside(let player),
             .resign(let player):
            switch player {
            case .white: return e1
            case .black: return e8
            }
        }
    }

    /// Return the "to" `Location` for this move.
    ///
    /// For most moves, this is the location where
    /// the piece ended its move.
    ///
    /// For castling moves, this is the location where
    /// the king arrived.
    ///
    /// For resignation, this is the initial location of
    /// the king.  (This value is not really useful, but
    /// we have to return something.)
    public var to: Location {
        switch self {
        case .move(_, _, let to),
             .capture(_, _, let to, _),
             .promote(_, _, let to, _),
             .promoteCapture(_, _, let to, _, _),
             .enPassantCapture(_, _, let to, _):
            return to
        case .castleKingside(let player):
            switch player {
            case .white: return g1
            case .black: return g8
            }
        case .castleQueenside(let player):
            switch player {
            case .white: return c1
            case .black: return c8
            }
        case .resign(let player):
            switch player {
            case .white: return e1
            case .black: return e8
            }
        }
    }

    public var isCastle: Bool {
        switch self {
        case .castleKingside,
             .castleQueenside:
            return true
        default:
            return false
        }
    }

    public var isResignation: Bool {
        switch self {
        case .resign:
            return true
        default:
            return false
        }
    }

    public var isCapture: Bool {
        switch self {
        case .capture,
             .promoteCapture,
             .enPassantCapture:
            return true
        default:
            return false
        }
    }

    /// Return the captured piece, if any.
    public var capturedPiece: Piece? {
        switch self {
        case .capture(_, _, _, let capturedPiece),
             .promoteCapture(_, _, _, let capturedPiece, _),
             .enPassantCapture(_, _, _, let capturedPiece):
            return capturedPiece
        default:
            return nil
        }
    }

    public var isEnPassant: Bool {
        switch self {
        case .enPassantCapture:
            return true
        default:
            return false
        }
    }

    public var isPromotion: Bool {
        switch self {
        case .promote,
             .promoteCapture:
            return true
        default:
            return false
        }
    }

    /// Return the piece to which the pawn was promoted, if this was a promotion move.
    public var promotedPiece: Piece? {
        switch self {
        case .promote(_, _, _, let promotedPiece),
             .promoteCapture(_, _, _, _, let promotedPiece):
            return promotedPiece
        default:
            return nil
        }
    }

    /// Determine whether this move has the specified start and end location.
    public func matches(from: Location, to: Location) -> Bool {
        return from == self.from
            && to == self.to
    }

    /// Determine whether this move has the specified piece, start, and end location.
    public func matches(piece: Piece, from: Location, to: Location) -> Bool {
        return piece == self.piece
            && from == self.from
            && to == self.to
    }

    /// Determine whether this move has the specified piece kind, start, and end location.
    public func matches(kind: PieceKind, from: Location, to: Location) -> Bool {
        return kind == self.piece.kind
            && from == self.from
            && to == self.to
    }

    /// Return long-algebraic representation of a `Move`.
    public var longAlgebraicForm: String {
        
        /// Return the symbol for a piece, unless it is a
        /// pawn, in which case return an empty string.
        func symbol(_ piece: Piece) -> String {
            switch piece.kind {
            case .pawn: return ""
            default:    return piece.kind.symbol
            }
        }

        switch self {

        case let .move(piece, from, to):
            return "\(symbol(piece))\(from.symbol)-\(to.symbol)"

        case let .capture(piece, from, to, _):
            return "\(symbol(piece))\(from.symbol)x\(to.symbol)"

        case let .promote(_, from, to, promotedPiece):
            return "\(from.symbol)-\(to.symbol)\(promotedPiece.kind.symbol)"

        case let .promoteCapture(_, from, to, _, promotedPiece):
            return "\(from.symbol)x\(to.symbol)\(promotedPiece.kind.symbol)"

        case let .enPassantCapture(_, from, to, _):
            return "\(from.symbol)x\(to.symbol)e.p."

        case .castleKingside:
            return "O-O"

        case .castleQueenside:
            return "O-O-O"
            
        case .resign:
            return "resigns"
        }
    }
}

extension Move: CustomStringConvertible {
    /// Return textual representation of a `Move`.
    ///
    /// The result is similar to long algebraic notation, but
    /// includes some extra information.
    public var description: String {
        switch self {

        case let .move(piece, from, to):
            return "\(piece.symbol)\(from.symbol)-\(to.symbol)"

        case let .capture(piece, from, to, capturedPiece):
            return "\(piece.symbol)\(from.symbol)x\(capturedPiece.kind.symbol)\(to.symbol)"

        case let .promote(player, from, to, promotedPiece):
            return "\(player.symbol)P\(from.symbol)-\(to.symbol)\(promotedPiece.kind.symbol)"

        case let .promoteCapture(player, from, to, capturedPiece, promotedPiece):
            return "\(player.symbol)P\(from.symbol)x\(capturedPiece.kind.symbol)\(to.symbol)\(promotedPiece.kind.symbol)"

        case let .enPassantCapture(piece, from, to, capturedPiece):
            return "\(piece.symbol)\(from.symbol)x\(capturedPiece.kind.symbol)\(to.symbol)e.p."

        case let .castleKingside(player):
            return "\(player.symbol) O-O"

        case .castleQueenside:
            return "\(player.symbol) O-O-O"

        case .resign:
            return "\(player.symbol) resigns"
        }
    }
}
