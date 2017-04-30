//
//  bestMove.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Return the best move for the specified position.
///
/// - parameter position: The `Position` for which a move should be found.
/// - parameter searchDepth: Minimax search depth.
/// - parameter concurrentTasks: Number of asynchronous minimax tasks to run.
///
/// - returns: A `Move`, the score, and the principal variation, or `nil` if there are no legal moves.
public func bestMove(position: Position, searchDepth: Int = 1, concurrentTasks: Int = 1)
    -> (Move, Double, [Move])?
{
    var moves = position.legalMoves()
    moves.shuffle()

    var bestMoves = [(Move, [Move])]()
    var bestScore: Double

    let queue = DispatchQueue(label: "bestMove")
    let group = DispatchGroup()

    let semaphore = DispatchSemaphore(value: concurrentTasks)

    switch position.toMove {
    case .white:
        bestScore = -Double.infinity
        for move in moves {
            DispatchQueue.global().async(group: group) {
                semaphore.wait()
                var newPosition = position.after(move)
                let (moveScore, movePV) = minimaxSearch(position: &newPosition,
                                                        depth: searchDepth - 1,
                                                        alpha: -Double.infinity,
                                                        beta: Double.infinity)
                semaphore.signal()
                queue.sync {
                    if moveScore > bestScore {
                        bestScore = moveScore
                        bestMoves = [(move, movePV.prepending(move))]
                    }
                    else if moveScore == bestScore {
                        bestMoves.append((move, movePV.prepending(move)))
                    }
                }
            }
        }
    case .black:
        bestScore = Double.infinity
        for move in moves {
            DispatchQueue.global().async(group: group) {
                semaphore.wait()
                var newPosition = position.after(move)
                let (moveScore, movePV) = minimaxSearch(position: &newPosition,
                                                        depth: searchDepth - 1,
                                                        alpha: -Double.infinity,
                                                        beta: Double.infinity)
                semaphore.signal()
                queue.sync {
                    if moveScore < bestScore {
                        bestScore = moveScore
                        bestMoves = [(move, movePV.prepending(move))]
                    }
                    else if moveScore == bestScore {
                        bestMoves.append((move, movePV.prepending(move)))
                    }
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

/// Search for best move from the specified position.
///
/// This function mutates the position while evaluating moves.
/// When it returns, the position will match its original
/// state.
private func minimaxSearch(position: inout Position, depth: Int, alpha: Double, beta: Double)
    -> (Double, [Move])
{
    if depth < 1 {
        return (evaluate(position: position), [])
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
            let undo = position.apply(move)
            let (moveScore, movePV) = minimaxSearch(position: &position,
                                                    depth: d,
                                                    alpha: a,
                                                    beta: b)
            position.unapply(undo)

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
            let undo = position.apply(move)
            let (moveScore, movePV) = minimaxSearch(position: &position,
                                                    depth: d,
                                                    alpha: a,
                                                    beta: b)
            position.unapply(undo)

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
    if lhs.isCapture {
        if !rhs.isCapture {
            // Captures before non-captures
            return true
        }

        // If both captures, order by material value of the captured piece.
        return lhs.capturedPiece!.materialValue > rhs.capturedPiece!.materialValue
    }
    else {
        return false
    }
}
