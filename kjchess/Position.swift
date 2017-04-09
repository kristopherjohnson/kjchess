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

    /// Initializer.
    public init(board: Board,
                toMove: Player,
                moves: [Move],
                whiteCanCastleKingside: Bool = true,
                whiteCanCastleQueenside: Bool = true,
                blackCanCastleKingside: Bool = true,
                blackCanCastleQueenside: Bool = true)
    {
        self.board = board
        self.toMove = toMove
        self.moves = moves
        self.whiteCanCastleKingside = whiteCanCastleKingside
        self.whiteCanCastleQueenside = whiteCanCastleQueenside
        self.blackCanCastleKingside = blackCanCastleKingside
        self.blackCanCastleQueenside = blackCanCastleQueenside
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

        let (newWhiteCanCastleKingside,
             newWhiteCanCastleQueenside,
             newBlackCanCastleKingside,
             newBlackCanCastleQueenside) = castlingState(after: move)
        
        return Position(board: newBoard,
                        toMove: newToMove,
                        moves: newMoves,
                        whiteCanCastleKingside: newWhiteCanCastleKingside,
                        whiteCanCastleQueenside: newWhiteCanCastleQueenside,
                        blackCanCastleKingside: newBlackCanCastleKingside,
                        blackCanCastleQueenside: newBlackCanCastleQueenside)
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
}

// MARK:- Equatable

extension Position: Equatable {}
public func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.board == rhs.board
        && lhs.toMove == rhs.toMove
        && lhs.moves == rhs.moves
        && lhs.whiteCanCastleKingside == rhs.whiteCanCastleKingside
        && lhs.whiteCanCastleQueenside == rhs.whiteCanCastleQueenside
        && lhs.blackCanCastleKingside == rhs.blackCanCastleKingside
        && lhs.blackCanCastleQueenside == rhs.blackCanCastleQueenside
}

