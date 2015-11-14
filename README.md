TipTapGestureRecognizer
-----------------------
Tip tap!

It's similar to a gesture that you can find in the excellent BetterTouchTool for Mac.

Also might be handy as an example of a custom gesture recognizer written in Swift.

# Integration
- Drag the TipTapGestureRecognizer.swift file into your project
- You'll need to add: `#import <UIKit/UIGestureRecognizerSubclass.h>` to your projects `Bridging-Header.h`
- Create the gesture recognizer, add it to a view and set it's delegate to something that implements the `gestureRecognizer(, didRecognizeTipTap:)` method.
- You're done!

Also.. `tipTapType` is so much fun to write.

# License
Released under the MIT License: http://www.opensource.org/licenses/MIT