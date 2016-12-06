//
//  ViewController.swift
//  DemoApp
//
//  Created by Daniele Margutti on 02/12/2016.
//  Copyright © 2016 Daniele Margutti. All rights reserved.
//

import UIKit
import SwiftScanner

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let hex32 = "0x00000016"
		let hex64 = "-12.5"
		let s = StringScanner(hex64)
		let x = try! s.scanFloat()
		print(x)
		
		/*
		let c = "ciao <bold>valore</bold> come <italic>va</italic>"
		let w = try! String(contentsOfFile: Bundle.main.path(forResource: "file", ofType: "txt")!)
		var acc =  ""
		let s = StringScanner(w)
		do {
			while !s.isAtEnd {
				if let text = try s.scan(upTo: CharacterSet(charactersIn: "<")) {
					acc += text
				} else {
					try! s.scanChar()
					let endTag = try! s.scan(upTo: CharacterSet(charactersIn: ">"))
					//print(endTag)
					try! s.scanChar()
				}
			}
		} catch let err {
			print(err)
		}
		print("done")*/
	}
		

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

