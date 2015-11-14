//
//  TipTapGestureRecognizer.swift
//  TipTap
//
//  Created by Harry Jordan on 14/11/2015.
//  Copyright © 2015 Inquisitive Software. All rights reserved.
//
//	If used in an app which contains you'll need to add
//	'#import <UIKit/UIGestureRecognizerSubclass.h>' to your BridgingHeader
//	so that the touches… can be overridden
//
//	Released under the MIT License: http://www.opensource.org/licenses/MIT
//


import UIKit


enum TipTapType: Int {
	case Left, Middle, Right
}


protocol TipTapGestureRecognizerDelegate: UIGestureRecognizerDelegate {
	func gestureRecognizer(gestureRecognizer: TipTapGestureRecognizer, didRecognizeTipTap tipTapType: TipTapType)
}



let TipTapGestureMinimumDragDistance: NSTimeInterval = 5.0
let TipTapGestureMaximumTapDuration: NSTimeInterval = 0.25


public class TipTapGestureRecognizer: UIGestureRecognizer {
	public var maximumTapDuration: NSTimeInterval = TipTapGestureMaximumTapDuration

	public var requiredNumberOfSourceTaps: Int = 1
	public var requiredNumberOfTipTaps: Int = 1
	public var maximumNumberOfSourceTaps: Int = Int.max
	public var maximumNumberOfTipTaps: Int = Int.max

	internal var currentTouches: [UITouch: NSTimeInterval] = [:]
	
	
	override init(target: AnyObject?, action: Selector) {
		super.init(target: target, action: action)
		
		reset()
	}


	public override func reset() {
		currentTouches.removeAll()
		state = .Possible
	}
	
	
	public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
		for touch in touches {
			currentTouches[touch] = event.timestamp
		}
		
		if(state == .Possible) {
			state = .Began
		} else {
			state = .Changed
		}
	}
	
	
	public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
		state = .Changed
	}
	
	
	public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
		var sourceTouches = Set(currentTouches.keys)
		let currentTime = event.timestamp
		var tapTouches: [UITouch] = []
		
		for touch in touches {
			if let startTouchTimestamp = currentTouches[touch] where (currentTime - startTouchTimestamp) < maximumTapDuration {
				tapTouches.append(touch)
				sourceTouches.remove(touch)
			}
			
			currentTouches[touch] = nil
		}
		
		if let view = view where !tapTouches.isEmpty &&
			(tapTouches.count >= requiredNumberOfTipTaps) && (tapTouches.count <= maximumNumberOfTipTaps)
				&& (sourceTouches.count >= requiredNumberOfSourceTaps) && (tapTouches.count <= maximumNumberOfSourceTaps) {
			
			let tapPoints = tapTouches.map { (touch) -> (CGPoint) in
				return touch.locationInView(view)
			}
			
			let sourcePoints = sourceTouches.map { (touch) -> (CGPoint) in
				return touch.locationInView(view)
			}
			
			
			let tapPoint = CGPoint.averageOfPoints(tapPoints)
			let sourceRect = CGRect(containingPoints: sourcePoints)
			let type: TipTapType
			
			if tapPoint.x <= sourceRect.minX {
				type = .Left
			} else if tapPoint.x >= sourceRect.maxX {
				type = .Right
			} else {
				type = .Middle
			}
			
			state = .Changed
			
			if let delegate = delegate as? TipTapGestureRecognizerDelegate {
				delegate.gestureRecognizer(self, didRecognizeTipTap: type)
			}
		} else {
			if currentTouches.isEmpty {
				state = .Ended
			} else {
				state = .Changed
			}
		}
	}
	
			
	public override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
		touchesEnded(touches, withEvent: event)
	}

}



extension CGRect {
	
	init(containingPoints: [CGPoint]) {
		guard let firstPoint = containingPoints.first else {
			self = CGRect.null
			return
		}
		
		var topLeftPoint: CGPoint = firstPoint
		var bottomRightPoint: CGPoint = firstPoint
		
		for point in containingPoints {
			topLeftPoint.x = min(point.x, topLeftPoint.x)
			topLeftPoint.y = min(point.y, topLeftPoint.y)
			bottomRightPoint.x = max(point.x, bottomRightPoint.x)
			bottomRightPoint.y = max(point.y, bottomRightPoint.y)
		}
		
		self = CGRect(origin: topLeftPoint, size: CGSize(width: bottomRightPoint.x - topLeftPoint.x, height: bottomRightPoint.y - topLeftPoint.y))
	}

}


extension CGPoint {

	static func averageOfPoints(points: [CGPoint]) -> CGPoint {
		let combinedPoints = points.reduce(CGPointZero) {
			return CGPoint(x: ($0.x + $1.x), y: ($0.y + $1.y))
		}

		let numberOfSourceTouches = points.count
		let averagedPoint = CGPoint(x: combinedPoints.x / CGFloat(numberOfSourceTouches), y: combinedPoints.y / CGFloat(numberOfSourceTouches))

		return averagedPoint
	}
	
}