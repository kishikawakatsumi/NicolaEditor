//
//  NCLKeyboardInputEngine.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/09.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLKeyboardInputEngine.h"
#import "NCLConstants.h"

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

NSString * const NCLKeyboardInputMethodKana = @"Kana";
NSString * const NCLKeyboardInputMethodAlphabet = @"Alphabet";
NSString * const NCLKeyboardInputMethodNumberPunctuation = @"NumberPunctuation";

@interface NCLKeyboardInput : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic) NCLKeyboardKeyType type;
@property (nonatomic) NSTimeInterval timestamp;

@property (nonatomic, getter = isUsed) BOOL used;

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

@property (nonatomic) NSMutableArray *keyInputQueue;
@property (nonatomic) NCLKeyboardInput *lastLeftShiftKeyInput;
@property (nonatomic) NCLKeyboardInput *lastRightShiftKeyInput;

@end

@interface NCLKeyboardPrefixShiftInputEngine : NCLKeyboardInputEngine

@property (nonatomic) NCLKeyboardShiftState shiftState;

@end

@implementation NCLKeyboardInputEngine

+ (id)inputEngineWithShiftKeyBehavior:(NSString *)shiftKeyBehavior
{
    if ([shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorTimeShift]) {
        return [[NCLKeyboardTimeShiftInputEngine alloc] init];
    } else if ([shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorContinuityShift]) {
        return [[NCLKeyboardContinuityShiftInputEngine alloc] init];
    } else if ([shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorPrefixShift]) {
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

- (void)addKeyInput:(NSInteger)input
{
    
}

- (void)addLeftShiftKeyEvent:(NCLKeyboardEvent)event
{
    
}

- (void)addRightShiftKeyEvent:(NCLKeyboardEvent)event
{
    
}

- (NSString *)shiftedTextWithText:(NSString *)text
{
    text = [text capitalizedString];
    if ([text isEqualToString:@"\u306F"]) {
        text = @"\u3071";
    } else if ([text isEqualToString:@"\u3072"]) {
        text = @"\u3074";
    } else if ([text isEqualToString:@"\u3075"]) {
        text = @"\u3077";
    } else if ([text isEqualToString:@"\u3078"]) {
        text = @"\u307A";
    } else if ([text isEqualToString:@"\u307B"]) {
        text = @"\u307D";
    }
    
    return text;
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

- (void)addKeyInput:(NSInteger)input
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
                shiftState = (NCLKeyboardShiftState)previousKeyInput.type;
                [_keyInputQueue removeObject:previousKeyInput];
            }
        }
        
        if (shiftState == NCLKeyboardShiftStateNone && _keyInputQueue.count > queueIndex + 1) {
            NCLKeyboardInput *nextKeyInput = _keyInputQueue[queueIndex + 1];
            NSTimeInterval delta = nextKeyInput.timestamp - keyInput.timestamp;
            
            if (self.delay > delta) {
                shiftState = (NCLKeyboardShiftState)nextKeyInput.type;
                [_keyInputQueue removeObject:nextKeyInput];
            }
        }
        
        NSInteger keyIndex = keyInput.index;
        NSArray *keyboardLayout = self.keyboardLayouts[self.inputMethod];
        NSString *text = keyboardLayout[shiftState][keyIndex];
        
        if (self.shifted) {
            text = [self shiftedTextWithText:text];
        }
        
        [self.delegate keyboardInputEngine:self processedText:text keyIndex:keyIndex];
        
        [_keyInputQueue removeObject:keyInput];
    } else {
        NCLKeyboardShiftState shiftState = NCLKeyboardShiftStateNone;
        
        if (_keyInputQueue.count > queueIndex - 1) {
            NCLKeyboardInput *previousKeyInput = _keyInputQueue[queueIndex - 1];
            NSTimeInterval delta = keyInput.timestamp - previousKeyInput.timestamp;
            
            if (self.delay > delta) {
                shiftState = (NCLKeyboardShiftState)previousKeyInput.type;
                [_keyInputQueue removeObject:previousKeyInput];
            }
        }
        
        if (shiftState == NCLKeyboardShiftStateNone && _keyInputQueue.count > queueIndex + 1) {
            NCLKeyboardInput *nextKeyInput = _keyInputQueue[queueIndex + 1];
            NSTimeInterval delta = nextKeyInput.timestamp - keyInput.timestamp;
            
            if (self.delay > delta) {
                shiftState = (NCLKeyboardShiftState)nextKeyInput.type;
                [_keyInputQueue removeObject:nextKeyInput];
            }
        }
        
        if (shiftState == NCLKeyboardShiftStateNone) {
            if (keyInput.type == NCLKeyboardKeyTypeLeftShift) {
                [self.delegate keyboardInputEngineDidInputLeftShiftKey:self];
            } else if (keyInput.type == NCLKeyboardKeyTypeRightShift) {
                [self.delegate keyboardInputEngineDidInputRightShiftKey:self];
            }
        }
        
        [_keyInputQueue removeObject:keyInput];
    }
}

@end

@implementation NCLKeyboardContinuityShiftInputEngine

- (id)init
{
    self = [super init];
    if (self) {
        self.keyInputQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addKeyInput:(NSInteger)input
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
        
        _lastLeftShiftKeyInput = keyInput;
    } else if (event == NCLKeyboardEventKeyUp) {
        NCLKeyboardInput *keyInput = _lastLeftShiftKeyInput;
        
        double delayInSeconds = self.delay * 2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self proccessInput:keyInput];
        });
        _lastLeftShiftKeyInput = nil;
    }
}

- (void)addRightShiftKeyEvent:(NCLKeyboardEvent)event
{
    if (event == NCLKeyboardEventKeyPressed) {
        NCLKeyboardInput *keyInput = [[NCLKeyboardInput alloc] init];
        keyInput.type = NCLKeyboardKeyTypeRightShift;
        keyInput.timestamp = CACurrentMediaTime();
        [_keyInputQueue addObject:keyInput];
        
        _lastRightShiftKeyInput = keyInput;
    } else if (event == NCLKeyboardEventKeyUp) {
        NCLKeyboardInput *keyInput = _lastRightShiftKeyInput;
        
        double delayInSeconds = self.delay * 2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self proccessInput:keyInput];
        });
        _lastRightShiftKeyInput = nil;
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
        
        if (_lastLeftShiftKeyInput) {
            _lastLeftShiftKeyInput.used = YES;
            shiftState = NCLKeyboardShiftStateLeftShifted;
        }
        
        if (shiftState == NCLKeyboardShiftStateNone) {
            if (_lastRightShiftKeyInput) {
                _lastRightShiftKeyInput.used = YES;
                shiftState = NCLKeyboardShiftStateRightShifted;
            }
        }
        
        if (shiftState == NCLKeyboardShiftStateNone) {
            if (_keyInputQueue.count > queueIndex - 1) {
                NCLKeyboardInput *previousKeyInput = _keyInputQueue[queueIndex - 1];
                NSTimeInterval delta = keyInput.timestamp - previousKeyInput.timestamp;
                
                if (self.delay > delta) {
                    previousKeyInput.used = YES;
                    shiftState = (NCLKeyboardShiftState)previousKeyInput.type;
                    [_keyInputQueue removeObject:previousKeyInput];
                }
            }
            if (shiftState == NCLKeyboardShiftStateNone && _keyInputQueue.count > queueIndex + 1) {
                NCLKeyboardInput *nextKeyInput = _keyInputQueue[queueIndex + 1];
                NSTimeInterval delta = nextKeyInput.timestamp - keyInput.timestamp;
                
                if (self.delay > delta) {
                    nextKeyInput.used = YES;
                    shiftState = (NCLKeyboardShiftState)nextKeyInput.type;
                    [_keyInputQueue removeObject:nextKeyInput];
                }
            }
        }
        
        NSInteger keyIndex = keyInput.index;
        NSArray *keyboardLayout = self.keyboardLayouts[self.inputMethod];
        NSString *text = keyboardLayout[shiftState][keyIndex];
        
        if (self.shifted) {
            text = [self shiftedTextWithText:text];
        }
        
        [self.delegate keyboardInputEngine:self processedText:text keyIndex:keyIndex];
        
        [_keyInputQueue removeObject:keyInput];
    } else {
        if (!keyInput.isUsed) {
            NCLKeyboardShiftState shiftState = NCLKeyboardShiftStateNone;
            
            if (shiftState == NCLKeyboardShiftStateNone) {
                if (keyInput.type == NCLKeyboardKeyTypeLeftShift) {
                    [self.delegate keyboardInputEngineDidInputLeftShiftKey:self];
                } else if (keyInput.type == NCLKeyboardKeyTypeRightShift) {
                    [self.delegate keyboardInputEngineDidInputRightShiftKey:self];
                }
            }
        }
        
        [_keyInputQueue removeObject:keyInput];
    }
}

@end

@implementation NCLKeyboardPrefixShiftInputEngine

- (void)addKeyInput:(NSInteger)input
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
    NSArray *keyboardLayout = self.keyboardLayouts[self.inputMethod];
    NSString *text = keyboardLayout[_shiftState][keyIndex];
    
    if (self.shifted) {
        text = [self shiftedTextWithText:text];
    }
    
    [self.delegate keyboardInputEngine:self processedText:text keyIndex:keyIndex];
}

@end
