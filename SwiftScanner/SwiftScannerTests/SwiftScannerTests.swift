//
//  SwiftScannerTests.swift
//  SwiftScannerTests
//
//  Created by Daniele Margutti on 06/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import XCTest
import SwiftScanner

class SwiftScannerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
	
	func testScanChar() {
		let test = "next char test ⛵️"
		let testScalars = test.unicodeScalars
		var idx = testScalars.startIndex

		let scanner = StringScanner(test)
		do {
			while !scanner.isAtEnd {
				let currentScalar = try scanner.scanChar()
				XCTAssert( (currentScalar == testScalars[idx]) , "Failed to validate scanChar()")
				idx = testScalars.index(after: idx)
			}
		} catch let err {
			XCTFail("scanChar() does not work properly: \(err)")
		}
	}
	
	func testInt() {
		let test = "12,24,36,45,1"
		let valid = [12,24,36,45,1]
		let scanner = StringScanner(test)
		var idx = 0
		
		do {
			while !scanner.isAtEnd {
				if scanner.consumed > 0 { try scanner.skip() }
				let currentInt = try scanner.scanInt()
				XCTAssert( (currentInt == valid[idx]) , "Failed to validate scanInt()")
				idx += 1
			}
		} catch let err {
			XCTFail("scanInt() does not work properly: \(err)")
		}
	}
	
	func testFloat() {
		let test = "12.56,34.5,33.4,3.4"
		let valid: [Float] = [12.56,34.5,33.4,3.4]
		let scanner = StringScanner(test)
		var idx = 0
		
		do {
			while !scanner.isAtEnd {
				if scanner.consumed > 0 { try scanner.skip() }
				let currentFloat = try scanner.scanFloat()
				XCTAssert( (currentFloat == valid[idx]) , "Failed to validate testFloat()")
				idx += 1
			}
		} catch let err {
			XCTFail("testFloat() does not work properly: \(err)")
		}
	}
	
	func testHEX16BitString() {
		let test = "#1602,#04D1,0x0929"
		let intValues = [5634,1233,2345]
		validateHEXValues(name: "testHEX16BitString()", string: test, digits: .bit16, validValues: intValues)
	}
	
	func testHEX32BitString() {
		let test = "0XAF2C0155,#FF003344,0x0000F2C4"
		let intValues = [2938896725,4278203204,62148]
		validateHEXValues(name: "testHEX32BitString()", string: test, digits: .bit32, validValues: intValues)
	}
	
	func testHEX64BitString() {
		let test = "0x0000000000564534"
		let intValues = [5653812]
		validateHEXValues(name: "testHEX64BitString()", string: test, digits: .bit64, validValues: intValues)
	}
	
	func validateHEXValues(name: String, string: String, digits: BitDigits, validValues: [Int]) {
		var idx = 0
		let scanner = StringScanner(string)
		do {
			while !scanner.isAtEnd {
				if scanner.consumed > 0 { try scanner.skip() }
				let currentInt = try scanner.scanHexInt(digits)
				XCTAssert( (currentInt == validValues[idx]) , "Failed to validate scanHexInt()")
				idx += 1
			}
		} catch let err {
			XCTFail("scanHexInt() does not work properly: \(err)")
		}
	}
	
	func testScanUpToUnicodeScalar() {
		let test = "hello again. i'm daniele. welcome here!"
		let validValues:[String] = ["hello again"," i'm daniele"," welcome here!"]
		let scanner = StringScanner(test)
		var idx = 0
		
		do {
			while !scanner.isAtEnd  {
				let blockValue = try scanner.scan(upTo: ".")
				XCTAssert( (blockValue == validValues[idx]) , "Failed to validate scan(upTo:<UnicodeScalar>)")
				idx += 1
				if (idx < validValues.count) { try scanner.skip() }
			}
		} catch let err {
			XCTFail("scan(upTo:<UnicodeScalar>) does not work properly: \(err)")
		}
	}
	
	func testScanUpToCharset() {
		let test = "this a token;that's another.third one!the last one"
		let validValues: [String] = ["this a token","that's another","third one","the last one"]
		let scanner = StringScanner(test)
		var idx = 0

		do {
			while !scanner.isAtEnd  {
				let blockValue = try scanner.scan(upTo: CharacterSet(charactersIn: ";.!"))
				XCTAssert( (blockValue == validValues[idx]) , "Failed to validate scan(upTo:<CharacterSet>)")
				idx += 1
				if (idx < validValues.count) { try scanner.skip() }
			}
		} catch let err {
			XCTFail("scan(upTo:<CharacterSet>) does not work properly: \(err)")
		}
	}
	
	func testScanUpUntilCharset() {
		let test = "daniele;mario;john;steve"
		let validValues: [String] = ["daniele","mario","john","steve"]
		let scanner = StringScanner(test)
		var idx = 0

		do {
			while !scanner.isAtEnd  {
				let blockValue = try scanner.scan(untilIn: CharacterSet.lowercaseLetters)
				XCTAssert( (blockValue == validValues[idx]) , "Failed to validate scan(until:<CharacterSet>)")
				idx += 1
				if (idx < validValues.count) { try scanner.skip() }
			}
		} catch let err {
			XCTFail("scan(until:<CharacterSet>) does not work properly: \(err)")
		}
	}
	
	func testScanUpToString() {
		let separator = ",\n"
		let test = "one\(separator)two\(separator)three\(separator)four\(separator)"
		let validValues: [String] = ["one","two","three","four"]
		let scanner = StringScanner(test)
		var idx = 0
		
		do {
			while !scanner.isAtEnd  {
				let blockValue = try scanner.scan(upTo: separator)
				XCTAssert( (blockValue == validValues[idx]) , "Failed to validate scan(upTo:<String>)")
				if (idx < validValues.count) { try scanner.skip(length: separator.characters.count) }
				idx += 1
			}
		} catch let err {
			XCTFail("scan(upTo:<String>) does not work properly: \(err)")
		}

	}
	
	func testScanLength() {
		let separator = ",\n"
		let test = "123\(separator)456\(separator)678\(separator)987"
		let validValues: [String] = ["123","456","678","987"]

		let scanner = StringScanner(test)
		var idx = 0
		
		do {
			while !scanner.isAtEnd  {
				let blockValue = try scanner.scan(length: 3)
				XCTAssert( (blockValue == validValues[idx]) , "Failed to validate scan(length:)")
				idx += 1
				if (idx < validValues.count) {
					try scanner.skip(length: separator.characters.count)
				}
			}
		} catch let err {
			XCTFail("scan(length:) does not work properly: \(err)")
		}

	}
	
	func testPeekUpToChar() {
		let test = "abc;defg;hilmn;"
		let validDistances = [3,4,5]
		let scanner = StringScanner(test)
		var idx = 0
		
		do {
			while !scanner.isAtEnd  {
				let currentPosition = scanner.position
				let separatorPosition = try scanner.peek(upTo: ";")
				let distance = scanner.string.distance(from: currentPosition, to: separatorPosition)
				try scanner.skip(length: distance+1)
				XCTAssert( (distance == validDistances[idx]) , "Failed to validate peek(upTo:<UnicodeScalar>)")
				idx += 1
			}
		} catch let err {
			XCTFail("peek(upTo:<UnicodeScalar>) does not work properly: \(err)")
		}
	}
	
	func testPeekUpToCharset() {
		let test = "hello, again!I'm daniele.And you?"
		let validDistances = [5,6,11,8]
		let scanner = StringScanner(test)
		var idx = 0
		
		do {
			while !scanner.isAtEnd  {
				let currentPosition = scanner.position
				let separatorPosition = try scanner.peek(upTo: CharacterSet(charactersIn: ",!."))
				let distance = scanner.string.distance(from: currentPosition, to: separatorPosition)
				try scanner.skip(length: distance+1)
				XCTAssert( (distance == validDistances[idx]) , "Failed to validate peek(upTo:<CharacterSet>)")
				idx += 1
			}
		} catch let err {
			guard let error = err as? StringScannerError else { return }
			if case .eof = error { // handle last scanner.skip(length:)
				return
			}
			XCTFail("peek(upTo:<CharacterSet>) does not work properly: \(error)")
		}
	}
	
	func testPeekUpUntilCharset() {
		let test = "HELLOman!"
		let scanner = StringScanner(test)

		do {
			let startPosition = scanner.position
			let endPosition = try scanner.peek(untilIn: CharacterSet.uppercaseLetters)
			let distance = scanner.string.distance(from: startPosition, to: endPosition)
			XCTAssert( (distance == 5) , "Failed to validate peek(untilIn:<CharacterSet>)")
		} catch let err {
			XCTFail("peek(untilIn:<CharacterSet>) does not work properly: \(err)")
		}
	}
	
	func testPeekUpToString() {
		let test = "Never be satisfied 💪 and always push yourself!"
		let scanner = StringScanner(test)
		do {
			let startPosition = scanner.position
			let endPosition = try scanner.peek(upTo: "💪")
			let distance = scanner.string.distance(from: startPosition, to: endPosition)
			XCTAssert( (distance == 19) , "Failed to validate peek(upTo:String)")
		} catch let err {
			XCTFail("peek(upTo:String) does not work properly: \(err)")
		}
	}
	
	func testScanUntilTrueOnTest() {
		let test = "Never be satisfied 💪 and always push yourself! 😎 Do the things people say cannot be done"
		let validated = ["Never be satisfied "," and always push yourself! "," Do the things people say cannot be done"]
		let delimiters = CharacterSet(charactersIn: "💪😎")
		let scanner = StringScanner(test)
		var idx = 0
		
		do {
			while !scanner.isAtEnd {
				let block = scanner.scan(untilTrue: { char in
					return (delimiters.contains(char) == false)
				})
				XCTAssert( (block == validated[idx]) , "Failed to validate scan(untilTrue:)")
				try scanner.skip()
				idx += 1
			}
		} catch let err {
			guard let error = err as? StringScannerError else { return }
			if case .eof = error { // handle last scanner.skip(length:)
				return
			}
			XCTFail("scan(untilTrue:) does not work properly: \(error)")
		}
	}
	
	func testPeekUntilTrueOnTest() {
		let test = "I'm very 💪 and 😎 Go!"
		let delimiters = CharacterSet(charactersIn: "💪😎")
		var validatedDistances = [9,5,4]
		let scanner = StringScanner(test)
		var idx = 0
		
		do {
			while !scanner.isAtEnd {
				let prevIndex = scanner.position
				let finalIndex = scanner.peek(untilTrue: { char in
					return (delimiters.contains(char) == false)
				})
				let distance = scanner.string.distance(from: prevIndex, to: finalIndex)
				XCTAssert( (distance == validatedDistances[idx]) , "Failed to validate peek(untilTrue:)")
				try scanner.skip(length: distance + 1)
				idx += 1
			}
		} catch let err {
			guard let error = err as? StringScannerError else { return }
			if case .eof = error { // handle last scanner.skip(length:)
				return
			}
			XCTFail("scan(untilTrue:) does not work properly: \(error)")
		}
	}
	
	func testMatch() {
		let test_match = "hello man! push yourself!"
		let scanner = StringScanner(test_match)
		
		// test match
		do {
			try scanner.match("hello man!")
			XCTAssertTrue(true)
		} catch let err {
			XCTFail("match(<String>) does not work properly: \(err)")
		}
		
		// test don't match
		scanner.reset() // reset from the start
		try! scanner.scan(upTo: "! ") // move to the next token
		try! scanner.skip(length: 2)
		do {
			try scanner.match("hello man")
			XCTFail("match(<String>) does not work properly")
		} catch {
			XCTAssertTrue(true)
		}
	}
	
	func testReset() {
		let test = "hello man! push yourself"
		
		func randomNumber(range: Range<Int>) -> Int {
			return Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound))) + range.lowerBound
		}
		
		let scanner = StringScanner(test)
		let length = test.characters.count
		
		var idx = 0
		do {
			while idx < 10 {
				let distance = randomNumber(range: 0..<length)
				try scanner.skip(length: distance)
				XCTAssert( (scanner.consumed == distance) , "Failed to validate skip(length:)")
				scanner.reset()
				XCTAssert( (scanner.consumed == 0 && scanner.string.startIndex == scanner.position) , "Failed to validate reset()")
				idx += 1
			}
		} catch {
			XCTFail("skip(length:) does not work properly")
		}
	}
	
	func testBackLength() {
		let test = "a........b....c.."
		let validatedLines = ["c","b","a"]
		let backLenghts = [3,5,9]
		var idx = 0
		
		let scanner = StringScanner(test)
		do {
			scanner.peekAtEnd() // null termination index
			while true {
				if idx >= validatedLines.count {
					break
				}
				let backLen = backLenghts[idx]
				try scanner.back(length: backLen)
				let scanner_char = try scanner.scanChar()
				let valid_char = validatedLines[idx]
				let isValid = (String(scanner_char) == valid_char)
				XCTAssert( isValid, "Failed to validate back()")
				try scanner.back()
				idx += 1
			}
		} catch {
			XCTFail("back() does not work properly")
		}
	}
	
	func testBack() {
		let test = "hello, i'm daniele and this is a great library!"
		let scanner = StringScanner(test)
		
		do {
			scanner.peekAtEnd() // null termination index
			try scanner.back() // back from null termination char
			var positionInChar = 1 // back from null termination char
			while true {
				let test_charIdx = test.unicodeScalars.index(test.unicodeScalars.endIndex, offsetBy: -positionInChar)
				let test_char = test.unicodeScalars[test_charIdx]
				let scanner_char = scanner.string[scanner.position]
				XCTAssert( (test_char == scanner_char) , "Failed to validate back()")
				
				if positionInChar < test.characters.count {
					try scanner.back()
					positionInChar += 1
				} else {
					break
				}
			}
		} catch {
			XCTFail("back() does not work properly")
		}
	}
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

