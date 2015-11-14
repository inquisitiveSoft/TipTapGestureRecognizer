//
//  TipTapExampleGestureRecognizer.swift
//  TipTap
//
//  Created by Harry Jordan on 14/11/2015.
//  Copyright © 2015 Inquisitive Software. All rights reserved.
//
//	Released under the MIT License: http://www.opensource.org/licenses/MIT
//

import Foundation


protocol TipTapExampleGestureRecognizerDelegate: TipTapGestureRecognizerDelegate {
	func gestureRecognizerDidChange(gestureRecognizer: TipTapGestureRecognizer)
}


class TipTapExampleGestureRecognizer: TipTapGestureRecognizer {

	override var state: UIGestureRecognizerState {
		didSet {
			if let delegate = delegate as? TipTapExampleGestureRecognizerDelegate {
				delegate.gestureRecognizerDidChange(self)
			}
		}
	}

}