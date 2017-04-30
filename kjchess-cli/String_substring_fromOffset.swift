//
//  String_substring_fromNumericIndex.swift
//  swiftcat
//
//  Copyright © 2017 Kristopher Johnson
//

import Foundation

extension String {
    /// Returns substring starting from given numeric index to the end of the string.
    public func substring(fromOffset n: Int) -> String {
        return self.substring(from: self.index(self.startIndex,
                                               offsetBy: n))
    }
}
