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
    // just play a simple opening, or pick a random move.
    do {
        let b = position.board
        switch position.toMove {
        case .white:
            if b[e2] == WP && b[e3] == nil && b[e4] == nil {
                return try position.find(coordinateMove: "e2e4")
            }
            else if b[g1] == WN && b[f3] == nil {
                return try position.find(coordinateMove: "g1f3")
            }
        case .black:
            if b[e7] == BP && b[e6] == nil && b[e5] == nil {
                return try position.find(coordinateMove: "e7e5")
            }
            else if b[b8] == BN && b[c6] == nil {
                return try position.find(coordinateMove: "b8c6")
            }
        }
    }
    catch (let error) {
        assertionFailure("Unable to find move: \(error.localizedDescription)")
    }

    let legalMoves = position.legalMoves()

    let evaluations = legalMoves.map { ($0, Evaluation(position.after($0))) }
    if evaluations.isEmpty {
        return nil
    }

    let score = bestScore(player: position.toMove, evaluations: evaluations)
    let bestEvaluations = evaluations.filter { $0.1.score == score }
    return bestEvaluations.randomPick().map { $0.0 }
}

private func bestScore(player: Player, evaluations: [(Move, Evaluation)]) -> Double {
    switch player {
    case .white:
        return evaluations.map { $0.1.score }.max() ?? 0.0
    case .black:
        return evaluations.map { $0.1.score }.min() ?? 0.0
    }
}
