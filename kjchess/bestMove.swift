//
//  bestMove.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Return the best move for the specified position.
///
/// - returns: A `Move`, or `nil` if there are no legal moves.
public func bestMove(position: Position) -> Move? {

    // TODO: Let the engine search to determine the best move.  For now, we
    // just play a simple Ruy Lopez opening, or pick a random move.
    do {
        let brd = position.board
        switch position.toMove {
        case .white:
            if brd[e2] == WP && brd[e3] == nil && brd[e4] == nil {
                return try position.find(coordinateMove: "e2e4")
            }
            else if brd[g1] == WN && brd[f3] == nil {
                return try position.find(coordinateMove: "g1f3")
            }
        case .black:
            if brd[e7] == BP && brd[e6] == nil && brd[e5] == nil {
                return try position.find(coordinateMove: "e7e5")
            }
            else if brd[b8] == BN && brd[c6] == nil {
                return try position.find(coordinateMove: "b8c6")
            }
        }
    }
    catch (let error) {
        assertionFailure("Unable to find move: \(error.localizedDescription)")
    }

    let moves = Array(position.legalMoves())
    return moves.randomPick()
}
