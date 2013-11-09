//
//  NCLKeyboardManager.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/11/09.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLPhysicalKeyboardManager.h"
#import "NCLKeyboardInputEngine.h"
#import "NCLKeyboardView.h"
#import "NCLConstants.h"

@interface NCLPhysicalKeyboardManager ()

@property (nonatomic) NCLKeyboardInputEngine *inputEngine;
@property (nonatomic, getter = isShifted) BOOL shifted;

@property (nonatomic) NSArray *physicalKeyLayout;
@property (nonatomic) NSDictionary *specialKeyLayout;

@end

@implementation NCLPhysicalKeyboardManager

+ (instancetype)sharedManager
{
    static NCLPhysicalKeyboardManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[NCLPhysicalKeyboardManager alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSData *data = [NSData dataWithContentsOfURL:[mainBundle URLForResource:@"PhysicalKeyboardLayouts" withExtension:@"json"]];
        NSDictionary *layouts = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        self.physicalKeyLayout = layouts[@"Physical"][@"Apple Wireless Keyboard JIS"];
        self.specialKeyLayout = layouts[@"Virtual"][@"Special"];
    }
    
    return self;
}

#pragma mark -

- (void)setKeyboardView:(NCLKeyboardView *)keyboardView
{
    _keyboardView = keyboardView;
    
    [self setupInputEngine];
    self.keyboardInputMethod = NCLKeyboardInputMethodKana;
    
    id internalKeyboard = keyboardView.textView.inputDelegate;
    [internalKeyboard addObserver:self forKeyPath:@"inHardwareKeyboardMode" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
}

- (void)setKeyboardInputMethod:(NSString *)inputMethod
{
    _keyboardInputMethod = inputMethod;
    self.keyboardView.keyboardInputMethod = inputMethod;
}

- (void)setupInputEngine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyBehavior = [userDefaults stringForKey:NCLSettingsShiftKeyBehaviorKey];
    self.inputEngine = [NCLPhysicalKeyboardInputEngine inputEngineWithShiftKeyBehavior:shiftKeyBehavior];
    self.inputEngine.delegate = self.keyboardView;
    
    float timeShiftDuration = [userDefaults doubleForKey:NCLSettingsTimeShiftDurationKey];
    self.inputEngine.delay = timeShiftDuration;
}

#pragma mark -

- (BOOL)isPhysicalKeyboardAttached
{
    id internalKeyboard = self.keyboardView.textView.inputDelegate;
    return [[internalKeyboard valueForKey:@"inHardwareKeyboardMode"] boolValue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL isInHardwareKeyboardMode = self.isPhysicalKeyboardAttached;
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLPhysicalKeyboardAvailabilityChangedNotification
                                                        object:self
                                                      userInfo:@{NCLPhysicalKeyboardAvailabilityKey: @(isInHardwareKeyboardMode)}];
}

#pragma mark -

- (BOOL)downKeyCode:(NSInteger)keyCode
{
    BOOL result = NO;
    
    NSString *keyCodeString = @(keyCode).stringValue;
    NSString *specialKey = self.specialKeyLayout[keyCodeString];
    
    if ([self.keyboardInputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
        if ([specialKey isEqualToString:@"DEL"]) {
            [self downDeleteKey];
            result = YES;
        } else if ([specialKey isEqualToString:@"SHIFT"]) {
            [self downShiftKey];
            result = YES;
        } else if ([specialKey isEqualToString:@"LSHIFT"]) {
            [self downLeftShiftKey];
            result = YES;
        } else if ([specialKey isEqualToString:@"RSHIFT"]) {
            [self downRightShiftKey];
            result = YES;
        } else if ([self.physicalKeyLayout indexOfObject:keyCodeString] != NSNotFound) {
            [self downKey:keyCode];
            result = YES;
        }
    }
    
    return result;
}

- (BOOL)upKeyCode:(NSInteger)keyCode
{
    BOOL result = NO;
    
    NSString *keyCodeString = @(keyCode).stringValue;
    NSString *specialKey = self.specialKeyLayout[keyCodeString];
    
    if ([self.keyboardInputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
        if ([specialKey isEqualToString:@"DEL"]) {
            [self upDeleteKey];
            result = YES;
        } else if ([specialKey isEqualToString:@"SHIFT"]) {
            [self upShiftKey];
            result = YES;
        } else if ([specialKey isEqualToString:@"LSHIFT"]) {
            [self upLeftShiftKey];
            result = YES;
        } else if ([specialKey isEqualToString:@"RSHIFT"]) {
            [self upRightShiftKey];
            result = YES;
        }
    }
    
    if ([specialKey isEqualToString:@"KANA/EISU"]) {
        [self toggleInputMethod];
        result = ![self.keyboardInputMethod isEqualToString:NCLKeyboardInputMethodKana];
    }
    
    return result;
}

#pragma mark -

- (void)downKey:(NSInteger)keyCode
{
    [self.inputEngine addKeyInput:keyCode];
}

#pragma mark -

- (void)downShiftKey
{
    self.shifted = YES;
}

- (void)upShiftKey
{
    self.shifted = NO;
}

- (void)setShifted:(BOOL)shifted
{
    _shifted = shifted;
    self.inputEngine.shifted = shifted;
}

#pragma mark -

- (void)downDeleteKey
{
    [self.keyboardView processDeleteKeyDown];
}

- (void)upDeleteKey
{
    [self.keyboardView processDeleteKeyUp];
}

#pragma mark -

- (void)toggleInputMethod
{
    if ([self.keyboardInputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
        self.keyboardInputMethod = NCLKeyboardInputMethodAlphabet;
    } else {
        self.keyboardInputMethod = NCLKeyboardInputMethodKana;
    }
}

#pragma mark -

- (void)downLeftShiftKey
{
    [self.inputEngine addLeftShiftKeyEvent:NCLKeyboardEventKeyPressed];
}

- (void)upLeftShiftKey
{
    [self.inputEngine addLeftShiftKeyEvent:NCLKeyboardEventKeyUp];
}

- (void)downRightShiftKey
{
    [self.inputEngine addRightShiftKeyEvent:NCLKeyboardEventKeyPressed];
}

- (void)upRightShiftKey
{
    [self.inputEngine addRightShiftKeyEvent:NCLKeyboardEventKeyUp];
}

@end
