//
//  EvaluationTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class EvaluationTests: XCTestCase {

    func testEvaluateNewGame() {
        let pos = Position.newGame()
        let score = evaluate(position: pos)

        XCTAssertEqualWithAccuracy(0.0, score, accuracy: 0.01)
    }

    func testEvaluateAfterBlackPawnLoss() {
        let pos = try! Position.newGame().after(coordinateMoves:
            "e2e4", "d7d5", "e4d5")

        let score = evaluate(position: pos)

        XCTAssertEqualWithAccuracy(1.0, score, accuracy: 0.5,
                                   "White is ahead by a pawn")
    }

    func testEvaluateAfterWhiteKnightLoss() {
        let pos = try! Position.newGame().after(coordinateMoves:
            "g1f3", "e7e5", "f3d4", "e5d4")

        let score = evaluate(position: pos)

        XCTAssertEqualWithAccuracy(-3.2, score, accuracy: 0.5,
                                   "Black is ahead by a minor piece")
    }
}
