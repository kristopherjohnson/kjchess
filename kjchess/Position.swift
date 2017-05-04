//
//  Position.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

/// A chess position.
///
/// Contains the current board layout, the player to move,
/// and complete history of moves.
public struct Position {

    /// Information needed to undo a move applied to a Position.
    public struct MoveDelta {
        let move: Move
        let enPassantCaptureLocation: Location?
        let halfmoveClock: Int
        let moveNumber: Int
        let castlingOptions: CastlingOptions
    }
    
    // Important: When data members are added, be sure to update func ==()
    // at the bottom of this file.

    public fileprivate(set) var board: Board
    public fileprivate(set) var toMove: Player

    /// En-passant target square
    ///
    /// Set whenever previous move was a two-square pawn move.
    ///
    /// This is set even if there is no pawn in position to make the en-passant capture.
    public fileprivate(set) var enPassantCaptureLocation: Location?

    /// Number of halfmoves since the last capture or pawn advance.
    public fileprivate(set) var halfmoveClock: Int

    /// The number of the full move.
    ///
    /// Incremented after Black's move.
    public fileprivate(set) var moveNumber: Int

    // These flags are false if the associated king or rook has been moved.
    // Their states do not reflect whether a castling move is legal based
    // upon piece locations.
    public fileprivate(set) var castlingOptions: CastlingOptions

    public var whiteCanCastleKingside: Bool {
        return castlingOptions.contains(.whiteCanCastleKingside)
    }

    public var whiteCanCastleQueenside: Bool {
        return castlingOptions.contains(.whiteCanCastleQueenside)
    }
    public var blackCanCastleKingside: Bool {
        return castlingOptions.contains(.blackCanCastleKingside)
    }

    public var blackCanCastleQueenside: Bool {
        return castlingOptions.contains(.blackCanCastleQueenside)
    }

    /// Initializer.
    public init(board: Board,
                toMove: Player,
                enPassantCaptureLocation: Location? = nil,
                castlingOptions: CastlingOptions = CastlingOptions.all,
                halfmoveClock: Int = 0,
                moveNumber: Int = 1)
    {
        self.board = board
        self.toMove = toMove
        self.enPassantCaptureLocation = enPassantCaptureLocation
        self.castlingOptions = castlingOptions
        self.halfmoveClock = halfmoveClock
        self.moveNumber = moveNumber
    }

    /// Return position for the start of a new game.
    public static func newGame() -> Position {
        return Position(board: Board.newGame, toMove: .white)
    }

    /// Return new position after applying a move.
    public func after(_ move: Move) -> Position {
        var newPosition = self
        let _ = newPosition.apply(move)
        return newPosition
    }

    /// Apply a move to a position, mutating it.
    ///
    /// - returns: A `MoveDelta` that can be used to `unapply()` the move.
    public mutating func apply(_ move: Move) -> MoveDelta {
        assert(move.player == toMove)

        let delta = MoveDelta(move: move,
                              enPassantCaptureLocation: enPassantCaptureLocation,
                              halfmoveClock: halfmoveClock,
                              moveNumber: moveNumber,
                              castlingOptions: castlingOptions)

        board.apply(move)
        toMove = toMove.opponent
        enPassantCaptureLocation = enPassantCaptureLocation(after: move)
        castlingOptions = castlingOptions(after: move)
        halfmoveClock = halfmoveClock(after: move)
        moveNumber = moveNumber(after: move)

        return delta
    }

    /// Undo a move, mutating this position.
    ///
    /// Results are undefined if the given delta is not for the
    /// last move applied to the board.
    public mutating func unapply(_ delta: MoveDelta) {
        board.unapply(delta.move)
        toMove = delta.move.player
        enPassantCaptureLocation = delta.enPassantCaptureLocation
        castlingOptions = delta.castlingOptions
        halfmoveClock = delta.halfmoveClock
        moveNumber = delta.moveNumber
    }

    /// Determine new value for the `castlingOptions` property after a move.
    private func castlingOptions(after move: Move) -> CastlingOptions {
        var newCastlingOptions = castlingOptions

        switch move.piece {
        case WK:
            newCastlingOptions.remove(.whiteCanCastleKingside)
            newCastlingOptions.remove(.whiteCanCastleQueenside)

        case BK:
            newCastlingOptions.remove(.blackCanCastleKingside)
            newCastlingOptions.remove(.blackCanCastleQueenside)

        case WR:
            if move.from == a1 {
                newCastlingOptions.remove(.whiteCanCastleQueenside)
            }
            else if move.from == h1 {
                newCastlingOptions.remove(.whiteCanCastleKingside)
            }

        case BR:
            if move.from == a8 {
                newCastlingOptions.remove(.blackCanCastleQueenside)
            }
            else if move.from == h8 {
                newCastlingOptions.remove(.blackCanCastleKingside)
            }

        default:
            break
        }

        return newCastlingOptions
    }

    /// If move is a two-square pawn move, return the square behind the move destination.
    /// 
    /// - returns: `Location` behind the moved pawn, or `nil` if not a two-square pawn move.
    private func enPassantCaptureLocation(after move: Move) -> Location? {
        switch move.piece {
        case BP:
            let from = move.from
            let to = move.to
            if from.rank == 6 && to.rank == 4 {
                return Location(to.file, to.rank + 1)
            }

        case WP:
            let from = move.from
            let to = move.to
            if from.rank == 1 && to.rank == 3 {
                return Location(to.file, to.rank - 1)
            }

        default:
            break
        }

        return nil
    }

    /// Determine value of halfmove clock after given move.
    ///
    /// Resets to zero if move is a capture or pawn advance.
    /// Otherwise increments by 1.
    private func halfmoveClock(after move: Move) -> Int {
        return (move.isCapture || move.piece.kind == .pawn) ? 0 : self.halfmoveClock + 1
    }

    /// Determine value of full move number after given move.
    ///
    /// Increments after Black's move.
    private func moveNumber(after move: Move) -> Int {
        return (move.player == .black) ? self.moveNumber + 1 : self.moveNumber
    }
}

// MARK:- Equatable

extension Position: Equatable {}
public func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.board == rhs.board
        && lhs.toMove == rhs.toMove
        && lhs.enPassantCaptureLocation == rhs.enPassantCaptureLocation
        && lhs.whiteCanCastleKingside == rhs.whiteCanCastleKingside
        && lhs.whiteCanCastleQueenside == rhs.whiteCanCastleQueenside
        && lhs.blackCanCastleKingside == rhs.blackCanCastleKingside
        && lhs.blackCanCastleQueenside == rhs.blackCanCastleQueenside
        && lhs.halfmoveClock == rhs.halfmoveClock
        && lhs.moveNumber == rhs.moveNumber
}

extension Position { // MARK:- FEN

    /// Return FEN record for the position.
    public var fen: String {
        return [
            board.fen,
            fenPlayerToMove,
            fenCastlingOptions,
            fenEnPassantCaptureLocation,
            fenHalfmoveClock,
            fenMoveNumber
        ].joined(separator: " ")
    }

    /// Initialize from a FEN (Forsyth-Edwards Notation) record.
    public init(fen: String) throws {
        let tokens = fen.whitespaceSeparatedTokens()
        if tokens.count != 6 {
            throw ChessError.fenStringRequiresExactlySixFields(fen: fen)
        }

        board = try Board(fenBoard: tokens[0])

        toMove = try Position.playerToMove(fenPlayerToMove: tokens[1])

        castlingOptions = Position.castlingOptions(fenCastlingOptions: tokens[2])

        enPassantCaptureLocation = Location(tokens[3])

        if let halfmoveClock = Int(tokens[4]), halfmoveClock >= 0 {
            self.halfmoveClock = halfmoveClock
        }
        else {
            throw ChessError.fenInvalidHalfmoveClock(fenHalfmoveClock: tokens[4])
        }

        if let moveNumber = Int(tokens[5]), moveNumber > 0 {
            self.moveNumber = moveNumber
        }
        else {
            throw ChessError.fenInvalidMoveNumber(fenMoveNumber: tokens[5])
        }
    }

    private var fenPlayerToMove: String {
        switch toMove {
        case .white: return "w"
        case .black: return "b"
        }
    }

    private static func playerToMove(fenPlayerToMove: String) throws -> Player {
        switch fenPlayerToMove {
        case "w": return .white
        case "b": return .black
        default: throw ChessError.fenInvalidPlayerToMove(fenPlayerToMove: fenPlayerToMove);
        }
    }

    private var fenCastlingOptions: String {
        var result = ""

        if whiteCanCastleKingside  { result.append("K") }
        if whiteCanCastleQueenside { result.append("Q") }
        if blackCanCastleKingside  { result.append("k") }
        if blackCanCastleQueenside { result.append("q") }

        if result.isEmpty {
            return "-"
        }
        else {
            return result
        }
    }

    private static func castlingOptions(fenCastlingOptions opts: String) -> CastlingOptions {
        var castlingOptions = CastlingOptions.none

        if opts.contains("K") { castlingOptions.insert(.whiteCanCastleKingside)  }
        if opts.contains("Q") { castlingOptions.insert(.whiteCanCastleQueenside) }
        if opts.contains("k") { castlingOptions.insert(.blackCanCastleKingside)  }
        if opts.contains("q") { castlingOptions.insert(.blackCanCastleQueenside) }

        return castlingOptions
    }

    private var fenEnPassantCaptureLocation: String {
        if let location = enPassantCaptureLocation {
            return location.symbol
        }
        else {
            return "-"
        }
    }

    private var fenHalfmoveClock: String {
        return halfmoveClock.description
    }
    
    private var fenMoveNumber: String {
        return moveNumber.description
    }
}

extension Position: CustomStringConvertible {
    public var description: String {
        return fen
    }
}
