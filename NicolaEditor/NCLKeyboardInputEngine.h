//
//  NCLKeyboardInputEngine.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/09.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, NCLKeyboardEvent) {
    NCLKeyboardEventKeyPressed = 0,
    NCLKeyboardEventKeyUp
};

@interface NCLKeyboardInputEngine : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic) NSString *inputMethod;
@property (nonatomic) NSTimeInterval delay;

@property (nonatomic, getter = isShifted) BOOL shifted;

+ (id)inputEngineWithShiftKeyBehavior:(NSString *)shiftKeyBehavior;
+ (id)keyboardLayoutNamed:(NSString *)name;

- (void)addKeyInput:(NSInteger)input;

- (void)addLeftShiftKeyEvent:(NCLKeyboardEvent)event;
- (void)addRightShiftKeyEvent:(NCLKeyboardEvent)event;

@end

@interface NCLPhysicalKeyboardInputEngine : NCLKeyboardInputEngine

@end

@protocol NCLKeyboardInputEngineDelegate <NSObject>

- (void)keyboardInputEngine:(NCLKeyboardInputEngine *)engine processedText:(NSString *)text keyIndex:(NSInteger)keyIndex;
- (void)keyboardInputEngineDidInputLeftShiftKey:(NCLKeyboardInputEngine *)engine;
- (void)keyboardInputEngineDidInputRightShiftKey:(NCLKeyboardInputEngine *)engine;

@end
