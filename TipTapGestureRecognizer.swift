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


@objc public enum TipTapType: Int {
	case Left, Middle, Right
}


@objc public protocol TipTapGestureRecognizerDelegate: UIGestureRecognizerDelegate {
	func gestureRecognizer(gestureRecognizer: TipTapGestureRecognizer, didRecognizeTipTap tipTapType: TipTapType)
}



let TipTapGestureMaximumTapDuration: NSTimeInterval = 0.25
let TipTapGestureMinimumDragDistance: CGFloat = 105.0


public class TipTapGestureRecognizer: UIGestureRecognizer {
	public var maximumTapDuration: NSTimeInterval = TipTapGestureMaximumTapDuration
	public var minimumDragDistance: CGFloat = TipTapGestureMinimumDragDistance

	public var requiredNumberOfSourceTaps: Int = 1
	public var requiredNumberOfTipTaps: Int = 1
	public var requiredNumberOfCombinedTaps: Int = 2
	public var maximumNumberOfSourceTaps: Int = Int.max
	public var maximumNumberOfTipTaps: Int = Int.max
	public var maximumNumberOfCombinedTaps: Int = Int.max

	public var tapCount: Int = 0
	
	
	internal var currentTouches: [UITouch: (startTimestamp: NSTimeInterval, startPosition: CGPoint)] = [:]
	
	
	override init(target: AnyObject?, action: Selector) {
		super.init(target: target, action: action)
		
		reset()
	}


	public override func reset() {
		currentTouches.removeAll()
		tapCount = 0
		
		state = .Possible
	}
	
	
	public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
		guard let view = view else {
			return
		}
		
		for touch in touches {
			currentTouches[touch] = (event.timestamp, touch.locationInView(view))
		}
		
		if(state == .Possible) {
			state = .Began
		} else {
			state = .Changed
		}
	}
	
	
	public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
		guard let view = view else {
			return
		}
		
		let currentTime = event.timestamp
		
		for touch in touches {
			if let touchDetails = currentTouches[touch] where (currentTime - touchDetails.startTimestamp) > maximumTapDuration {
				let touchPosition = touch.locationInView(view)
				
				if CGPoint.distanceBetweenPoints(touchDetails.startPosition, touchPosition) > minimumDragDistance {
					state = .Failed
					return
				}
			}
		}
		
		state = .Changed
	}
	
	
	public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
		var sourceTouches = Set(currentTouches.keys)
		let currentTime = event.timestamp
		var tapTouches: [UITouch] = []
		
		for touch in touches {
			if let touchDetails = currentTouches[touch] where (currentTime - touchDetails.startTimestamp) < maximumTapDuration {
				tapTouches.append(touch)
				sourceTouches.remove(touch)
			}
			
			currentTouches[touch] = nil
		}
		
		
		let numberOfTapTouches = tapTouches.count
		let numberOfSourceTouches = sourceTouches.count
		let combinedNumberOfTouches = numberOfTapTouches + numberOfSourceTouches
		
		if let view = view where !tapTouches.isEmpty &&
			(numberOfTapTouches >= requiredNumberOfTipTaps) && (numberOfTapTouches <= maximumNumberOfTipTaps)
				&& (numberOfSourceTouches >= requiredNumberOfSourceTaps) && (numberOfSourceTouches <= maximumNumberOfSourceTaps)
					&& (combinedNumberOfTouches >= requiredNumberOfCombinedTaps) && (combinedNumberOfTouches <= maximumNumberOfCombinedTaps) {
			
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
			tapCount += 1
			
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
	
	
	static func distanceBetweenPoints(firstPoint: CGPoint, _ secondPoint: CGPoint) -> CGFloat {
		let distance = CGSize(width: fabs(secondPoint.x - firstPoint.x), height: fabs(secondPoint.y - firstPoint.y))
		let epsilon: CGFloat = 0.0001
		
		if(distance.width < epsilon) {
			return distance.height;
		} else if (distance.height < epsilon) {
			return distance.width;
		}
		
		return CGFloat(sqrt(Double(distance.width * distance.width) + Double(distance.height * distance.height)))
	}
}