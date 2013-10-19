//
//  NCLKeyboardView.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/05.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

@import UIKit;

@interface NCLKeyboardView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) UITextView *textView;

@property (nonatomic) NSString *keyboardInputMethod;

- (void)cursorUp;
- (void)cursorDown;
- (void)cursorLeft;
- (void)cursorRight;

@end

@protocol NCLKeyboardViewDelegate <NSObject>

@end
