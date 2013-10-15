//
//  NCLKeyboardInputEngine.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/09.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLKeyboardInputEngine.h"
#import "NCLKeyboardView.h"

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

NSString * const NCLKeyboardInputModeKana = @"Kana";
NSString * const NCLKeyboardInputModeAlphabet = @"Alphabet";
NSString * const NCLKeyboardInputModeNumber = @"Number";

@interface NCLKeyboardInput : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic) NCLKeyboardKeyType type;
@property (nonatomic) NSTimeInterval timestamp;

@end

@implementation NCLKeyboardInput

@end

@interface NCLKeyboardInputEngine ()

@property (nonatomic) NSDictionary *keyboardLayouts;

@end

@interface NCLKeyboardTimeShiftInputEngine : NCLKeyboardInputEngine

@property (nonatomic) NSMutableArray *keyInputQueue;

@end

@interface NCLKeyboardContinuityShiftInputEngine : NCLKeyboardInputEngine

@end

@interface NCLKeyboardPrefixShiftInputEngine : NCLKeyboardInputEngine

@property (nonatomic) NCLKeyboardShiftState shiftState;

@end

@implementation NCLKeyboardInputEngine

+ (id)inputEngineWithShiftKeyBehavior:(NSString *)shiftKeyBehavior
{
    if ([shiftKeyBehavior isEqualToString:NCLKeyboardShiftKeyBehaviorTimeShift]) {
        return [[NCLKeyboardTimeShiftInputEngine alloc] init];
    } else if ([shiftKeyBehavior isEqualToString:NCLKeyboardShiftKeyBehaviorContinuityShift]) {
        return [[NCLKeyboardContinuityShiftInputEngine alloc] init];
    } else if ([shiftKeyBehavior isEqualToString:NCLKeyboardShiftKeyBehaviorPrefixShift]) {
        return [[NCLKeyboardPrefixShiftInputEngine alloc] init];
    }
    
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSData *data = [NSData dataWithContentsOfURL:[mainBundle URLForResource:@"KeyboardLayouts" withExtension:@"json"]];
        self.keyboardLayouts = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    
    return self;
}

- (void)addInput:(NSInteger)input
{
    
}

- (void)addLeftShiftKeyEvent:(NCLKeyboardEvent)event
{
    
}

- (void)addRightShiftKeyEvent:(NCLKeyboardEvent)event
{
    
}

@end

@implementation NCLKeyboardTimeShiftInputEngine

- (id)init
{
    self = [super init];
    if (self) {
        self.keyInputQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addInput:(NSInteger)input
{
    NCLKeyboardInput *keyInput = [[NCLKeyboardInput alloc] init];
    keyInput.index = input;
    keyInput.type = NCLKeyboardKeyTypeCharacter;
    keyInput.timestamp = CACurrentMediaTime();
    [_keyInputQueue addObject:keyInput];
    
    double delayInSeconds = self.delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self proccessInput:keyInput];
    });
}

#pragma mark -

- (void)addLeftShiftKeyEvent:(NCLKeyboardEvent)event
{
    if (event == NCLKeyboardEventKeyPressed) {
        NCLKeyboardInput *keyInput = [[NCLKeyboardInput alloc] init];
        keyInput.type = NCLKeyboardKeyTypeLeftShift;
        keyInput.timestamp = CACurrentMediaTime();
        [_keyInputQueue addObject:keyInput];
        
        double delayInSeconds = self.delay * 2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self proccessInput:keyInput];
        });
    } else if (event == NCLKeyboardEventKeyUp) {
        
    }
}

- (void)addRightShiftKeyEvent:(NCLKeyboardEvent)event
{
    if (event == NCLKeyboardEventKeyPressed) {
        NCLKeyboardInput *keyInput = [[NCLKeyboardInput alloc] init];
        keyInput.type = NCLKeyboardKeyTypeRightShift;
        keyInput.timestamp = CACurrentMediaTime();
        [_keyInputQueue addObject:keyInput];
        
        double delayInSeconds = self.delay * 2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self proccessInput:keyInput];
        });
    } else if (event == NCLKeyboardEventKeyUp) {
        
    }
}

#pragma mark -

- (void)proccessInput:(NCLKeyboardInput *)keyInput
{
    NSInteger queueIndex = [_keyInputQueue indexOfObject:keyInput];
    if (queueIndex == NSNotFound) {
        return;
    }
    
    if (keyInput.type == NCLKeyboardKeyTypeCharacter) {
        NCLKeyboardShiftState shiftState = NCLKeyboardShiftStateNone;
        
        if (_keyInputQueue.count > queueIndex - 1) {
            NCLKeyboardInput *previousKeyInput = _keyInputQueue[queueIndex - 1];
            NSTimeInterval delta = keyInput.timestamp - previousKeyInput.timestamp;
            
            if (self.delay > delta) {
                if (previousKeyInput.type == NCLKeyboardKeyTypeLeftShift) {
                    shiftState = NCLKeyboardShiftStateLeftShifted;
                    [_keyInputQueue removeObject:previousKeyInput];
                } else if (previousKeyInput.type == NCLKeyboardKeyTypeRightShift) {
                    shiftState = NCLKeyboardShiftStateRightShifted;
                    [_keyInputQueue removeObject:previousKeyInput];
                }
            }
        }
        if (shiftState == NCLKeyboardShiftStateNone && _keyInputQueue.count > queueIndex + 1) {
            NCLKeyboardInput *nextKeyInput = _keyInputQueue[queueIndex + 1];
            NSTimeInterval delta = nextKeyInput.timestamp - keyInput.timestamp;
            
            if (self.delay > delta) {
                if (nextKeyInput.type == NCLKeyboardKeyTypeLeftShift) {
                    shiftState = NCLKeyboardShiftStateLeftShifted;
                    [_keyInputQueue removeObject:nextKeyInput];
                } else if (nextKeyInput.type == NCLKeyboardKeyTypeRightShift) {
                    shiftState = NCLKeyboardShiftStateRightShifted;
                    [_keyInputQueue removeObject:nextKeyInput];
                }
            }
        }
        
        NSInteger keyIndex = keyInput.index;
        NSArray *keyboardLayout = self.keyboardLayouts[self.inputMode];
        NSString *text = keyboardLayout[shiftState][keyIndex];
        
        if (self.shifted) {
            text = [text capitalizedString];
        }
        
        [self.delegate keyboardInputEngine:self processedText:text keyIndex:keyIndex];
        
        [_keyInputQueue removeObject:keyInput];
    } else {
        NCLKeyboardShiftState shiftState = NCLKeyboardShiftStateNone;
        
        if (_keyInputQueue.count > queueIndex - 1) {
            NCLKeyboardInput *previousKeyInput = _keyInputQueue[queueIndex - 1];
            NSTimeInterval delta = keyInput.timestamp - previousKeyInput.timestamp;
            
            if (self.delay > delta) {
                if (previousKeyInput.type == NCLKeyboardKeyTypeLeftShift) {
                    shiftState = NCLKeyboardShiftStateLeftShifted;
                    [_keyInputQueue removeObject:previousKeyInput];
                } else if (previousKeyInput.type == NCLKeyboardKeyTypeRightShift) {
                    shiftState = NCLKeyboardShiftStateRightShifted;
                    [_keyInputQueue removeObject:previousKeyInput];
                }
            }
        }
        if (shiftState == NCLKeyboardShiftStateNone && _keyInputQueue.count > queueIndex + 1) {
            NCLKeyboardInput *nextKeyInput = _keyInputQueue[queueIndex + 1];
            NSTimeInterval delta = nextKeyInput.timestamp - keyInput.timestamp;
            
            if (self.delay > delta) {
                if (nextKeyInput.type == NCLKeyboardKeyTypeLeftShift) {
                    shiftState = NCLKeyboardShiftStateLeftShifted;
                    [_keyInputQueue removeObject:nextKeyInput];
                } else if (nextKeyInput.type == NCLKeyboardKeyTypeRightShift) {
                    shiftState = NCLKeyboardShiftStateRightShifted;
                    [_keyInputQueue removeObject:nextKeyInput];
                }
            }
        }
        
        if (shiftState == NCLKeyboardShiftStateNone) {
            if (keyInput.type == NCLKeyboardKeyTypeLeftShift) {
                [self.delegate keyboardInputEngineDidInputLeftShiftKey:self];
            } else if (keyInput.type == NCLKeyboardKeyTypeRightShift) {
                [self.delegate keyboardInputEngineDidInputRightShiftKey:self];
            }
        }
    }
}

@end

@implementation NCLKeyboardContinuityShiftInputEngine

@end

@implementation NCLKeyboardPrefixShiftInputEngine

- (void)addInput:(NSInteger)input
{
    NCLKeyboardInput *keyInput = [[NCLKeyboardInput alloc] init];
    keyInput.index = input;
    [self proccessInput:keyInput];
    
    _shiftState = NCLKeyboardShiftStateNone;
}

#pragma mark -

- (void)addLeftShiftKeyEvent:(NCLKeyboardEvent)event
{
    if (event == NCLKeyboardEventKeyUp) {
        if (_shiftState == NCLKeyboardShiftStateLeftShifted) {
            _shiftState = NCLKeyboardShiftStateNone;
            [self.delegate keyboardInputEngineDidInputLeftShiftKey:self];
        } else {
            _shiftState = NCLKeyboardShiftStateLeftShifted;
        }
    }
}

- (void)addRightShiftKeyEvent:(NCLKeyboardEvent)event
{
    if (event == NCLKeyboardEventKeyUp) {
        if (_shiftState == NCLKeyboardShiftStateRightShifted) {
            _shiftState = NCLKeyboardShiftStateNone;
            [self.delegate keyboardInputEngineDidInputRightShiftKey:self];
        } else {
            _shiftState = NCLKeyboardShiftStateRightShifted;
        }
    }
}

#pragma mark -

- (void)proccessInput:(NCLKeyboardInput *)keyInput
{
    NSInteger keyIndex = keyInput.index;
    NSArray *keyboardLayout = self.keyboardLayouts[self.inputMode];
    NSString *text = keyboardLayout[_shiftState][keyIndex];
    
    if (self.shifted) {
        text = [text capitalizedString];
    }
    
    [self.delegate keyboardInputEngine:self processedText:text keyIndex:keyIndex];
}

@end
