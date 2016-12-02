//
//  StringScanner.swift
//  SwiftScanner
//
//  Created by Daniele Margutti on 02/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import Foundation

public enum Result {
	case value(String)
	case none
	case end
}

public class StringScanner {
	private let string: String
	private var index: Int
	
	private lazy var length: Int = {
		return self.string.characters.count
	}()
	
	public init(_ string: String) {
		self.string = string
		self.index = 0
	}
	
}
