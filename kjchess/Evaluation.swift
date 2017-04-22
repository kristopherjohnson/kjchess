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

        score = board.pieceSquareValue()
    }
}

extension Board {

    /// Calculate score based upon material and placement of pieces.
    ///
    /// This evaluation uses values suggested by Tomasz Michniewski
    /// for a basic evaluation function.
    ///
    /// See <https://chessprogramming.wikispaces.com/Simplified+evaluation+function>
    /// for more details.
    public func pieceSquareValue() -> Double {
        var score = 0.0
        for i in 0..<squares.count {
            score = score + pieceSquareValue(squareIndex: i)
        }
        return score
    }

    /// Calculate score for the piece at the given square index.
    ///
    /// The score combines the material value of the piece with
    /// a value based upon its current location.
    private func pieceSquareValue(squareIndex: Int) -> Double {
        guard let piece = squares[squareIndex] else { return 0.0 }

        let materialValue = piece.materialValue
        let squareValue = Board.squareValues(piece: piece)[squareIndex]

        let value = materialValue + squareValue

        return (piece.player == .black) ? -value : value;
    }

    /// Get array of square values for a given piece.
    private static func squareValues(piece: Piece) -> [Double] {
        switch (piece.player, piece.kind) {

        case (.white, .pawn):   return WPSquareValues
        case (.white, .knight): return WNSquareValues
        case (.white, .bishop): return WBSquareValues
        case (.white, .rook):   return WRSquareValues
        case (.white, .queen):  return WQSquareValues
        case (.white, .king):   return WKSquareValues

        case (.black, .pawn):   return BPSquareValues
        case (.black, .knight): return BNSquareValues
        case (.black, .bishop): return BBSquareValues
        case (.black, .rook):   return BRSquareValues
        case (.black, .queen):  return BQSquareValues
        case (.black, .king):   return BKSquareValues
        }
    }

    // MARK:- Piece-square tables
    
    // White Pawn
    private static let WPSquareValues = [
        0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,
        0.05, 0.10, 0.10,-0.20,-0.20, 0.10, 0.10, 0.05,
        0.05,-0.05,-0.10, 0.00, 0.00,-0.10,-0.05, 0.05,
        0.00, 0.00, 0.00, 0.20, 0.20, 0.00, 0.00, 0.00,
        0.05, 0.05, 0.10, 0.25, 0.25, 0.10, 0.05, 0.05,
        0.10, 0.10, 0.20, 0.30, 0.30, 0.20, 0.10, 0.10,
        0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50,
        0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,
    ]

    // Black Pawn
    private static let BPSquareValues = [
        0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,
        0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50,
        0.10, 0.10, 0.20, 0.30, 0.30, 0.20, 0.10, 0.10,
        0.05, 0.05, 0.10, 0.25, 0.25, 0.10, 0.05, 0.05,
        0.00, 0.00, 0.00, 0.20, 0.20, 0.00, 0.00, 0.00,
        0.05,-0.05,-0.10, 0.00, 0.00,-0.10,-0.05, 0.05,
        0.05, 0.10, 0.10,-0.20,-0.20, 0.10, 0.10, 0.05,
        0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,
    ]

    // White Knight
    private static let WNSquareValues = [
        -0.50,-0.40,-0.30,-0.30,-0.30,-0.30,-0.40,-0.50,
        -0.40,-0.20, 0.00, 0.05, 0.05, 0.00,-0.20,-0.40,
        -0.30, 0.05, 0.10, 0.15, 0.15, 0.10, 0.05,-0.30,
        -0.30, 0.00, 0.15, 0.20, 0.20, 0.15, 0.00,-0.30,
        -0.30, 0.05, 0.15, 0.20, 0.20, 0.15, 0.05,-0.30,
        -0.30, 0.00, 0.10, 0.15, 0.15, 0.10, 0.00,-0.30,
        -0.40,-0.20, 0.00, 0.00, 0.00, 0.00,-0.20,-0.40,
        -0.50,-0.40,-0.30,-0.30,-0.30,-0.30,-0.40,-0.50,
    ]

    // Black Knight
    private static let BNSquareValues = [
        -0.50,-0.40,-0.30,-0.30,-0.30,-0.30,-0.40,-0.50,
        -0.40,-0.20, 0.00, 0.00, 0.00, 0.00,-0.20,-0.40,
        -0.30, 0.00, 0.10, 0.15, 0.15, 0.10, 0.00,-0.30,
        -0.30, 0.05, 0.15, 0.20, 0.20, 0.15, 0.05,-0.30,
        -0.30, 0.00, 0.15, 0.20, 0.20, 0.15, 0.00,-0.30,
        -0.30, 0.05, 0.10, 0.15, 0.15, 0.10, 0.05,-0.30,
        -0.40,-0.20, 0.00, 0.05, 0.05, 0.00,-0.20,-0.40,
        -0.50,-0.40,-0.30,-0.30,-0.30,-0.30,-0.40,-0.50,
    ]

    // White Bishop
    private static let WBSquareValues = [
        -0.20,-0.10,-0.10,-0.10,-0.10,-0.10,-0.10,-0.20,
        -0.10, 0.05, 0.00, 0.00, 0.00, 0.00, 0.05,-0.10,
        -0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10,-0.10,
        -0.10, 0.00, 0.10, 0.10, 0.10, 0.10, 0.00,-0.10,
        -0.10, 0.05, 0.05, 0.10, 0.10, 0.05, 0.05,-0.10,
        -0.10, 0.00, 0.05, 0.10, 0.10, 0.05, 0.00,-0.10,
        -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.10,
        -0.20,-0.10,-0.10,-0.10,-0.10,-0.10,-0.10,-0.20,
    ]

    // Black Bishop
    private static let BBSquareValues = [
        -0.20,-0.10,-0.10,-0.10,-0.10,-0.10,-0.10,-0.20,
        -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.10,
        -0.10, 0.00, 0.05, 0.10, 0.10, 0.05, 0.00,-0.10,
        -0.10, 0.05, 0.05, 0.10, 0.10, 0.05, 0.05,-0.10,
        -0.10, 0.00, 0.10, 0.10, 0.10, 0.10, 0.00,-0.10,
        -0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10,-0.10,
        -0.10, 0.05, 0.00, 0.00, 0.00, 0.00, 0.05,-0.10,
        -0.20,-0.10,-0.10,-0.10,-0.10,-0.10,-0.10,-0.20,
    ]

    // White Rook
    private static let WRSquareValues = [
         0.00, 0.00, 0.00, 0.05, 0.05, 0.00, 0.00, 0.00,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
         0.05, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.05,
         0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,
    ]

    // Black Rook
    private static let BRSquareValues = [
         0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,
         0.05, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.05,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
        -0.05, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.05,
         0.00, 0.00, 0.00, 0.05, 0.05, 0.00, 0.00, 0.00,
    ]

    // White Queen
    private static let WQSquareValues = [
        -0.20,-0.10,-0.10,-0.05,-0.05,-0.10,-0.10,-0.20,
        -0.10, 0.00, 0.05, 0.00, 0.00, 0.00, 0.00,-0.10,
        -0.10, 0.05, 0.05, 0.05, 0.05, 0.05, 0.00,-0.10,
         0.00, 0.00, 0.05, 0.05, 0.05, 0.05, 0.00,-0.05,
        -0.05, 0.00, 0.05, 0.05, 0.05, 0.05, 0.00,-0.05,
        -0.10, 0.00, 0.05, 0.05, 0.05, 0.05, 0.00,-0.10,
        -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.10,
        -0.20,-0.10,-0.10,-0.05,-0.05,-0.10,-0.10,-0.20,
    ]

    // Black Queen
    private static let BQSquareValues = [
        -0.20,-0.10,-0.10,-0.05,-0.05,-0.10,-0.10,-0.20,
        -0.10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,-0.10,
        -0.10, 0.00, 0.05, 0.05, 0.05, 0.05, 0.00,-0.10,
        -0.05, 0.00, 0.05, 0.05, 0.05, 0.05, 0.00,-0.05,
         0.00, 0.00, 0.05, 0.05, 0.05, 0.05, 0.00,-0.05,
        -0.10, 0.05, 0.05, 0.05, 0.05, 0.05, 0.00,-0.10,
        -0.10, 0.00, 0.05, 0.00, 0.00, 0.00, 0.00,-0.10,
        -0.20,-0.10,-0.10,-0.05,-0.05,-0.10,-0.10,-0.20,
    ]

    // White King (middlegame)
    private static let WKSquareValues = [
         0.20, 0.30, 0.10, 0.00, 0.00, 0.10, 0.30, 0.20,
         0.20, 0.20, 0.00, 0.00, 0.00, 0.00, 0.20, 0.20,
        -0.10,-0.20,-0.20,-0.20,-0.20,-0.20,-0.20,-0.10,
        -0.20,-0.30,-0.30,-0.40,-0.40,-0.30,-0.30,-0.20,
        -0.30,-0.40,-0.40,-0.50,-0.50,-0.40,-0.40,-0.30,
        -0.30,-0.40,-0.40,-0.50,-0.50,-0.40,-0.40,-0.30,
        -0.30,-0.40,-0.40,-0.50,-0.50,-0.40,-0.40,-0.30,
        -0.30,-0.40,-0.40,-0.50,-0.50,-0.40,-0.40,-0.30,
    ]

    // Black King (middlegame)
    private static let BKSquareValues = [
        -0.30,-0.40,-0.40,-0.50,-0.50,-0.40,-0.40,-0.30,
        -0.30,-0.40,-0.40,-0.50,-0.50,-0.40,-0.40,-0.30,
        -0.30,-0.40,-0.40,-0.50,-0.50,-0.40,-0.40,-0.30,
        -0.30,-0.40,-0.40,-0.50,-0.50,-0.40,-0.40,-0.30,
        -0.20,-0.30,-0.30,-0.40,-0.40,-0.30,-0.30,-0.20,
        -0.10,-0.20,-0.20,-0.20,-0.20,-0.20,-0.20,-0.10,
         0.20, 0.20, 0.00, 0.00, 0.00, 0.00, 0.20, 0.20,
         0.20, 0.30, 0.10, 0.00, 0.00, 0.10, 0.30, 0.20,
    ]
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
