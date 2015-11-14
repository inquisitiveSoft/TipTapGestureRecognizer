TipTapGestureRecognizer
-----------------------
Tip tap!
It's similar to a gesture that you can find in the excellent BetterTouchTool for Mac.

Also might be handy as an example of a custom gesture recognizer written in Swift.

# Integration
TipTapGestureRecognizer is entirely written in Swift.

- To use it to your app you'll need to add: `#import <UIKit/UIGestureRecognizerSubclass.h>`  to your projects `Bridging-Header.h`.
- Create the gesture recognizer, add it to a view and set it's delegate to somethign that implement the `gestureRecognizer(, didRecognizeTipTap:)` method.
- tipTapType is so much fun to write.

# License
Released under the MIT License: http://www.opensource.org/licenses/MIT