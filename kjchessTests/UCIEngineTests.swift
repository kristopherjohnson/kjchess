//
//  UCIEngineTests.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import kjchess

class LineStream {
    private var queue = DispatchQueue(label: "LineStream")
    private var semaphore = DispatchSemaphore(value: 0)
    private var lines = [String]()

    public func putLine(_ line: String) {
        queue.sync {
            lines.append(line)
            semaphore.signal()
        }
    }

    public func readLine() -> String? {
        let timeout = DispatchTime.now() + 10  // No test should take this long
        if semaphore.wait(timeout: timeout) == DispatchTimeoutResult.timedOut {
            XCTFail("readLine() timed out")
        }
        var result: String? = nil
        queue.sync {
            if lines.count > 0 {
                result = lines[0]
                lines.remove(at: 0)
            }
            else {
                semaphore.signal()
            }
        }
        return result
    }
}

class UCIEngineTests: XCTestCase {

    var engine: UCIEngine?

    // Synchronizes input sent to the engine
    var toEngineQueue: DispatchQueue?

    var fromEngineStream: LineStream?

    override func setUp() {
        super.setUp()

        toEngineQueue = DispatchQueue(label: "UCIEngineTestsInput")

        fromEngineStream = LineStream()

        engine = UCIEngine()
        engine!.putLine = { self.fromEngineStream?.putLine($0) }
        engine!.searchDepth = 1
    }
    
    override func tearDown() {
        engine = nil
        toEngineQueue = nil
        fromEngineStream = nil

        super.tearDown()
    }

    func send(_ lines: String...) {
        for line in lines {
            toEngineQueue?.async {
                _ = self.engine?.processInput(line)
            }
        }
    }

    func readLine() -> String? {
        return fromEngineStream?.readLine()
    }

    func expect(_ linePatterns: String...) {
        for linePattern in linePatterns {
            if let inputLine = readLine() {
                do {
                    let re = try NSRegularExpression(pattern: linePattern, options: [.anchorsMatchLines])
                    let matches = re.numberOfMatches(in: inputLine, options: [], range: NSMakeRange(0, inputLine.utf16.count))
                    if matches == 0 {
                        XCTFail("Unable to match pattern \"\(linePattern)\" with input line \"\(inputLine)\"")
                    }
                }
                catch (let error) {
                    XCTFail("Unable to create regular expression from \"\(linePattern)\": \(error.localizedDescription)")
                }
            }
            else {
                XCTFail("EOF when expecting \"\(linePattern)\"")
            }
        }
    }

    // MARK:- Tests

    func testUciInitialization() {
        send(
            "uci"
        )

        expect(
            "id name kjchess",
            "id author Kristopher Johnson",
            "uciok"
        )
    }

    func testIsReady() {
        send(
            "isready"
        )

        expect(
            "readyok"
        )
    }

    func testNewGame() {
        send(
            "ucinewgame"
        )

        XCTAssertEqual(Position.newGame(), engine!.position)
    }

    func testPositionAfter_e2e4() {
        // Note: A real GUI wouldn't send "isready" after
        // a a "position" command, but we need to make sure
        // we wait until the engine processes the command
        // asynchronously before checking the result.

        send(
            "position startpos moves e2e4",
            "isready"
        )

        expect(
            "readyok"
        )
        
        let expectedPosition = Position.newGame().after(
            .move(piece: WP, from: e2, to: e4))
        XCTAssertEqual(expectedPosition, engine!.position)
    }

    func testPlayBlackFirstMoves() {
        send(
            "position startpos moves e2e4",
            "go wtime 300000 btime 300000 movestogo 40"
        )
        
        expect(
            "info depth \\d+ score cp -?\\d+ time \\d+ pv [a-h][1-8][a-h][1-8]",
            "bestmove [a-h][1-8][a-h][1-8]"
        )
    }

    func testPlayBlackSecondMove() {
        send(
            "position startpos moves e2e4 e7e5 g1f3",
            "go wtime 297440 btime 299890 movestogo 39"
        )

        expect(
            "info depth \\d+ score cp -?\\d+ time \\d+ pv [a-h][1-8][a-h][1-8]",
            "bestmove [a-h][1-8][a-h][1-8]"
        )
    }

    func testFENPosition() {
        send(
            "position fen rnbqkbnr/pp1p1ppp/4p3/2p5/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 1 3",
            "isready"
        )

        expect(
            "readyok"
        )

        let expectedPosition = Position.newGame()
            .after(Move.move(piece: WP, from: e2, to: e4))
            .after(Move.move(piece: BP, from: c7, to: c5))
            .after(Move.move(piece: WN, from: g1, to: f3))
            .after(Move.move(piece: BP, from: e7, to: e6))
            .after(Move.move(piece: WB, from: f1, to: c4))
        XCTAssertEqual(engine!.position, expectedPosition)
    }

    func testHandleCheckmate() {
        /// This position is checkmate. Ensure engine does not crash in that case.
        /// (There was a bug that caused failure because the engine was
        /// trying to convert a score of Double.infinity to centipawns.)
        send(
            "position startpos moves e2e4 e7e5 g1f3 b8c6 f1c4 d8f6 c2c3 c6a5 b2b3 a5c4 b3c4 f6b6 e1g1 c7c6 f3e5 g8h6 d2d4 h6g8 d1b3 b6c7 c4c5 f7f5 b3f7",
            "go wtime 300000 btime 300000 movestogo 29",
            "isready"
        )

        expect(
            "info depth \\d+ score cp \\d+ time \\d+ pv e8d8",
            "bestmove e8d8",
            "readyok"
        )
    }
}
