//
//  Position_generateMovesTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
@testable import kjchess

class Position_generateMovesTests: XCTestCase {

    func testWhiteNewGameMoves() {
        let pos = Position.newGame()

        let expectedMoves = [
            (WP, a2, a3), (WP, a2, a4),
            (WP, b2, b3), (WP, b2, b4),
            (WP, c2, c3), (WP, c2, c4),
            (WP, d2, d3), (WP, d2, d4),
            (WP, e2, e3), (WP, e2, e4),
            (WP, f2, f3), (WP, f2, f4),
            (WP, g2, g3), (WP, g2, g4),
            (WP, h2, h3), (WP, h2, h4),
            (WN, b1, a3), (WN, b1, c3),
            (WN, g1, f3), (WN, g1, h3)
        ]

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for move in expectedMoves {
            XCTAssertTrue(moves.contains { $0.matches(piece: move.0, from: move.1, to: move.2) },
                          "Expected \(move), but it's missing")
        }
    }

    func testBlackNewGameMoves() {
        let board = Board.newGame.with([(WP, e4),
                                        (nil, e2)])

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves = [
            (BP, a7, a6), (BP, a7, a5),
            (BP, b7, b6), (BP, b7, b5),
            (BP, c7, c6), (BP, c7, c5),
            (BP, d7, d6), (BP, d7, d5),
            (BP, e7, e6), (BP, e7, e5),
            (BP, f7, f6), (BP, f7, f5),
            (BP, g7, g6), (BP, g7, g5),
            (BP, h7, h6), (BP, h7, h5),
            (BN, b8, a6), (BN, b8, c6),
            (BN, g8, f6), (BN, g8, h6)
        ]

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for move in expectedMoves {
            XCTAssertTrue(moves.contains { $0.matches(piece: move.0, from: move.1, to: move.2) },
                          "Expected \(move), but it's missing")
        }

        for move in moves {
            XCTAssertFalse(move.isCapture, "Should not be a capturing move")
        }
    }

    func testWhitePawnCaptures() {
        let board = Board.empty.with([(WP, e4),
                                      (BB, d5),
                                      (BP, e5),
                                      (BN, f5)])

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves: [Move] = [
            .capture(piece: WP, from: e4, to: d5, capturedPiece: BB),
            .capture(piece: WP, from: e4, to: f5, capturedPiece: BN)
        ]

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for move in expectedMoves {
            XCTAssertTrue(moves.contains { $0 == move },
                          "Expected \(move), but it's missing")
        }
    }

    func testBlackPawnCaptures() {
        let board = Board.empty.with([(BP, at: d5),
                                      (WB, at: c4),
                                      (WP, at: d4),
                                      (WN, at: e4)])

        let pos = Position(board: board, toMove: .black, moves: [])

        let expectedMoves: [Move] = [
            .capture(piece: BP, from: d5, to: c4, capturedPiece: WB),
            .capture(piece: BP, from: d5, to: e4, capturedPiece: WN)
        ]

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for move in expectedMoves {
            XCTAssertTrue(moves.contains { $0 == move },
                          "Expected \(move), but it's missing")
        }
    }
    
    func testKnightMovesEmptyBoard() {
        let board = Board.empty.with(WN, at: d4)

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            (WN, d4, c6),
            (WN, d4, e6),
            (WN, d4, f5),
            (WN, d4, f3),
            (WN, d4, e2),
            (WN, d4, c2),
            (WN, d4, b3),
            (WN, d4, b5)
        ]

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for move in expectedMoves {
            XCTAssertTrue(moves.contains { $0.matches(piece: move.0, from: move.1, to: move.2) },
                          "Expected \(move), but it's missing")
        }

        for move in moves {
            XCTAssertFalse(move.isCapture, "Should not be a capturing move")
        }
    }

    func testKnightMovesAllBlocked() {
        // Knight at d4 with pawns at all locations it could jump to.
        let board = Board.empty.with([(WN, d4),
                                      (WP, c6),
                                      (WP, e6),
                                      (WP, f5),
                                      (WP, f3),
                                      (WP, e2),
                                      (WP, c2),
                                      (WP, b3),
                                      (WP, b5)])

        let pos = Position(board: board, toMove: .white, moves: [])

        // Note: Filter out the moves that the pawns could make.
        let moves = Array(pos.generateMoves()).filter { $0.from == d4 }

        XCTAssertEqual(0, moves.count, "No moves by the knight are possible")
    }

    func testKnightCaptures() {
        // White knight at d4 with black queens at every location can jump to
        let board = Board.empty.with([(WN, d4),
                                      (BQ, c6),
                                      (BQ, e6),
                                      (BQ, f5),
                                      (BQ, f3),
                                      (BQ, e2),
                                      (BQ, c2),
                                      (BQ, b3),
                                      (BQ, b5)])

        let pos = Position(board: board, toMove: .white, moves: [])

        let expectedMoves = [
            (WN, d4, c6),
            (WN, d4, e6),
            (WN, d4, f5),
            (WN, d4, f3),
            (WN, d4, e2),
            (WN, d4, c2),
            (WN, d4, b3),
            (WN, d4, b5)
        ]

        let moves = Array(pos.generateMoves())

        XCTAssertEqual(moves.count, expectedMoves.count)

        for move in expectedMoves {
            XCTAssertTrue(moves.contains { $0.matches(piece: move.0, from: move.1, to: move.2) },
                          "Expected \(move), but it's missing")
        }

        for move in moves {
            XCTAssertTrue(move.isCapture, "Should be a capturing move")
            XCTAssertEqual(BQ, move.capturedPiece)
        }
    }
}
