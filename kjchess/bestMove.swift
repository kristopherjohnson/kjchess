//
//  bestMove.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Return the best move for the specified position.
///
/// - returns: A `Move`, the score, and the principal variation, or `nil` if there are no legal moves.
public func bestMove(position: Position, searchDepth: Int = 1) -> (Move, Double, [Move])? {

    var moves = position.legalMoves()
    moves.sort(by: capturesFirst)

    var bestMoves = [(Move, [Move])]()
    var bestScore: Double

    let queue = DispatchQueue(label: "bestMove")
    let group = DispatchGroup()

    switch position.toMove {
    case .white:
        bestScore = -Double.infinity
        for move in moves {
            group.enter()
            DispatchQueue.global().async {
                let (moveScore, movePV) = minimaxSearch(position: position.after(move),
                                                        depth: searchDepth - 1,
                                                        alpha: -Double.infinity,
                                                        beta: Double.infinity)
                queue.sync {
                    if moveScore > bestScore {
                        bestScore = moveScore
                        bestMoves = [(move, movePV.prepending(move))]
                    }
                    else if moveScore == bestScore {
                        bestMoves.append((move, movePV.prepending(move)))
                    }
                    group.leave()
                }
            }
        }
    case .black:
        bestScore = Double.infinity
        for move in moves {
            group.enter()
            DispatchQueue.global().async {
                let (moveScore, movePV) = minimaxSearch(position: position.after(move),
                                                        depth: searchDepth - 1,
                                                        alpha: -Double.infinity,
                                                        beta: Double.infinity)
                queue.sync {
                    if moveScore < bestScore {
                        bestScore = moveScore
                        bestMoves = [(move, movePV.prepending(move))]
                    }
                    else if moveScore == bestScore {
                        bestMoves.append((move, movePV.prepending(move)))
                    }
                    group.leave()
                }
            }
        }
    }

    group.wait()

    if let (move, movePV) = bestMoves.randomPick() {
        return (move, bestScore, movePV)
    }
    else {
        return nil
    }
}

private func minimaxSearch(position: Position, depth: Int, alpha: Double, beta: Double)
    -> (Double, [Move]) {

    if depth < 1 {
        let evaluation = Evaluation(position)
        return (evaluation.score, [])
    }

    var moves = position.legalMoves()
    moves.sort(by: capturesFirst)

    var bestScore: Double
    var pv: [Move] = []

    var a = alpha
    var b = beta
    let d = depth - 1

    switch position.toMove {
    case .white:
        bestScore = -Double.infinity
        for move in moves {
            let (moveScore, movePV) = minimaxSearch(position: position.after(move),
                                                   depth: d,
                                                   alpha: a,
                                                   beta: b)
            if moveScore > bestScore {
                bestScore = moveScore
                pv = movePV.prepending(move)
            }
            a = max(a, bestScore)
            if b <= a {
                break // beta cut-off
            }
        }
    case .black:
        bestScore = Double.infinity
        for move in moves {
            let (moveScore, movePV) = minimaxSearch(position: position.after(move),
                                                    depth: d,
                                                    alpha: a,
                                                    beta: b)
            if moveScore < bestScore {
                bestScore = moveScore
                pv = movePV.prepending(move)
            }
            b = min(b, bestScore)
            if b <= a {
                break // alpha cut-off
            }
        }
    }

    return (bestScore, pv)
}

/// Predicate used to sort Move arrays so that captures come before non-capture moves.
///
/// Such an ordering should lead to better alpha-beta pruning.
private func capturesFirst(lhs: Move, rhs: Move) -> Bool {
    return lhs.isCapture && !rhs.isCapture
}
