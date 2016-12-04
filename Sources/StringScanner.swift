//
//  StringScanner.swift
//  StringScanner
//
//  Created by Daniele Margutti on 03/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//
//  The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation

/// Throwable errors of the scanner
///
/// - eof: end of file is reached
/// - invalidInput: invalid input passed to caller function
/// - failed: failed to match or search value into the scanner's source string
public enum StringScannerError: Error {
	case eof
	case invalidInput
	case intExpected(consumed: Int)
	case failed(search: String, consumed: Int)
}

public class StringScanner {
	
	public typealias SIndex = String.UnicodeScalarView.Index
	public typealias SString = String.UnicodeScalarView
	
	/// Thats the current data of the scanner.
	/// Internally it's represented by `String.UnicodeScalarView`
	public var string: SString
	
	/// Current scanner's index position
	public var position: SIndex
	
	/// Number of scalars consumed up to `position`
	/// Since String.UnicodeScalarView.Index is not a RandomAccessIndex,
	/// this makes determining the position *much* easier)
	public var consumed: Int
	
	/// Return true if scanner reached the end of the string
	public var isAtEnd: Bool {
		return (self.position == string.endIndex)
	}
	
	
	/// Returns the content of scanner's string from current value of the position till the end
	/// indexes are not touched.
	///
	/// - Returns: the string
	public var remainder: String {
		var remString: String = ""
		var idx = self.position
		while idx != self.string.endIndex {
			remString.unicodeScalars.append(self.string[idx])
			idx = self.string.index(after:idx)
		}
		return remString
	}
	
	/// Initialize a new scanner instance from given source string
	///
	/// - Parameter string: source string
	public init(_ string: String) {
		self.string = string.unicodeScalars
		self.position = self.string.startIndex
		self.consumed = 0
	}
	
	
	/// If the current scanner position is not at eof return the next scalar at position and move to the next index
	/// Otherwise it throws with .eof
	///
	/// - Returns: the next character
	/// - Throws: throw .eof
	public func scanChar() throws -> UnicodeScalar {
		guard self.position != self.string.endIndex else {
			throw StringScannerError.eof
		}
		let char = self.string[self.position]
		self.position = self.string.index(after: self.position)
		self.consumed += 1
		return char
	}
	
	
	/// Scan the next integer value after the current scalar position; consume scalars from 0..9 until a non numeric
	/// value is encontered. Return the integer representation in base 10.
	/// Both position and consumed are advanced to the end of the number.
	/// Throws if scalar at the current `index` is not in the range `"0"` to `"9"`
	///
	/// - Returns: read integer in base 10
	/// - Throws: throw if non numeric value is encountered
	public func scanInt() throws -> Int {
		var parsedInt = 0
		try self.session(peek: true, accumulate: false, block: { i,c in
			while i != self.string.endIndex && self.string[i] >= "0" && self.string[i] <= "9" {
				parsedInt = parsedInt * 10 + Int(self.string[i].value - UnicodeScalar("0").value )
				i = self.string.index(after: i)
				c += 1
			}
			if i == self.position {
				throw StringScannerError.intExpected(consumed: consumed)
			}
			// okay valid, store changes to index
			self.position = i
			self.consumed = c
		})
		return parsedInt
	}
	
	/// Peek until chracter is found starting from current scanner index.
	/// Scanner's position is never updated.
	/// Throw an exception if .eof is reached or .failed if char was not found.
	///
	/// - Parameter char: char to search
	/// - Returns: the index found
	/// - Throws: throw an exception on .eof or .failed
	public func peek(upTo char: UnicodeScalar) throws -> SIndex {
		return try self.move(peek: true, upTo: char).index
	}
	
	
	/// Scan until chracter is found starting from current scanner index.
	/// Scanner's position is updated when character is found.
	/// Throw an exception if .eof is reached or .failed if char was not found (in this case scanner's position is not updated)
	///
	/// - Parameter char: char to search
	/// - Returns: the string until the character (excluded)
	/// - Throws: throw an exception on .eof or .failed
	public func scan(upTo char: UnicodeScalar) throws -> String {
		return try self.move(peek: false, upTo: char).string!
	}
	
	/// Peek until one the characters specified by set is encountered
	/// Index is reported before the start of the sequence, but scanner position is not updated
	/// Throw an exception if .eof is reached or .failed if sequence was not found
	///
	/// - Parameter charSet: character set to search
	/// - Returns: found index
	/// - Throws: throw .eof or .failed
	public func peek(upTo charSet: CharacterSet) throws -> SIndex {
		return self.move(peek: true, accumulate: false, upToCharSet: charSet).index
	}
	
	
	/// Scan until one the characters specified by set is encountered
	/// Index is reported before the start of the sequence, scanner position is updated only if sequence is found.
	/// Throw an exception if .eof is reached or .failed if sequence was not found
	///
	/// - Parameter charSet: character set to search
	/// - Returns: found index
	/// - Throws: throw .eof or .failed
	public func scan(upTo charSet: CharacterSet) throws -> String {
		return self.move(peek: false, accumulate: true, upToCharSet: charSet).string!
	}
	
	
	/// Iterate until specified string is encountered without updating indexes
	///
	/// - Parameter string: string to search
	/// - Returns: index where found string was found
	/// - Throws: throw .eof or .failedtosearch
	public func peek(upTo string: String) throws -> SIndex {
		return try self.move(peek: true, upTo: string).index
	}
	
	/// Scan until specified string is encountered and update indexes if found
	/// Throw an exception if .eof is reached or string cannot be found
	///
	/// - Parameter string: string to search
	/// - Returns: string up to search string (excluded)
	/// - Throws: throw .eof or .failedtosearch
	public func scan(upTo string: String) throws -> String {
		return try self.move(peek: false, upTo: string).string!
	}
	
	/// Throw if the scalar at the current position don't match given scalar.
	/// Advance the index to the end of the match.
	///
	/// - Parameter char: char to match
	/// - Throws: throw if does not match or index reaches eof
	public func match(_ char: UnicodeScalar) throws {
		guard self.position != self.string.endIndex else {
			throw StringScannerError.eof
		}
		if self.string[self.position] != char {
			throw StringScannerError.failed(search: String(char), consumed: self.consumed)
		}
		// Advance by one scalar, the one we matched
		self.position = self.string.index(after: self.position)
		self.consumed += 1
	}
	
	/// Throw if scalars starting at the current position don't match scalars in given string.
	/// Advance the index to the end of the match string.
	///
	/// - Parameter string: string to match
	/// - Throws: throw if does not match or index reaches eof
	public func match(_ match: String) throws {
		try self.session(peek: false, accumulate: false, block: { i,c in
			try match.unicodeScalars.forEach({ char in
				if i == self.string.endIndex {
					throw StringScannerError.eof
				}
				if self.string[i] != char {
					throw StringScannerError.failed(search: match, consumed: c)
				}
				i = self.string.index(after: i)
				c += 1
			})
		})
	}
	
	///  Scan and consume at the scalar starting from current position, testing it with function test.
	///  If test returns `true`, the `position` increased. If `false`, the function returns.
	///
	/// - Parameter test: test to pass
	public func read(untilTrue test: ((UnicodeScalar) -> (Bool)) ) {
		self.move(peek: false, accumulate: false, untilTrue: test)
	}
	
	///  Peeks at the scalar at the current position, testing it with function test.
	///  It only peeks so current scanner position and consumed are not increased at the end of the operation
	///
	/// - Parameter test: test to pass
	public func peek(untilTrue test: ((UnicodeScalar) -> (Bool)) ) {
		self.move(peek: true, accumulate: false, untilTrue: test)
	}
	
	/// Attempt to advance the index by length
	/// If operation is not possible (reached the end of the string) it throws and current position of the index did not change
	/// If operation succeded position and consumed indexes are changed according to passed length.
	///
	/// - Parameter length: length to advance
	/// - Throws: throw if .eof
	public func skip(length: Int = 1) throws {
		if length == 1 && self.position != self.string.endIndex {
			self.position = self.string.index(after: self.position)
			self.consumed += 1
			return
		}
		
		// Use temporary indexes and don't touch the real ones until we are
		// sure the operation succeded
		var proposedIdx = self.position
		var proposedConsumed = 0
		
		var remaining = length
		while remaining > 0 {
			if proposedIdx == self.string.endIndex {
				throw StringScannerError.eof
			}
			proposedIdx = self.string.index(after: proposedIdx)
			proposedConsumed += 1
			remaining -= 1
		}
		// Write changes only if skip operation succeded
		self.position = proposedIdx
		self.consumed = proposedConsumed
	}
	
	
	/// Attempt to advance the position back by length
	/// If operation fails indexes (position and consumed) are not touched
	/// If operation succeded indexes are modified according to new values
	///
	/// - Parameter length: length to move
	/// - Throws: throw if .eof
	public func back(length: Int = 1) throws {
		guard length <= self.consumed else { // more than we can go back
			throw StringScannerError.invalidInput
		}
		if length == 1 {
			self.position = self.string.index(self.position, offsetBy: -1)
			self.consumed -= 1
			return
		}
		
		let upperLimit = (self.consumed - length)
		while self.consumed != upperLimit {
			self.position = self.string.index(self.position, offsetBy: -1)
			self.consumed -= 1
		}
	}
	
	// -- Private Funcs --
	
	@discardableResult
	private func move(peek: Bool, upTo char: UnicodeScalar) throws -> (index: SIndex, string: String?) {
		return try self.session(peek: peek, accumulate: true, block: { i,c in
			// continue moving forward until we reach the end of scanner's string
			// or current character at scanner's string current position differs from we are searching for
			while i != self.string.endIndex && self.string[i] != char {
				i = self.string.index(after: i)
				c += 1
			}
			if i == self.string.endIndex { // we have reached the end of scanner's string
				throw StringScannerError.eof
			}
		})
	}
	
	@discardableResult
	private func move(peek: Bool, accumulate: Bool, upToCharSet charSet: CharacterSet) -> (index: SIndex, string: String?) {
		return try! self.session(peek: peek, accumulate: accumulate, block: { i,c in
			// continue moving forward until we reach the end of scanner's string
			// or current character at scanner's string current position differs from we are searching for
			while i != self.string.endIndex && charSet.contains(self.string[i]) == false {
				i = self.string.index(after: i)
				c += 1
			}
			if i == self.string.endIndex { // we have reached the end of scanner's string
				throw StringScannerError.eof
			}
		})
	}

	@discardableResult
	public func move(peek: Bool, accumulate: Bool, untilTrue test: ((UnicodeScalar) -> (Bool)) ) -> (index: SIndex, string: String?) {
		return try! self.session(peek: peek, accumulate: accumulate, block: { i,c in
			while i != self.string.endIndex {
				if test(self.string[i]) == false { // test is not passed, we return
					return
				}
				i = self.string.index(after: i)
				c += 1
			}
		})
	}
	
	@discardableResult
	private func move(peek: Bool, upTo string: String) throws -> (index: SIndex, string: String?) {
		let search = string.unicodeScalars
		guard let firstSearchChar = search.first else { // Invalid search string
			throw StringScannerError.invalidInput
		}
		if search.count == 1 { // If we are searching for a single char we want to forward call to the specific func
			return try self.move(peek: peek, upTo: firstSearchChar)
		}
		
		return try self.session(peek: peek, accumulate: true, block: { i,c in
			
			let remainderSearch = search[search.index(after: search.startIndex)..<search.endIndex]
			let endStringIndex = self.string.endIndex
			
			// Candidates allows us to store the position of index for any candidate string
			// A candidate session happens when we found the first char of search string (firstSearchChar)
			// into our scanner string.
			// We will use these indexes to switch back position of the scanner if the entire searchString will found
			// in order to exclude searchString itself from resulting string/indexes
			var candidateStartIndex = i
			var candidateConsumed = c
			
			mainLoop : while i != endStringIndex {
				// Iterate all over the strings searching for first occourence of the first char of the string to search
				while self.string[i] != firstSearchChar {
					if i == endStringIndex { // we have reached the end of the scanner's string
						throw StringScannerError.eof
					}
					i = self.string.index(after: i) // move to the next item
					c += 1 // increment consumed chars
				}
				// Okay we have found first char of our search string into our data
				
				// First of all we store in proposedIndex and proposedConsumed the position were we have found
				// this candidate. If validated we adjust back the indexes in of c,i in order to exclude found string itself
				candidateStartIndex = i
				candidateConsumed = c
				
				// We need to validate the remaining characters and see if are the same
				i = self.string.index(after: i) // scan from second character of the search string
				c += 1 // (clearly also increments consumed chars)
				
				// now we want to compare the reamining chars of the search (remainderSearch) with the
				// next chars of our current position in scanner's string
				for searchCChar in remainderSearch {
					if i == endStringIndex { // we have reached the end of the scanner's string
						throw StringScannerError.eof
					}
					if self.string[i] != searchCChar {
						continue mainLoop
					}
					// Go the next char
					i = self.string.index(after: i)
					c += 1
				}
				// Wow the string is that!
				// Adjust back the indexes
				i = candidateStartIndex
				c = candidateConsumed
				break
			}
		})
	}
	
	
	/// Initiate a scan or peek session. This func allows you to keep changes in index and consumed
	/// chars; moreover it returns the string accumulated during the move session.
	///
	/// - Parameters:
	///   - peek: if true it will update both consumed and position indexes of the scanner at the end with sPosition and sConsumed values
	///	  - accumulate: true to return the string from initial position till the end of reached index
	///   - block: block with the operation to execute
	/// - Returns: return the new proposed position for scanner's index and accumulated string
	/// - Throws: throw if block throws
	@discardableResult
	private func session(peek: Bool, accumulate: Bool = true,
	                     block: (_ sPosition: inout SIndex, _ sConsumed: inout Int) throws -> (Void) )
		throws -> (index: SIndex, string: String?) {
		// Keep in track with status of the position and consumed indexes before anything change
		var initialPosition = self.position
		let initialConsumed = self.consumed
		
		var sessionPosition = self.position
		var sessionConsumed = 0
		
		// execute the real code into block
		try block(&sessionPosition,&sessionConsumed)
			
		var result: String? = nil
		if accumulate == true {
			result = ""
			result!.reserveCapacity( (sessionConsumed - initialConsumed) ) // just an optimization
			while initialPosition != sessionPosition {
				result!.unicodeScalars.append(self.string[initialPosition])
				initialPosition = self.string.index(after: initialPosition)
			}
		}
			
		if peek == false { // Write changes to the main scanner's indexes
			self.position = sessionPosition
			self.consumed += sessionConsumed
		}
		return (sessionPosition,result)
	}
	
}
