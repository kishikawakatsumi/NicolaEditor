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
- (void)processDeleteKeyDown;
- (void)processDeleteKeyUp;

@end

@protocol NCLKeyboardViewDelegate <NSObject>

- (void)keyboardView:(NCLKeyboardView *)view inputText:(NSString *)text;
- (void)keyboardViewInputEnter:(NCLKeyboardView *)view;
- (void)keyboardViewInputBackspace:(NCLKeyboardView *)view;
- (void)keyboardViewInputShiftDown:(NCLKeyboardView *)view;
- (void)keyboardViewInputShiftUp:(NCLKeyboardView *)view;
- (void)keyboardViewInputSpace:(NCLKeyboardView *)view;
- (void)keyboardViewInputNextCandidate:(NCLKeyboardView *)view;
- (void)keyboardViewInputHideKeyboard:(NCLKeyboardView *)view;

@end
