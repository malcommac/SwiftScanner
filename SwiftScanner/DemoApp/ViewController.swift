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
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	
		let filePath =  Bundle(for: ViewController.self).path(forResource: "sample_file", ofType: "html")
		let source = try! String(contentsOfFile: filePath!)
		var acc =  ""
		let s = StringScanner(source)
		do {
			while !s.isAtEnd {
				if let text = try s.scan(upTo: CharacterSet(charactersIn: "<")) {
					acc += text
				} else {
					try! s.scanChar()
					let endTag = try! s.scan(upTo: CharacterSet(charactersIn: ">"))
					print(endTag)
					try! s.scanChar()
				}
			}
		} catch let err {
			print(err)
		}
		print("done")
	}
		

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

