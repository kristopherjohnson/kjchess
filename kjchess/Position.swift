//
//  Position.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// A chess position.
///
/// Contains the current board layout, the player to move,
/// and complete history of moves.
public struct Position {
    // Important: When data members are added, be sure to update func ==()
    // at the bottom of this file.

    public let board: Board
    public let toMove: Player

    public let moves: [Move]

    // These flags are false if the associated king or rook has been moved.
    // Their states do not reflect whether a castling move is legal based
    // upon piece locations.
    public let whiteCanCastleKingside: Bool
    public let whiteCanCastleQueenside: Bool
    public let blackCanCastleKingside: Bool
    public let blackCanCastleQueenside: Bool

    /// En-passant target square
    ///
    /// Set whenever previous move was a two-square pawn move.
    ///
    /// This is set even if there is no pawn in position to make the en-passant capture.
    public let enPassantCaptureLocation: Location?

    /// Number of halfmoves since the last capture or pawn advance.
    public let halfmoveClock: Int

    /// The number of the full move.
    ///
    /// Incremented after Black's move.
    public let moveNumber: Int

    /// Initializer.
    public init(board: Board,
                toMove: Player,
                moves: [Move],
                enPassantCaptureLocation: Location? = nil,
                whiteCanCastleKingside: Bool = true,
                whiteCanCastleQueenside: Bool = true,
                blackCanCastleKingside: Bool = true,
                blackCanCastleQueenside: Bool = true,
                halfmoveClock: Int = 0,
                moveNumber: Int = 1)
    {
        self.board = board
        self.toMove = toMove
        self.moves = moves
        self.enPassantCaptureLocation = enPassantCaptureLocation
        self.whiteCanCastleKingside = whiteCanCastleKingside
        self.whiteCanCastleQueenside = whiteCanCastleQueenside
        self.blackCanCastleKingside = blackCanCastleKingside
        self.blackCanCastleQueenside = blackCanCastleQueenside
        self.halfmoveClock = halfmoveClock
        self.moveNumber = moveNumber
    }

    /// Return position for the start of a new game.
    public static func newGame() -> Position {
        return Position(board: Board.newGame, toMove: .white, moves: [])
    }

    /// Return new position after applying a move.
    public func after(_ move: Move) -> Position {
        assert(move.player == toMove)
        
        let newBoard = board.after(move)
        let newToMove = toMove.opponent
        var newMoves = Array(moves)
        newMoves.append(move)

        let newEnPassantCaptureLocation = enPassantCaptureLocation(after: move)

        let (newWhiteCanCastleKingside,
             newWhiteCanCastleQueenside,
             newBlackCanCastleKingside,
             newBlackCanCastleQueenside) = castlingState(after: move)

        let newHalfmoveClock = halfmoveClock(after: move)

        let newMoveNumber = moveNumber(after: move)

        return Position(board: newBoard,
                        toMove: newToMove,
                        moves: newMoves,
                        enPassantCaptureLocation: newEnPassantCaptureLocation,
                        whiteCanCastleKingside: newWhiteCanCastleKingside,
                        whiteCanCastleQueenside: newWhiteCanCastleQueenside,
                        blackCanCastleKingside: newBlackCanCastleKingside,
                        blackCanCastleQueenside: newBlackCanCastleQueenside,
                        halfmoveClock: newHalfmoveClock,
                        moveNumber: newMoveNumber)
    }

    /// Get the move that led to this position.
    ///
    /// - returns: `Move` or `nil` if move information is not available.
    public var lastMove: Move? {
        return moves.last
    }

    /// Get the last move's description.
    ///
    /// - returns: Move description, or "?" if last move is unavailable.
    public var lastMoveDescription: String {
        return lastMove?.description ?? "?"
    }

    /// Get the list of moves as a space-delimited string.
    public var movesDescription: String {
        if moves.isEmpty {
            return "?"
        }
        return moves.map { $0.description }.joined(separator: " ")
    }

    /// Determine new values for the CanCastle properties after a move.
    private func castlingState(after move: Move) -> (Bool, Bool, Bool, Bool) {
        var newWhiteCanCastleKingside = whiteCanCastleKingside
        var newWhiteCanCastleQueenside = whiteCanCastleQueenside
        var newBlackCanCastleKingside = blackCanCastleKingside
        var newBlackCanCastleQueenside = blackCanCastleQueenside

        switch move.piece {
        case WK:
            newWhiteCanCastleKingside = false
            newWhiteCanCastleQueenside = false

        case BK:
            newBlackCanCastleKingside = false
            newBlackCanCastleQueenside = false

        case WR:
            if move.from == a1 {
                newWhiteCanCastleQueenside = false
            }
            else if move.from == h1 {
                newWhiteCanCastleKingside = false
            }

        case BR:
            if move.from == a8 {
                newBlackCanCastleQueenside = false
            }
            else if move.from == h8 {
                newBlackCanCastleKingside = false
            }

        default:
            break
        }

        return (newWhiteCanCastleKingside,
                newWhiteCanCastleQueenside,
                newBlackCanCastleKingside,
                newBlackCanCastleQueenside)
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
        && lhs.moves == rhs.moves
        && lhs.enPassantCaptureLocation == rhs.enPassantCaptureLocation
        && lhs.whiteCanCastleKingside == rhs.whiteCanCastleKingside
        && lhs.whiteCanCastleQueenside == rhs.whiteCanCastleQueenside
        && lhs.blackCanCastleKingside == rhs.blackCanCastleKingside
        && lhs.blackCanCastleQueenside == rhs.blackCanCastleQueenside
        && lhs.halfmoveClock == rhs.halfmoveClock
        && lhs.moveNumber == rhs.moveNumber
}

extension Position {
    /// Determine whether two Positions are equivalent, ignoring the `moves` values.
    ///
    /// This is useful for comparing a position with a FEN representation,
    /// which does not include the moves that led to the position, or
    /// identifying transpositions.
    public func isEqualDisregardingMoves(_ rhs: Position) -> Bool {
        return self.board == rhs.board
            && self.toMove == rhs.toMove
            && self.enPassantCaptureLocation == rhs.enPassantCaptureLocation
            && self.whiteCanCastleKingside == rhs.whiteCanCastleKingside
            && self.whiteCanCastleQueenside == rhs.whiteCanCastleQueenside
            && self.blackCanCastleKingside == rhs.blackCanCastleKingside
            && self.blackCanCastleQueenside == rhs.blackCanCastleQueenside
            && self.halfmoveClock == rhs.halfmoveClock
            && self.moveNumber == rhs.moveNumber
    }
}
