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

    /// - todo: Needs a timeout to prevent blocking forever.
    public func readLine() -> String? {
        let timeout = DispatchTime.now() + 5  // No test should take this long
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
    var inputQueue: DispatchQueue?

    var outputLineStream: LineStream?

    override func setUp() {
        super.setUp()

        inputQueue = DispatchQueue(label: "UCIEngineTestsInput")

        outputLineStream = LineStream()

        engine = UCIEngine()
        engine!.putLine = { self.outputLineStream?.putLine($0) }
    }
    
    override func tearDown() {
        engine = nil
        inputQueue = nil
        outputLineStream = nil

        super.tearDown()
    }

    func sendToEngine(_ lines: String...) {
        for line in lines {
            inputQueue?.async {
                let _ = self.engine?.processInput(line)
            }
        }
    }

    func readFromEngine() -> String? {
        return outputLineStream?.readLine()
    }

    func expectFromEngine(_ lines: String...) {
        for line in lines {
            if let r = readFromEngine() {
                XCTAssertEqual(r, line)
            }
            else {
                XCTFail("EOF when expecting \"\(line)\"")
            }
        }
    }

    func testInitialization() {
        sendToEngine("uci")
        expectFromEngine(
            "id name kjchess",
            "id author Kristopher Johnson",
            "uciok"
        )
    }
}
