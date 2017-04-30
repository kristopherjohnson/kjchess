//
//  CommandLineParseResult.swift
//  kjchess
//
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Possible types of values for command options.
public enum CommandLineOptionValueType {
    case noValue
    case string(String)
}

/// The value associated with a command option.
public enum CommandLineOptionValue: CustomStringConvertible {
    case noValue
    case string(String)

    public var description: String {
        switch self {
        case .noValue:
            return "(no value)"
        case .string(let s):
            return "\"\(s)\""
        }
    }
}

/// Describes a possible command-line option.
public struct CommandLineOptionDefinition: CustomStringConvertible {
    public let name: String
    public let letter: Character?
    public let valueType: CommandLineOptionValueType
    public let briefHelp: String

    public init(name: String, letter: Character, valueType: CommandLineOptionValueType, briefHelp: String) {
        self.name = name
        self.letter = letter
        self.valueType = valueType
        self.briefHelp = briefHelp
    }

    public init(name: String, valueType: CommandLineOptionValueType, briefHelp: String) {
        self.name = name
        self.letter = nil
        self.valueType = valueType
        self.briefHelp = briefHelp
    }

    public var description: String {
        return "\(helpName) (\(valueType)) \(briefHelp)"
    }

    /// Return the option name as it should be displayed in descriptions.
    ///
    /// If there is a letter, then the result is "-letter/--name". Otherwise
    /// the result is just "--name".
    public var helpName: String {
        if let letter = letter {
            return "-\(letter)/--\(name)"
        }
        else {
            return "--\(name)"
        }
    }

    /// Return a description of the option syntax.
    ///
    /// Returns a string like "-o, --option" or "-o ARG, --option=ARG".
    public var helpSyntax: String {
        switch valueType {
        case .noValue:
            if let letter = letter {
                return "-\(letter), --\(name)"
            }
            else {
                return "=-\(name)"
            }
        case .string(let argName):
            if let letter = letter {
                return "-\(letter) \(argName), --\(name)=\(argName)"
            }
            else {
                return "=-\(name)=\(argName)"
            }
        }
    }
}

/// Print help for a set of option definitions.
public func printHelp(optionDefinitions: [CommandLineOptionDefinition], firstColumnWidth: Int = 40) {
    func paddedColumn(_ s: String) -> String {
        return s.padding(toLength: firstColumnWidth, withPad: " ", startingAt: 0)
    }

    for optionDefinition in optionDefinitions {
        print(String(format: "%@ %@",
                     paddedColumn(optionDefinition.helpSyntax),
                     optionDefinition.briefHelp))
    }
}

/// Print help for a set of option definitions to a specified output stream.
public func printHelp<Target: TextOutputStream>(
    optionDefinitions: [CommandLineOptionDefinition],
    to outputStream: inout Target,
    firstColumnWidth: Int = 40)
{
    func paddedColumn(_ s: String) -> String {
        return s.padding(toLength: firstColumnWidth, withPad: " ", startingAt: 0)
    }

    for optionDefinition in optionDefinitions {
        print(String(format: "%@ %@",
                     paddedColumn(optionDefinition.helpSyntax),
                     optionDefinition.briefHelp),
              to: &outputStream)
    }
}

/// A parsed command line option.
public struct CommandLineOption: CustomStringConvertible {
    public let definition: CommandLineOptionDefinition
    public let value: CommandLineOptionValue

    public var description: String {
        return "\(definition.helpName) \(value)"
    }
}

/// Errors thrown by `CommandLineParseResult` initializer.
public enum CommandLineParseError: Error, CustomStringConvertible {
    case unimplementedFeature(String)
    case undefinedOption(String)
    case missingOptionParameter(String)
    case invalidArgumentSyntax(String)
    case valueNotAllowed(String)
    case missingValue(String)

    public var description: String {
        switch self {
        case .unimplementedFeature(let name):
            return "unimplemented feature: \(name)"
        case .undefinedOption(let name):
            return "undefined option \"\(name)\""
        case .missingOptionParameter(let name):
            return "missing value for option \"\(name)\""
        case .invalidArgumentSyntax(let message):
            return "invalid argument syntax: \(message)"
        case .valueNotAllowed(let name):
            return "value not allowed for option: \(name)"
        case .missingValue(let name):
            return "argument required for option: \(name)"
        }
    }
}

extension CommandLineParseError: LocalizedError {
    public var errorDescription: String? {
        return description
    }
}

/// Result of parsing a command line.
public struct CommandLineParseResult {
    /// Arguments passed to the initializer.
    public let arguments: [String]

    /// Option definitions passed to the initializer.
    public let optionDefinitions: [CommandLineOptionDefinition]

    /// The first argument (or `nil` if no arguments were given).
    public let program: String?

    /// Option arguments.
    public let parsedOptions: [CommandLineOption]

    /// Non-option arguments.
    public let parsedArguments: [String]

    public init(arguments: [String], optionDefinitions: [CommandLineOptionDefinition]) throws {
        self.arguments = arguments
        self.optionDefinitions = optionDefinitions

        var iterator = arguments.makeIterator()
        self.program = iterator.next()

        (self.parsedOptions, self.parsedArguments) = try CommandLineParseResult.parse(
            iterator: &iterator,
            optionDefinitions: optionDefinitions,
            accumulatedOptions: [],
            accumulatedArguments: [])
    }

    /// Return the parsed option with the given name, or `nil` if it was not present.
    public func option(named name: String) -> CommandLineOption? {
        return parsedOptions.first { $0.definition.name == name }
    }

    /// Return the value of the parsed option with the given name, or `nil` if it was not present.
    public func value(optionNamed name: String) -> CommandLineOptionValue? {
        return option(named: name)?.value
    }

    /// Return `true` if an option with the specified name was parsed, or `false` otherwise.
    public func isPresent(optionNamed name: String) -> Bool {
        if let _ = option(named: name) {
            return true
        }
        else {
            return false
        }
    }

    private static func parse<StringIterator: IteratorProtocol>(
        iterator: inout StringIterator,
        optionDefinitions: [CommandLineOptionDefinition],
        accumulatedOptions: [CommandLineOption],
        accumulatedArguments: [String]
        ) throws -> ([CommandLineOption], [String])
        where StringIterator.Element == String
    {
        guard let argument = iterator.next() else {
            return (accumulatedOptions, accumulatedArguments)
        }

        if argument.hasPrefix("--") && argument.characters.count > 2 {
            let (name, value) = try parseNameAndValue(argument.substring(fromOffset: 2))
            if let matchingDefinition = optionDefinitions.first(where: { name == $0.name }) {
                switch matchingDefinition.valueType {
                case .noValue:
                    // --option
                    if value != nil {
                        throw CommandLineParseError.valueNotAllowed(argument)
                    }
                    let option = CommandLineOption(definition: matchingDefinition,
                                                   value: .noValue)
                    return try parse(
                        iterator: &iterator,
                        optionDefinitions: optionDefinitions,
                        accumulatedOptions: accumulatedOptions.appending(option),
                        accumulatedArguments: accumulatedArguments)

                case .string:
                    if let value = value {
                        // --option=VALUE
                        let option = CommandLineOption(definition: matchingDefinition,
                                                       value: .string(value))
                        return try parse(
                            iterator: &iterator,
                            optionDefinitions: optionDefinitions,
                            accumulatedOptions: accumulatedOptions.appending(option),
                            accumulatedArguments: accumulatedArguments)
                    }
                    else if let value = iterator.next() {
                        // --option VALUE
                        let option = CommandLineOption(definition: matchingDefinition,
                                                       value: .string(value))
                        return try parse(
                            iterator: &iterator,
                            optionDefinitions: optionDefinitions,
                            accumulatedOptions: accumulatedOptions.appending(option),
                            accumulatedArguments: accumulatedArguments)
                    }
                    else {
                        throw CommandLineParseError.missingValue(argument)
                    }
                }
            }
            else {
                throw CommandLineParseError.undefinedOption(argument)
            }
        }

        if argument.hasPrefix("-") && argument.characters.count > 1 {
            let letters = argument.substring(fromOffset: 1)
            var options: [CommandLineOption] = []
            var skipRemainingLetters = false
            for (n, letter) in letters.characters.enumerated() {
                if skipRemainingLetters {
                    continue
                }
                if let matchingDefinition = optionDefinitions.first(where: { letter == $0.letter }) {
                    switch matchingDefinition.valueType {
                    case .noValue:
                        // -o
                        options.append(CommandLineOption(definition: matchingDefinition,
                                                         value: .noValue))
                    case .string:
                        if n != 0 {
                            throw CommandLineParseError.invalidArgumentSyntax("-\(letter) cannot be grouped with other options because it requires an argument")
                        }
                        else if letters.characters.count > 1 {
                            // -oVALUE
                            let value = letters.substring(fromOffset: 1)
                            skipRemainingLetters = true
                            options.append(CommandLineOption(definition: matchingDefinition,
                                                             value: .string(value)))
                        }
                        else if let value = iterator.next() {
                            // -o VALUE
                            options.append(CommandLineOption(definition: matchingDefinition,
                                                             value: .string(value)))
                        }
                        else {
                            throw CommandLineParseError.missingValue("-\(letter)")
                        }
                    }
                }
                else {
                    throw CommandLineParseError.undefinedOption(argument)
                }
            }
            return try parse(
                iterator: &iterator,
                optionDefinitions: optionDefinitions,
                accumulatedOptions: accumulatedOptions + options,
                accumulatedArguments: accumulatedArguments)
        }

        return try parse(
            iterator: &iterator,
            optionDefinitions: optionDefinitions,
            accumulatedOptions: accumulatedOptions,
            accumulatedArguments: accumulatedArguments.appending(argument))
    }

    /// Split a string into name and value.
    ///
    /// Given a string, look for "=". If found, return portion before "=" and portion after "=".
    /// If "=" is not present, return the string and `nil`.
    private static func parseNameAndValue(_ s: String) throws -> (String, String?) {
        let components = s.components(separatedBy: "=")
        switch components.count {
        case 0:
            throw CommandLineParseError.invalidArgumentSyntax("empty argument")
        case 1:
            return (components[0], nil)
        case 2:
            return (components[0], components[1])
        default:
            throw CommandLineParseError.invalidArgumentSyntax("contains multiple '=' characters")
        }
    }
}
