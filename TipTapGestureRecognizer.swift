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
	case left, middle, right
}


@objc public protocol TipTapGestureRecognizerDelegate: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: TipTapGestureRecognizer, didRecognizeTipTap tipTapType: TipTapType)
}



let TipTapGestureMaximumTapDuration: TimeInterval = 0.25
let TipTapGestureMinimumDragDistance: CGFloat = 105.0


open class TipTapGestureRecognizer: UIGestureRecognizer {
	@objc open var maximumTapDuration: TimeInterval = TipTapGestureMaximumTapDuration
	@objc open var minimumDragDistance: CGFloat = TipTapGestureMinimumDragDistance

	@objc open var requiredNumberOfSourceTaps: Int = 1
	@objc open var requiredNumberOfTipTaps: Int = 1
	@objc open var requiredNumberOfCombinedTaps: Int = 2
	@objc open var maximumNumberOfSourceTaps: Int = Int.max
	@objc open var maximumNumberOfTipTaps: Int = Int.max
	@objc open var maximumNumberOfCombinedTaps: Int = Int.max

	@objc open var tapCount: Int = 0
	
	
	internal var currentTouches: [UITouch: (startTimestamp: TimeInterval, startPosition: CGPoint)] = [:]
	
	
	override init(target: Any?, action: Selector?) {
		super.init(target: target, action: action)
		
		reset()
	}


	open override func reset() {
		currentTouches.removeAll()
		tapCount = 0
		
		state = .possible
	}
	
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		guard let view = view else {
			return
		}
		
		for touch in touches {
			currentTouches[touch] = (event.timestamp, touch.location(in: view))
		}
		
		if(state == .possible) {
			state = .began
		} else {
			state = .changed
		}
	}
	
	
	open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
		guard let view = view else {
			return
		}
		
		let currentTime = event.timestamp
		
		for touch in touches {
			if let touchDetails = currentTouches[touch] , (currentTime - touchDetails.startTimestamp) > maximumTapDuration {
				let touchPosition = touch.location(in: view)
				
				if CGPoint.distanceBetweenPoints(touchDetails.startPosition, touchPosition) > minimumDragDistance {
					state = .failed
					return
				}
			}
		}
		
		state = .changed
	}
	
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		var sourceTouches = Set(currentTouches.keys)
		let currentTime = event.timestamp
		var tapTouches: [UITouch] = []
		
		for touch in touches {
			if let touchDetails = currentTouches[touch] , (currentTime - touchDetails.startTimestamp) < maximumTapDuration {
				tapTouches.append(touch)
				sourceTouches.remove(touch)
			}
			
			currentTouches[touch] = nil
		}
		
		
		let numberOfTapTouches = tapTouches.count
		let numberOfSourceTouches = sourceTouches.count
		let combinedNumberOfTouches = numberOfTapTouches + numberOfSourceTouches
		
		if let view = view , !tapTouches.isEmpty &&
			(numberOfTapTouches >= requiredNumberOfTipTaps) && (numberOfTapTouches <= maximumNumberOfTipTaps)
				&& (numberOfSourceTouches >= requiredNumberOfSourceTaps) && (numberOfSourceTouches <= maximumNumberOfSourceTaps)
					&& (combinedNumberOfTouches >= requiredNumberOfCombinedTaps) && (combinedNumberOfTouches <= maximumNumberOfCombinedTaps) {
			
			let tapPoints = tapTouches.map { (touch) -> (CGPoint) in
				return touch.location(in: view)
			}
			
			let sourcePoints = sourceTouches.map { (touch) -> (CGPoint) in
				return touch.location(in: view)
			}
			
			
			let tapPoint = CGPoint.averageOfPoints(tapPoints)
			let sourceRect = CGRect(containingPoints: sourcePoints)
			let type: TipTapType
			
			if tapPoint.x <= sourceRect.minX {
				type = .left
			} else if tapPoint.x >= sourceRect.maxX {
				type = .right
			} else {
				type = .middle
			}
			
			state = .changed
			tapCount += 1
			
			if let delegate = delegate as? TipTapGestureRecognizerDelegate {
				delegate.gestureRecognizer(self, didRecognizeTipTap: type)
			}
		} else {
			if currentTouches.isEmpty {
				if tapCount > 0 {
					state = .ended
				} else {
					state = .failed
				}
			} else {
				state = .changed
			}
		}
	}
	
			
	open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
		touchesEnded(touches, with: event)
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

	static func averageOfPoints(_ points: [CGPoint]) -> CGPoint {
		let combinedPoints = points.reduce(CGPoint.zero) {
			return CGPoint(x: ($0.x + $1.x), y: ($0.y + $1.y))
		}

		let numberOfSourceTouches = points.count
		let averagedPoint = CGPoint(x: combinedPoints.x / CGFloat(numberOfSourceTouches), y: combinedPoints.y / CGFloat(numberOfSourceTouches))

		return averagedPoint
	}
	
	
	static func distanceBetweenPoints(_ firstPoint: CGPoint, _ secondPoint: CGPoint) -> CGFloat {
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
