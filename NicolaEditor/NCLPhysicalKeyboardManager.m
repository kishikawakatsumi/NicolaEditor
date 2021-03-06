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
#import "NCLKeyboardAccessoryView.h"
#import "NCLConstants.h"
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *xfS9MiWvpygnCQtUh483;

@interface NCLPhysicalKeyboardManager ()

@property (nonatomic) NCLKeyboardInputEngine *inputEngine;
@property (nonatomic, getter = isShifted) BOOL shifted;

@property (nonatomic) NSArray *physicalKeyLayout;
@property (nonatomic) NSDictionary *specialKeyLayout;

@property (nonatomic, getter = isDisplayKeycode) BOOL displayKeycode;
@property (nonatomic, getter = isDisplayDebugInfo) BOOL displayDebugInfo;

@end

@implementation NCLPhysicalKeyboardManager

+ (void)initialize
{
    xfS9MiWvpygnCQtUh483 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"i", @"n", @"H", @"a", @"r", @"d", @"w", @"a", @"r", @"e", @"K", @"e", @"y", @"b", @"o", @"a", @"r", @"d", @"M", @"o", @"d", @"e"];
}

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
        [self setupKeyboardLayout];
        [self applyDebugFunctionEnabled];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalKeyboardDebugSettingsChanged:) name:NCLSettingsExternalKeyboardDebugSettingsChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)setupKeyboardLayout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *keyboard = [userDefaults stringForKey:NCLSettingsExternalKeyboardKey];
    
    NSArray *layouts = [NCLKeyboardInputEngine keyboardLayoutNamed:keyboard];
    
    self.physicalKeyLayout = layouts[0];
    self.specialKeyLayout = layouts[1];
}

- (void)applyDebugFunctionEnabled
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL displayKeycode = [userDefaults boolForKey:NCLSettingsExternalKeyboardDisplayKeycode];
    BOOL displayDebugInfo = [userDefaults boolForKey:NCLSettingsExternalKeyboardDisplayDebugInfo];
    
    self.displayKeycode = displayKeycode;
    self.displayDebugInfo = displayDebugInfo;
}

#pragma mark -

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    id internalKeyboard = self.keyboardView.textView.inputDelegate;
    void *observationInfo = [internalKeyboard observationInfo];
    if (observationInfo) {
        [internalKeyboard removeObserver:self forKeyPath:xfS9MiWvpygnCQtUh483];
    }
}

#pragma mark -

- (void)setKeyboardView:(NCLKeyboardView *)keyboardView
{
    _keyboardView = keyboardView;
    
    [self setupInputEngine];
    self.keyboardInputMethod = NCLKeyboardInputMethodKana;
    
    id internalKeyboard = keyboardView.textView.inputDelegate;
    [internalKeyboard addObserver:self forKeyPath:xfS9MiWvpygnCQtUh483 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
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
    return [[internalKeyboard valueForKey:xfS9MiWvpygnCQtUh483] boolValue];
}

- (BOOL)isNicolaKeyboardType
{
    NCLKeyboardAccessoryView *inputAccessoryView = (NCLKeyboardAccessoryView *)self.keyboardView.textView.inputAccessoryView;
    if ([inputAccessoryView isKindOfClass:[NCLKeyboardAccessoryView class]]) {
        return inputAccessoryView.keyboardType == NCLKeyboardTypeNICOLA;
    }
    return NO;
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
    
    if (_displayKeycode) {
        [SVProgressHUD showImage:[UIImage imageNamed:@"keyup"] status:[NSString stringWithFormat:@"[ %@ ]", keyCodeString]];
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
    
    if (_displayKeycode) {
        [SVProgressHUD showImage:[UIImage imageNamed:@"keyup"] status:[NSString stringWithFormat:@"[ %@ ]", keyCodeString]];
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

#pragma mark -

- (void)externalKeyboardDebugSettingsChanged:(UIApplication *)application
{
    [self applyDebugFunctionEnabled];
}

@end
