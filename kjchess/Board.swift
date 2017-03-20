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

    public static let minRank = 0
    public static let maxRank = ranksCount - 1

    public static let minFile = 0
    public static let maxFile = filesCount - 1

    /// Return true if the given file index is in the range 0...7.
    public static func isValid(file: Int) -> Bool {
        return (minFile...maxFile).contains(file)
    }

    /// Return true if the given rank index is in the range 0...7.
    public static func isValid(rank: Int) -> Bool {
        return (minRank...maxRank).contains(rank)
    }

    /// Return true if given file and rank are in the range 0...7.
    public static func isValid(file: Int, rank: Int) -> Bool {
        return isValid(file: file) && isValid(rank: rank)
    }

    private static let emptyRank: [Piece?]
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

    /// Return `Piece` at the specified `Location`.
    public subscript(location: Location) -> Piece? {
        return ranks[location.rank][location.file]
    }

    /// Return `Piece` at the specified location.
    public func at(file: Int, rank: Int) -> Piece? {
        return ranks[rank][file]
    }

    /// Return `true` if specified `Location` has no piece on it.
    public func isEmpty(_ location: Location) -> Bool {
        return self[location] == nil
    }

    /// Return `true` if specified square has no piece on it.
    public func isEmpty(file: Int, rank: Int) -> Bool {
        return at(file: file, rank: rank) == nil
    }

    /// Return `true` if specified square has a piece of the specified color.
    public func hasPiece(file: Int, rank: Int, player: Player) -> Bool {
        if let piece = at(file: file, rank: rank), piece.player == player {
            return true
        }
        return false
    }

    /// Return copy of board after applying the given `Move`.
    ///
    /// This method does not validate whether the move is valid
    /// of the specified pieces exist.
    ///
    /// - todo: The creation of the new board should be optimized to not call `.with(_,at:)` for every changed square.
    public func after(_ move: Move) -> Board {
        switch move {

        case .move(let piece, let from, let to),
             .capture(let piece, let from, let to, _):
            return self
                .with(piece, at: to)
                .with(nil, at: from)

        case .promote:
            return self

        case .promoteCapture:
            return self
            
        case .enPassantCapture(let player, let from, let to, _):
            let capturedPieceRank
                = (player == .white)
                    ? to.rank - 1
                    : to.rank + 1
            return self
                .with(Piece(player, .pawn), at: to)
                .with(nil, at: from)
                .with(nil, at: Location(to.file, capturedPieceRank))

        case .castleKingside(let player):
            switch player {
            case .white:
                return self
                    .with(WK, at: g1)
                    .with(WR, at: f1)
                    .with(nil, at: e1)
                    .with(nil, at: h1)
            case .black:
                return self
                    .with(BK, at: g8)
                    .with(BR, at: f8)
                    .with(nil, at: e8)
                    .with(nil, at: h8)
            }

        case .castleQueenside(let player):
            switch player {
            case .white:
                return self
                    .with(WK, at: c1)
                    .with(WR, at: d1)
                    .with(nil, at: e1)
                    .with(nil, at: a1)
            case .black:
                return self
                    .with(BK, at: c8)
                    .with(BR, at: d8)
                    .with(nil, at: e8)
                    .with(nil, at: a8)
            }

        case .resign:
            return self
        }
    }

    /// Return copy of board with the given `Piece` at the given `Location`.
    public func with(_ piece: Piece?, at location: Location) -> Board {
        let file = location.file
        let rank = location.rank

        var newRank = Array(ranks[rank])
        newRank[file] = piece

        var newRanks = Array(ranks)
        newRanks[rank] = newRank

        return Board(newRanks)
    }

    /// Return array of (`Piece`, `Location`) tuples indicating pieces for the specified player.
    public func pieces(player: Player) -> AnySequence<(Piece, Location)> {
        // TODO: Create the result sequence lazily
        var result = [(Piece, Location)]()
        for rank in 0..<Board.ranksCount {
            let rankArray = ranks[rank]
            for file in 0..<Board.filesCount {
                if let piece = rankArray[file], piece.player == player {
                    result.append((piece, Location(file, rank)))
                }
            }
        }
        return AnySequence(result)
    }
}
