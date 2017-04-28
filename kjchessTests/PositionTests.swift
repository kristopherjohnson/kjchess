//
//  PositionTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class PositionTests: XCTestCase {

    func testApplyAndUnapplyMove() {
        let pos1 = Position.newGame()

        var pos2 = pos1

        let undo = pos2.apply(.move(piece: WP, from: e2, to: e4))

        XCTAssertEqual(WP, pos2.board[e4])
        XCTAssertEqual(nil, pos2.board[e2])

        pos2.unapply(undo)

        XCTAssertEqual(pos1, pos2)
    }
}
