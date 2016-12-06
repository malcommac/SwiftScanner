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
		
		do {
			let scanner = StringScanner(test)
			while !scanner.isAtEnd {
				let currentScalar = try scanner.scanChar()
				XCTAssert( (currentScalar == testScalars[idx]) , "Failed to validate scanChar()")
				idx = testScalars.index(after: idx)
			}
		} catch let err {
			XCTFail("scanChar() does not work properly: \(err)")
		}
	}
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
