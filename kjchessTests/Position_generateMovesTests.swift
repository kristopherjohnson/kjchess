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

        let moves = Array(pos.generateMoves())

        let expectedMoves = [
            (WP, a2, a3), (WP, a2, a4),
            (WP, b2, b3), (WP, b2, b4),
            (WP, c2, c3), (WP, c2, c4),
            (WP, d2, d3), (WP, d2, d4),
            (WP, e2, e3), (WP, e2, e4),
            (WP, f2, f3), (WP, f2, f4),
            (WP, g2, g3), (WP, g2, g4),
            (WP, h2, h3), (WP, h2, h4)
        ]

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

        let moves = Array(pos.generateMoves())

        let expectedMoves = [
            (BP, a7, a6), (BP, a7, a5),
            (BP, b7, b6), (BP, b7, b5),
            (BP, c7, c6), (BP, c7, c5),
            (BP, d7, d6), (BP, d7, d5),
            (BP, e7, e6), (BP, e7, e5),
            (BP, f7, f6), (BP, f7, f5),
            (BP, g7, g6), (BP, g7, g5),
            (BP, h7, h6), (BP, h7, h5)
        ]

        XCTAssertEqual(moves.count, expectedMoves.count)

        for move in expectedMoves {
            XCTAssertTrue(moves.contains { $0.matches(piece: move.0, from: move.1, to: move.2) },
                          "Expected \(move), but it's missing")
        }
    }

}
