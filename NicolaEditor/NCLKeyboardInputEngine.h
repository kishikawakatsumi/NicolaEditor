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

typedef NS_ENUM(NSInteger, NCLKeyboardKeyType) {
    NCLKeyboardKeyTypeCharacter = 0,
    NCLKeyboardKeyTypeLeftShift,
    NCLKeyboardKeyTypeRightShift
};

typedef NS_ENUM(NSInteger, NCLKeyboardShiftState) {
    NCLKeyboardShiftStateNone = 0,
    NCLKeyboardShiftStateLeftShifted,
    NCLKeyboardShiftStateRightShifted
};

@interface NCLKeyboardInput : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic) NCLKeyboardKeyType type;
@property (nonatomic) NSTimeInterval timestamp;

@property (nonatomic, getter = isUsed) BOOL used;

@end

extern NSString * const NCLKeyboardInputMethodKana;
extern NSString * const NCLKeyboardInputMethodAlphabet;
extern NSString * const NCLKeyboardInputMethodNumberPunctuation;

@interface NCLKeyboardInputEngine : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic) NSString *inputMethod;
@property (nonatomic) NSTimeInterval delay;

@property (nonatomic, getter = isShifted) BOOL shifted;

+ (id)inputEngineWithShiftKeyBehavior:(NSString *)shiftKeyBehavior;

- (void)addKeyInput:(NSInteger)input;

- (void)addLeftShiftKeyEvent:(NCLKeyboardEvent)event;
- (void)addRightShiftKeyEvent:(NCLKeyboardEvent)event;

@end

@protocol NCLKeyboardInputEngineDelegate <NSObject>

- (void)keyboardInputEngine:(NCLKeyboardInputEngine *)engine processedText:(NSString *)text keyIndex:(NSInteger)keyIndex;
- (void)keyboardInputEngineDidInputLeftShiftKey:(NCLKeyboardInputEngine *)engine;
- (void)keyboardInputEngineDidInputRightShiftKey:(NCLKeyboardInputEngine *)engine;

@end
