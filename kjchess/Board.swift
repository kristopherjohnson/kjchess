//
//  Board.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Chess board.
///
/// Representation is an 8x8 array.
/// Each element may be a `Piece` or be empty (`nil`).
///
/// A `Board` is an immutable object.  Moves result in
/// the creation of new `Board` instances, which may
/// share rank arrays with other instances.
public class Board {
    public static let ranksCount = 8
    public static let filesCount = 8

    public static let emptyRank: [Piece?]
        = Array(repeating: nil, count: Board.filesCount)

    public static let empty
        = Board(Array(repeating: emptyRank, count: Board.ranksCount))

    public static let newGame
        = Board([[WR,  WN,  WB,  WQ,  WK,  WB,  WN,  WR],
                 [WP,  WP,  WP,  WP,  WP,  WP,  WP,  WP],
                 emptyRank,
                 emptyRank,
                 emptyRank,
                 emptyRank,
                 [BP,  BP,  BP,  BP,  BP,  BP,  BP,  BP],
                 [BR,  BN,  BB,  BQ,  BK,  BB,  BN,  BR]])

    public let ranks: [[Piece?]]

    public init(_ ranks: [[Piece?]]) {
        assert(ranks.count == Board.ranksCount,
               "Number of ranks must be 8")
        assert(!ranks.contains { $0.count != Board.filesCount },
               "Each rank must contain exactly 8 elements")
        self.ranks = ranks
    }

    public subscript(location: Location) -> Piece? {
        return ranks[location.rank][location.file]
    }

    public func at(_ file: Int, _ rank: Int) -> Piece? {
        return ranks[rank][file]
    }
}
