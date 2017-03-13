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
            (a2, a3),
            (b2, b3),
            (c2, c3),
            (d2, d3),
            (e2, e3),
            (f2, f3),
            (g2, g3),
            (h2, h3)
        ]

        XCTAssertEqual(moves.count, expectedMoves.count)

        for move in expectedMoves {
            XCTAssertTrue(moves.contains { $0.matches(from: move.0, to: move.1) },
                          "Expected \(move)")
        }
    }

    func testBlackNewGameMoves() {
        let board = Board.newGame
            .with(WP, at: e4)
            .with(nil, at: e2)

        let pos = Position(board: board, toMove: .black, moves: [])

        let moves = Array(pos.generateMoves())

        let expectedMoves = [
            (a7, a6),
            (b7, b6),
            (c7, c6),
            (d7, d6),
            (e7, e6),
            (f7, f6),
            (g7, g6),
            (h7, h6)
        ]

        XCTAssertEqual(moves.count, expectedMoves.count)

        for move in expectedMoves {
            XCTAssertTrue(moves.contains { $0.matches(from: move.0, to: move.1) },
                          "Expected \(move)")
        }
    }

}
