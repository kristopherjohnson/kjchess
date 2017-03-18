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
        let board = Board.newGame
            .with(WP, at: e4)
            .with(nil, at: e2)

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

    func testKnightMovesEmptyBoard() {
        let board = Board.empty
            .with(WN, at: d4)

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
        let board = Board.empty
            .with(WN, at: d4)
            .with(WP, at: c6)
            .with(WP, at: e6)
            .with(WP, at: f5)
            .with(WP, at: f3)
            .with(WP, at: e2)
            .with(WP, at: c2)
            .with(WP, at: b3)
            .with(WP, at: b5)

        let pos = Position(board: board, toMove: .white, moves: [])

        // Note: Filter out the moves that the pawns could make.
        let moves = Array(pos.generateMoves()).filter { $0.from == d4 }

        XCTAssertEqual(0, moves.count, "No moves by the knight are possible")
    }

    func testKnightCaptures() {
        // White knight at d4 with black queens at every location can jump to
        let board = Board.empty
            .with(WN, at: d4)
            .with(BQ, at: c6)
            .with(BQ, at: e6)
            .with(BQ, at: f5)
            .with(BQ, at: f3)
            .with(BQ, at: e2)
            .with(BQ, at: c2)
            .with(BQ, at: b3)
            .with(BQ, at: b5)

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
