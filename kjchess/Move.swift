//
//  Move.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

/// A chess move.
public enum Move {

    case move(
        piece: Piece,
        from: Location,
        to: Location)

    case capture(
        piece: Piece,
        from: Location,
        to: Location,
        captured: PieceKind)

    case promote(
        player: Player,
        from: Location,
        to: Location,
        promoted: PieceKind)

    case promoteCapture(
        player: Player,
        from: Location,
        to: Location,
        captured: PieceKind,
        promoted: PieceKind)

    case enPassantCapture(
        player: Player,
        from: Location,
        to: Location)

    case castleKingside(
        player: Player)

    case castleQueenside(
        player: Player)

    case resign(
        player: Player)

    /// Return the `Player` that made the move.
    public var player: Player {
        switch self {

        case .move(let piece, _, _),
             .capture(let piece, _, _, _):
            return piece.player

        case .promote(let player, _, _, _),
             .promoteCapture(let player, _, _, _, _),
             .enPassantCapture(let player, _, _),
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
             .capture(let piece, _, _, _):
            return piece

        case .promote(let player, _, _, _),
             .promoteCapture(let player, _, _, _, _),
             .enPassantCapture(let player, _, _):
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
             .enPassantCapture(_, let from, _):
            return from

        case .castleKingside(let player),
             .castleQueenside(let player),
             .resign(let player):
            switch player {
            case .white: return e1
            case .black: return e8
            case .empty:
                assert(false)
                return a1
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
             .enPassantCapture(_, _, let to):
            return to
        case .castleKingside(let player):
            switch player {
            case .white: return g1
            case .black: return g8
            case .empty:
                assert(false)
                return a1
            }
        case .castleQueenside(let player):
            switch player {
            case .white: return c1
            case .black: return c8
            case .empty:
                assert(false)
                return a1
            }
        case .resign(let player):
            switch player {
            case .white: return e1
            case .black: return e8
            case .empty:
                assert(false)
                return a1
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

    public var capturedKind: PieceKind? {
        switch self {
        case .capture(_, _, _, let captured),
             .promoteCapture(_, _, _, let captured, _):
            return captured
        case .enPassantCapture:
            return .pawn
        default:
            return nil
        }
    }

    public var capturedPiece: Piece? {
        if let kind = capturedKind {
            return Piece(player.opponent, kind)
        }
        else {
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

    /// Return the piece kind to which the pawn was promoted, if this was a promotion move.
    public var promotedKind: PieceKind? {
        switch self {
        case .promote(_, _, _, let promoted),
             .promoteCapture(_, _, _, _, let promoted):
            return promoted
        default:
            return nil
        }
    }

    /// Return the piece to which the pawn was promoted, if this was a promotion move.
    public var promotedPiece: Piece? {
        if let kind = promotedKind {
            return Piece(player, kind)
        }
        else {
            return nil
        }
    }

    /// Determine whether this move has the given start and end location.
    public func matches(from: Location, to: Location) -> Bool {
        return from == self.from
            && to == self.to
    }

    /// Determine whether this move has the given piece, start, and end location.
    public func matches(piece: Piece, from: Location, to: Location) -> Bool {
        return piece == self.piece
            && from == self.from
            && to == self.to
    }

    /// Determine whether this move has the given piece, start and end location, and isCapture property value.
    public func matches(piece: Piece, from: Location, to: Location, isCapture: Bool) -> Bool {
        return piece == self.piece
            && from == self.from
            && to == self.to
            && isCapture == self.isCapture
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

        case let .promote(_, from, to, promotedKind):
            return "\(from.symbol)-\(to.symbol)\(promotedKind.symbol)"

        case let .promoteCapture(_, from, to, _, promotedKind):
            return "\(from.symbol)x\(to.symbol)\(promotedKind.symbol)"

        case let .enPassantCapture(_, from, to):
            return "\(from.fileSymbol)x\(to.symbol)e.p."

        case .castleKingside:
            // Note: Capital O's (to be compatible with PGN), not zeroes.
            return "O-O"

        case .castleQueenside:
            // Note: Capital O's (to be compatible with PGN), not zeroes.
            return "O-O-O"
            
        case .resign:
            return "resigns"
        }
    }

    /// Return UCI representation of a `Move`.
    ///
    /// The UCI representation of a move is the `from`
    /// location and `to`, without hyphens or other separators.
    ///
    /// Examples: "e2e4", "e7e5", "e1g1" (castling), "e7e8q" (promotion).
    public var coordinateForm: String {

        switch self {

        case let .move(_, from, to):
            return "\(from.symbol)\(to.symbol)"

        case let .capture(_, from, to, _):
            return "\(from.symbol)\(to.symbol)"

        case let .promote(_, from, to, promoted):
            return "\(from.symbol)\(to.symbol)\(promoted.lowercaseSymbol)"

        case let .promoteCapture(_, from, to, _, promoted):
            return "\(from.symbol)\(to.symbol)\(promoted.lowercaseSymbol)"

        case let .enPassantCapture(_, from, to):
            return "\(from.symbol)\(to.symbol)"

        case .castleKingside(let player):
            switch player {
            case .white: return "e1g1"
            case .black: return "e8g8"
            case .empty:
                assert(false)
                return "0000"
            }

        case .castleQueenside(let player):
            switch player {
            case .white: return "e1c1"
            case .black: return "e8c8"
            case .empty:
                assert(false)
                return "0000"
            }

        case .resign:
            return "0000"
        }
    }
}

// MARK:- CustomStringConvertible

extension Move: CustomStringConvertible {
    /// Return textual representation of a `Move`.
    ///
    /// The result is similar to long algebraic notation, but
    /// includes some extra information, like "W" or "B" to
    /// indicate the player, and the captured piece if any.
    public var description: String {
        switch self {

        case let .move(piece, from, to):
            return "\(piece.symbol)\(from.symbol)-\(to.symbol)"

        case let .capture(piece, from, to, captured):
            return "\(piece.symbol)\(from.symbol)x\(captured.symbol)\(to.symbol)"

        case let .promote(player, from, to, promoted):
            return "\(player.symbol)P\(from.symbol)-\(to.symbol)\(promoted.symbol)"

        case let .promoteCapture(player, from, to, captured, promoted):
            return "\(player.symbol)P\(from.symbol)x\(captured.symbol)\(to.symbol)\(promoted.symbol)"

        case let .enPassantCapture(_, from, to):
            return "\(piece.symbol)\(from.symbol)xP\(to.symbol)e.p."

        case let .castleKingside(player):
            return "\(player.symbol) O-O"

        case .castleQueenside:
            return "\(player.symbol) O-O-O"

        case .resign:
            return "\(player.symbol) resigns"
        }
    }
}

// MARK:- Equatable

extension Move: Equatable {}

public func ==(lhs: Move, rhs: Move) -> Bool {
    switch (lhs, rhs) {

    case let (.move(l0, l1, l2), .move(r0, r1, r2)):
        return l0 == r0
            && l1 == r1
            && l2 == r2

    case let (.capture(l0, l1, l2, l3), .capture(r0, r1, r2, r3)):
        return l0 == r0
            && l1 == r1
            && l2 == r2
            && l3 == r3

    case let (.promote(l0, l1, l2, l3), .promote(r0, r1, r2, r3)):
        return l0 == r0
            && l1 == r1
            && l2 == r2
            && l3 == r3

    case let (.promoteCapture(l0, l1, l2, l3, l4), .promoteCapture(r0, r1, r2, r3, r4)):
        return l0 == r0
            && l1 == r1
            && l2 == r2
            && l3 == r3
            && l4 == r4

    case let (.enPassantCapture(l0, l1, l2), .enPassantCapture(r0, r1, r2)):
        return l0 == r0
            && l1 == r1
            && l2 == r2

    case let (.castleKingside(l0), .castleKingside(r0)),
         let (.castleQueenside(l0), .castleQueenside(r0)),
         let (.resign(l0), .resign(r0)):
        return l0 == r0

    default:
        return false
    }
}

// MARK: Hashable

extension Move: Hashable {
    public var hashValue: Int {
        return (from.hashValue << 8) | to.hashValue
    }
}
