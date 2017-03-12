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
public class Position {
    public let board: Board
    public let toMove: Player
    public let moves: [Move]

    public init(board: Board, toMove: Player, moves: [Move]) {
        self.board = board
        self.toMove = toMove
        self.moves = moves
    }

    public static func newGame() -> Position {
        return Position(board: Board.newGame, toMove: .white, moves: [])
    }
}
