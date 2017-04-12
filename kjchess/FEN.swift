//
//  FEN.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

// This file contains extensions to Position and Board for parsing
// and generating FEN position notation.

import Foundation

// Additions to Position to support FEN.
extension Position {

    /// Return FEN record for the position.
    public var fen: String {
        return [
            board.fen,
            fenPlayerToMove,
            fenCastlingFlags,
            fenEnPassantCaptureLocation,
            fenHalfmoveClock,
            fenMoveNumber
        ].joined(separator: " ")
    }

    /// Initialize from a FEN (Forsyth-Edwards Notation) record.
    public init(fen: String) throws {
        let tokens = fen.whitespaceSeparatedTokens()
        if tokens.count != 6 {
            throw ChessError.fenStringRequiresExactlySixFields(fen: fen)
        }

        board = try Board(fenBoard: tokens[0])

        toMove = try Position.playerToMove(fenPlayerToMove: tokens[1])

        moves = []

        (whiteCanCastleKingside, whiteCanCastleQueenside, blackCanCastleKingside, blackCanCastleQueenside)
            = try Position.castlingFlags(fenCastlingFlags: tokens[2])

        enPassantCaptureLocation = Location(tokens[3])

        if let halfmoveClock = Int(tokens[4]), halfmoveClock >= 0 {
            self.halfmoveClock = halfmoveClock
        }
        else {
            throw ChessError.fenInvalidHalfmoveClock(fenHalfmoveClock: tokens[4])
        }

        if let moveNumber = Int(tokens[5]), moveNumber > 0 {
            self.moveNumber = moveNumber
        }
        else {
            throw ChessError.fenInvalidMoveNumber(fenMoveNumber: tokens[5])
        }
    }

    private var fenPlayerToMove: String {
        switch toMove {
        case .white: return "w"
        case .black: return "b"
        }
    }

    private static func playerToMove(fenPlayerToMove: String) throws -> Player {
        switch fenPlayerToMove {
        case "w": return .white
        case "b": return .black
        default: throw ChessError.fenInvalidPlayerToMove(fenPlayerToMove: fenPlayerToMove);
        }
    }

    private var fenCastlingFlags: String {
        var result = ""

        if whiteCanCastleKingside  { result.append("K") }
        if whiteCanCastleQueenside { result.append("Q") }
        if blackCanCastleKingside  { result.append("k") }
        if blackCanCastleQueenside { result.append("q") }

        if result.isEmpty {
            return "-"
        }
        else {
            return result
        }
    }

    private static func castlingFlags(fenCastlingFlags: String) throws -> (Bool, Bool, Bool, Bool) {
        let whiteCanCastleKingside = fenCastlingFlags.contains("K")
        let whiteCanCastleQueenside = fenCastlingFlags.contains("Q")
        let blackCanCastleKingside = fenCastlingFlags.contains("k")
        let blackCanCastleQueenside = fenCastlingFlags.contains("q")
        
        return (whiteCanCastleKingside,
                whiteCanCastleQueenside,
                blackCanCastleKingside,
                blackCanCastleQueenside)
    }

    private var fenEnPassantCaptureLocation: String {
        if let location = enPassantCaptureLocation {
            return location.symbol
        }
        else {
            return "-"
        }
    }

    private var fenHalfmoveClock: String {
        return halfmoveClock.description
    }

    private var fenMoveNumber: String {
        return moveNumber.description
    }
}

extension Position: CustomStringConvertible {
    public var description: String {
        return fen
    }
}

// Additions to Board to support FEN.
extension Board {
    /// Return FEN representation of the board's pieces.
    public var fen: String {
        var ranks = [String]()
        ranks.reserveCapacity(Board.ranksCount)

        for i in 0..<Board.ranksCount {
            let rank = fenRank(7 - i)
            ranks.append(rank)
        }

        return ranks.joined(separator: "/")
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

        // There is probably a more elegant way to do this
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
