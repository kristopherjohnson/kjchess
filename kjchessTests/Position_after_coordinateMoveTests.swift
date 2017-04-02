//
//  Position_after_coordinateMoveTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class Position_after_coordinateMoveTests: XCTestCase {

    func test_e2e4() {
        do {
            let pos = try Position.newGame().after(
                coordinateMove: "e2e4");

            let expectedPosition = Position.newGame().after(
                .move(piece: WP, from: e2, to: e4))
            XCTAssertEqual(expectedPosition, pos)
        }
        catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }
}
