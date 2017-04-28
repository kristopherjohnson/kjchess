//
//  FEN.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

// This file contains extensions to Board and Piece for parsing
// and generating FEN position notation.

import Foundation

// Additions to Board to support FEN.
extension Board {
    /// Return FEN representation of the board's pieces.
    public var fen: String {
        return (0..<Board.ranksCount).map{ fenRank(7 - $0) }.joined(separator: "/")
    }

    /// Initialize `Board` from the first field of a FEN record.
    public init(fenBoard: String) throws {
        let ranks = fenBoard.components(separatedBy: "/")
        if ranks.count != 8 {
            throw ChessError.fenStringRequiresExactlyEightRanks(fenBoard: fenBoard)
        }

        self.squares = try Board.squares(fenRanks: ranks)
    }

    private static func fenSquare(piece: Piece?) -> String {
        if let piece = piece {
            return piece.fen
        }
        else {
            return "1"
        }
    }

    private static func squares(fenRanks: [String]) throws -> [Piece?] {
        var result = [Piece?]()
        result.reserveCapacity(squaresCount)

        for i in 0..<ranksCount {
            let squares = try rankSquares(fenRank: fenRanks[7 - i])
            result.append(contentsOf: squares)
        }

        return result
    }

    private func fenRank(_ rank: Int) -> String {
        var rankString = ""

        for i in 0..<Board.filesCount {
            rankString.append(Board.fenSquare(piece: at(file: i, rank: rank)))
        }

        // Reduce strings of "1"s.
        // (There is probably a more elegant way to do this.)
        rankString = rankString.replacingOccurrences(of: "11111111", with: "8")
        rankString = rankString.replacingOccurrences(of: "1111111", with: "7")
        rankString = rankString.replacingOccurrences(of: "111111", with: "6")
        rankString = rankString.replacingOccurrences(of: "11111", with: "5")
        rankString = rankString.replacingOccurrences(of: "1111", with: "4")
        rankString = rankString.replacingOccurrences(of: "111", with: "3")
        rankString = rankString.replacingOccurrences(of: "11", with: "2")

        return rankString
    }

    private static func rankSquares(fenRank: String) throws -> [Piece?] {
        if fenRank == "8" {
            return [Piece?](repeating: nil, count: 8)
        }

        var result = [Piece?]()
        result.reserveCapacity(filesCount)

        for char in fenRank.characters {
            switch char {
            case "1": result.append(nil)
            case "2": result.appendRepeating(element: nil, count: 2)
            case "3": result.appendRepeating(element: nil, count: 3)
            case "4": result.appendRepeating(element: nil, count: 4)
            case "5": result.appendRepeating(element: nil, count: 5)
            case "6": result.appendRepeating(element: nil, count: 6)
            case "7": result.appendRepeating(element: nil, count: 7)

            case "P": result.append(WP)
            case "N": result.append(WN)
            case "B": result.append(WB)
            case "R": result.append(WR)
            case "Q": result.append(WQ)
            case "K": result.append(WK)

            case "p": result.append(BP)
            case "n": result.append(BN)
            case "b": result.append(BB)
            case "r": result.append(BR)
            case "q": result.append(BQ)
            case "k": result.append(BK)

            default:
                throw ChessError.fenBoardContainsInvalidCharacter(character: char)
            }
        }

        return result
    }
}

extension Board: CustomStringConvertible {
    public var description: String {
        return fen
    }
}

extension Piece {
    /// Return FEN representation of the piece.
    public var fen: String {
        switch (player, kind) {
        case (.white, .pawn):   return "P"
        case (.white, .knight): return "N"
        case (.white, .bishop): return "B"
        case (.white, .rook):   return "R"
        case (.white, .queen):  return "Q"
        case (.white, .king):   return "K"
        case (.black, .pawn):   return "p"
        case (.black, .knight): return "n"
        case (.black, .bishop): return "b"
        case (.black, .rook):   return "r"
        case (.black, .queen):  return "q"
        case (.black, .king):   return "k"
        }
    }
}
