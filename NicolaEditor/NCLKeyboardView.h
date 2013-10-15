//
//  NCLKeyboardView.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/05.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const NCLKeyboardShiftKeyBehaviorTimeShift;
extern NSString * const NCLKeyboardShiftKeyBehaviorContinuityShift;
extern NSString * const NCLKeyboardShiftKeyBehaviorPrefixShift;

extern NSString * const NCLKeyboardShiftKeyFunctionNextCandidate;
extern NSString * const NCLKeyboardShiftKeyFunctionAcceptCandidate;
extern NSString * const NCLKeyboardShiftKeyFunctionNone;

@interface NCLKeyboardView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) UITextView *textView;

@property (nonatomic) NSString *inputMode;

@end

@protocol NCLKeyboardViewDelegate <NSObject>

@end
