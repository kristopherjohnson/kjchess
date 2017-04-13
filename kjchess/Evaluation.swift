//
//  Evaluation.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// An evaluation of the score for a position.
///
/// Evaluations can change as a search proceeds.
public class Evaluation {

    public let position: Position
    public let whitePieces: [(Piece, Location)]
    public let blackPieces: [(Piece, Location)]
    public let moves: [Move]
    public let materialScore: Double

    public init(_ position: Position) {
        self.position = position

        let board = position.board
        whitePieces = Array(board.pieces(player: .white))
        blackPieces = Array(board.pieces(player: .black))

        moves = Array(position.legalMoves())

        func materialValue(_ pieces: [(Piece, Location)]) -> Double {
            return pieces.reduce(0.0) { $0 + $1.0.materialValue }
        }

        materialScore = materialValue(whitePieces) - materialValue(blackPieces)
    }
}

/// Extension to Piece for evaluating positions.
extension Piece {
    /// Return the material value of the piece.
    public var materialValue: Double {
        switch kind {
        case .pawn:   return 1
        case .knight: return 3
        case .bishop: return 3
        case .rook:   return 5
        case .queen:  return 9
        case .king:   return 1000
        }
    }
}
