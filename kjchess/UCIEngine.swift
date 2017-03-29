//
//  UCIEngine.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Implementation of UCI (Universal Chess Interface) protocol.
/// Includes a few non-standard extensions that are useful for debugging.
public class UCIEngine {

    /// Function called to read a line of input.
    ///
    /// By default, this reads a line from standard input.
    public var getLine: () -> String?
        = { readLine(strippingNewline: true) }

    /// Function called to write a line of output.
    ///
    /// By default, this writes to standard output.
    public var putLine: (String) -> ()
        = { print($0) }

    /// Read UCI commands and process them until "quit" or end-of-stream.
    public func runCommandLoop() throws {
        while let line = getLine() {
            let cmdTokens = tokens(line)
            if !processCommand(tokens: cmdTokens) {
                return
            }
        }
    }

    /// Split an input line into tokens.
    ///
    /// Arbitrary whitespace between tokens is allowed.
    public func tokens(_ line: String) -> [String] {
        return line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    }

    /// Process the given command.
    ///
    /// - returns: `false` if the command loop should exit. `true` if it should continue.
    public func processCommand(tokens: [String]) -> Bool {
        if tokens.count == 0 {
            return true
        }

        let cmd = tokens[0]

        switch cmd {

        case "uci":
            putLine("id name kjchess")
            putLine("id author Kristopher Johnson")
            putLine("uciok")

        case "quit":
            return false

        default:
            putLine("info string Unexpected command \(cmd)")
        }

        return true
    }
}
