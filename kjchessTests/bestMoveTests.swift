//
//  bestMoveTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class bestMoveTests: XCTestCase {

    /// Number of times we repeat each test.
    ///
    /// This is intended to verify that the same "best" move is selected every time,
    /// and that we didn't just luckily choose the expected move randomly.
    let repeats = 4

    func testCaptureOverMove() {
        let board = Board.empty.with((WQ, e4),
                                     (BQ, b7))

        let pos = Position(board: board, toMove: .white, moves: [])

        for _ in 0..<repeats {
            let move = bestMove(position: pos)

            XCTAssertEqual(move,
                           .capture(piece: WQ, from: e4, to: b7, captured: .queen),
                           "Should always try to capture the queen")
        }
    }

    func testCaptureHighestValuePiece() {
        let board = Board.empty.with((WP, e4),
                                     (BQ, d5),
                                     (BB, f5))

        let pos = Position(board: board, toMove: .white, moves: [])

        for _ in 0..<repeats {
            let move = bestMove(position: pos)

            XCTAssertEqual(move,
                           .capture(piece: WP, from: e4, to: d5, captured: .queen),
                           "Should always capture the queen instead of the bishop")
        }
    }
}
