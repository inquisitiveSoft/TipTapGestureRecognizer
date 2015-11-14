//
//  TipTapView.swift
//  TipTap
//
//  Created by Harry Jordan on 14/11/2015.
//  Copyright © 2015 Inquisitive Software. All rights reserved.
//
//	Released under the MIT License: http://www.opensource.org/licenses/MIT
//


import UIKit


class TipTapView: UIView {
	var sourcePointColor: UIColor = .blueColor()
	var fingertipSize = CGSize(width: 100.0, height: 100.0)
	
	var sourcePoints: [CGPoint] = [] {
		didSet {
			setNeedsDisplay()
		}
	}

	
	override func drawRect(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		
		let drawFingertip = { (point: CGPoint, fingertipSize: CGSize, color: UIColor) -> () in
			let fingerRect = CGRect(x: point.x - (fingertipSize.width / 2.0), y: point.y - (fingertipSize.width / 2.0), width: fingertipSize.width, height: self.fingertipSize.height)
			
			CGContextSetStrokeColorWithColor(context, color.CGColor)
			CGContextStrokeEllipseInRect(context, fingerRect)
		}
		
		for point in sourcePoints {
			drawFingertip(point, fingertipSize, sourcePointColor)
		}
	}
	
}