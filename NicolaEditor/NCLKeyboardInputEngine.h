//
//  NCLKeyboardInputEngine.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/09.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NCLKeyboardEvent) {
    NCLKeyboardEventKeyPressed = 0,
    NCLKeyboardEventKeyUp
};

extern NSString * const NCLKeyboardInputModeKana;
extern NSString * const NCLKeyboardInputModeAlphabet;
extern NSString * const NCLKeyboardInputModeNumber;

@interface NCLKeyboardInputEngine : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic) NSString *inputMode;
@property (nonatomic) NSTimeInterval delay;

@property (nonatomic, getter = isShifted) BOOL shifted;

+ (id)inputEngineWithShiftKeyBehavior:(NSString *)shiftKeyBehavior;

- (void)addInput:(NSInteger)input;

- (void)addLeftShiftKeyEvent:(NCLKeyboardEvent)event;
- (void)addRightShiftKeyEvent:(NCLKeyboardEvent)event;

@end

@protocol NCLKeyboardInputEngineDelegate <NSObject>

- (void)keyboardInputEngine:(NCLKeyboardInputEngine *)engine processedText:(NSString *)text keyIndex:(NSInteger)keyIndex;

@end
