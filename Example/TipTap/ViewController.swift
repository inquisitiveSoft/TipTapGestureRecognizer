//
//  ViewController.swift
//  TipTap
//
//  Created by Harry Jordan on 14/11/2015.
//  Copyright © 2015 Inquisitive Software. All rights reserved.
//
//	Released under the MIT License: http://www.opensource.org/licenses/MIT
//


import UIKit


class ViewController: UIViewController, TipTapExampleGestureRecognizerDelegate {
	@IBOutlet weak var tipTapView: TipTapView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//
		let gestureRecognizer = TipTapExampleGestureRecognizer()
		gestureRecognizer.delegate = self
		
		tipTapView.addGestureRecognizer(gestureRecognizer)
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func gestureRecognizerDidChange(gestureRecognizer: TipTapGestureRecognizer) {
		tipTapView.sourcePoints = gestureRecognizer.currentTouches.keys.flatMap { (touch) -> (CGPoint) in
			return touch.locationInView(tipTapView)
		}
		
		tipTapView.setNeedsDisplay()
	}
	
	
	func gestureRecognizer(gestureRecognizer: TipTapGestureRecognizer, didRecognizeTipTap tipTap: TipTapType) {
		print("tipTap: \(tipTap)")
	}

}

