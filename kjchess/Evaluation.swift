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

    /// The `Position` for which this evaluation was made.
    public let position: Position

    /// Moves that can be made from this position.
    public let moves: [Move]

    /// Score based upon material.
    ///
    /// Positive value means white is ahead.
    public let materialScore: Double

    /// Score based upon material and positional factors.
    ///
    /// Positive value means white is ahead.
    public let score: Double

    /// Initializer.
    public init(_ position: Position) {
        self.position = position

        let board = position.board

        moves = position.legalMoves()

        func materialValue<S: Sequence>(_ pieces: S) -> Double
            where S.Iterator.Element == (Piece, Location)
        {
            return pieces.reduce(0.0) { $0 + $1.0.materialValue }
        }

        let whitePieces = board.pieces(player: .white)
        let blackPieces = board.pieces(player: .black)
        materialScore = materialValue(whitePieces) - materialValue(blackPieces)

        score = materialScore
    }
}

/// Extension to Piece for evaluating positions.
extension Piece {
    /// Return the material value of the piece.
    ///
    /// This evaluation uses values suggested by Tomasz Michniewski
    /// for a basic evaluation function.
    ///
    /// See <https://chessprogramming.wikispaces.com/Simplified+evaluation+function>
    /// for more details.
    public var materialValue: Double {
        switch kind {
        case .pawn:   return 1.0
        case .knight: return 3.2
        case .bishop: return 3.3
        case .rook:   return 5.0
        case .queen:  return 9.0
        case .king:   return 20000.0
        }
    }
}
