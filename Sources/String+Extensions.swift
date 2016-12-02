//
//  String+Extensions.swift
//  SwiftScanner
//
//  Created by Daniele Margutti on 02/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import Foundation

public extension String {
	
	/// Search a string into self and get the index
	///
	/// - Parameter string: string to search
	/// - Returns: the index or nil if string were not found
	public func find(_ string: String) -> String.Index? {
		guard let foundIndex = self.findRange(string) else { return nil }
		return self.index( foundIndex.0, offsetBy: foundIndex.1 )
	}
	
	
	/// Search a string into self and get the interval
	///
	/// - Parameter string: string to search
	/// - Returns: the interval
	public func findRange(_ string: String) -> (String.Index,String.IndexDistance)? {
		var indexInSelf = self.startIndex
		var indexInSearchString = string.startIndex
		
		while true {
			guard indexInSelf != self.endIndex else { return nil } // We reached the end of the string
			
			if self[indexInSelf] == string[indexInSearchString] {
				// Okay we have found our start character
				indexInSelf = self.index(after: indexInSelf)
				indexInSearchString = string.index(after: indexInSearchString)
				
				if indexInSearchString == string.endIndex { // okay we have found our entire string
					return (indexInSelf,-string.characters.count)
				}
			} else {
				// Found characters are different, move ahead along the string
				indexInSelf = self.index(after: indexInSelf)
				if indexInSearchString != string.startIndex {
					indexInSearchString = string.startIndex
				}
			}
		}
	}
	
	/// Checks if the string contains as prefix another given string
	///
	/// - Parameter string: string to search as prefix for self
	/// - Returns: true if self has given string as prefix, false otherwise
	public func hasPrefix(_ string: String) -> Bool {
		var indexInSelf = self.startIndex
		var indexInSearchString = string.startIndex
		
		while true {
			guard indexInSelf != self.endIndex else { return false } // We reached the end of the string
			
			if self[indexInSelf] == string[indexInSearchString] {
				// this index is validated, continue to the next character and see if it's the same
				indexInSelf = self.index(after: indexInSelf)
				indexInSearchString = string.index(after: indexInSearchString)
				
				if indexInSearchString == string.endIndex {
					return true
				}
			} else {
				// okay we can stop search, strings are different in terms of prefixes
				return false
			}
		}
	}
	
	/// Return a substring from self starting from given index to the end of the self
	///
	/// - Parameter startIndex: index to start
	public subscript(fromIndex startIndex: String.Index) -> String {
		return String(self.characters[startIndex..<self.endIndex])
	}
	
	/// Return a substring from self starting from given index to the end of the self
	///
	/// - Parameter index: index to start
	public subscript(fromIndex index: Int) -> String {
		let sIndex = self.index(self.startIndex, offsetBy: index)
		return String(self.characters[sIndex..<self.endIndex])
	}
	
	/// Return a substring from the start of self to given index
	///
	/// - Parameter endIndex: end index
	public subscript(toIndex endIndex: String.Index) -> String {
		return String(self.characters[self.startIndex..<endIndex])
	}
	
	/// Return a substring from the start of self to given index
	///
	/// - Parameter index: end index
	public subscript(toIndex index: Int) -> String {
		let eIndex = self.index(self.startIndex, offsetBy: index)
		return String(self.characters[self.startIndex..<eIndex])
	}

	/// Return a substring from self at given range
	///
	/// - Parameter range: range of the substring
	public subscript(inRange range: Range<String.Index>) -> String {
		return String(self.characters[range])
	}
	
	/// Return substring from self at given range
	///
	/// - Parameter range: range of the substring
	public subscript(inRange range: Range<Int>) -> String {
		let startIdx = self.index(self.startIndex, offsetBy: range.lowerBound)
		let endIdx = self.index(self.startIndex, offsetBy: range.upperBound)
		return String(self.characters[ startIdx..<endIdx ])
	}
}
