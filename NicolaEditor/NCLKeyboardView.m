//
//  NCLKeyboardView.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/05.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLKeyboardView.h"
#import "NCLKeyboardButton.h"
#import "NCLKeyboardInputDisplayView.h"
#import "NCLKeyboardInputEngine.h"
#import "NCLSettingsViewController.h"

NSString * const NCLKeyboardShiftKeyBehaviorTimeShift = @"Time-Shift";
NSString * const NCLKeyboardShiftKeyBehaviorContinuityShift = @"Continuity-Shift";
NSString * const NCLKeyboardShiftKeyBehaviorPrefixShift = @"Prefix-Shift";

NSString * const NCLKeyboardShiftKeyFunctionNextCandidate = @"Next-Candidate";
NSString * const NCLKeyboardShiftKeyFunctionAcceptCandidate = @"Accept-Candidate";
NSString * const NCLKeyboardShiftKeyFunctionNone = @"None";

NSInteger const NCLKeyboardViewSpecialKeyDelete = 11;
NSInteger const NCLKeyboardViewSpecialKeyShift1 = 22;
NSInteger const NCLKeyboardViewSpecialKeyShift2 = 33;

@interface NCLKeyboardView () <UIInputViewAudioFeedback>

@property (nonatomic, weak) IBOutlet UIView *keyboardBackgroundView;
@property (nonatomic) NSMutableArray *keyButtons;

@property (nonatomic, weak) IBOutlet UIButton *returnKeyButton;
@property (nonatomic, weak) IBOutlet UIButton *numberKeyButton;
@property (nonatomic, weak) IBOutlet UIButton *alphabetKeyButton;
@property (nonatomic, weak) IBOutlet UIButton *leftShiftKeyButton;
@property (nonatomic, weak) IBOutlet UIButton *rightShiftKeyButton;
@property (nonatomic, weak) IBOutlet UIButton *spaceKeyButton;
@property (nonatomic, weak) IBOutlet UIButton *keyboardKeyButton;

@property (nonatomic) NCLKeyboardInputDisplayView *ipnutDisplayView;

@property (nonatomic) id internalKeyboard;

@property (nonatomic) NCLKeyboardInputEngine *inputEngine;

@end

@implementation NCLKeyboardView

- (void)awakeFromNib
{
    [self commonInit];
    [super awakeFromNib];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.keyboardBackgroundView.backgroundColor = [UIColor colorWithRed:0.812 green:0.824 blue:0.839 alpha:1.000];
    }
    
    [self setupInputEngine];
    [self setupKeyboardView];
    
    self.inputMode = NCLKeyboardInputModeKana;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shiftKeyBehaviorSettingsChanged:) name:NCLShiftKeyBehaviorSettingsChanged object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutKeyButtons];
    
    if (!self.internalKeyboard) {
        Class clazz = NSClassFromString(@"UIKeyboardImpl");
        self.internalKeyboard = [clazz performSelector:@selector(sharedInstance)];
//        [self.internalKeyboard performSelector:@selector(setInputMode:) withObject:@"ja_JP-Romaji@sw=QWERTY-Japanese;hw=US"];
        [self.internalKeyboard performSelector:@selector(setInputMode:) withObject:@"ja_JP-Kana@sw=Kana-Flick;hw=US"];
        [self.internalKeyboard performSelector:@selector(setShowsCandidateInline:) withObject:@YES];
    }
}

#pragma mark -

- (void)setInputMode:(NSString *)inputMode
{
    _inputMode = inputMode;
    self.inputEngine.inputMode = inputMode;
    
    if ([inputMode isEqualToString:NCLKeyboardInputModeAlphabet]) {
        [self.internalKeyboard performSelector:@selector(setInputMode:) withObject:@"en_US@hw=US;sw=QWERTY"];
    } else if ([inputMode isEqualToString:NCLKeyboardInputModeNumber]) {
        [self.internalKeyboard performSelector:@selector(setInputMode:) withObject:@"en_US@hw=US;sw=QWERTY"];
    } else if ([inputMode isEqualToString:NCLKeyboardInputModeKana]) {
        [self.internalKeyboard performSelector:@selector(setInputMode:) withObject:@"ja_JP-Kana@sw=Kana-Flick;hw=US"];
    }
    
    BOOL kana = [inputMode isEqualToString:NCLKeyboardInputModeKana];
    for (NCLKeyboardButton *button in self.keyButtons) {
        button.selected = !kana;
    }
    
    self.alphabetKeyButton.selected = !kana;
}

#pragma mark -

- (void)setupInputEngine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyBehavior = [userDefaults stringForKey:@"shift-key-behavior"];
    self.inputEngine = [NCLKeyboardInputEngine inputEngineWithShiftKeyBehavior:shiftKeyBehavior];
    self.inputEngine.delegate = self;
    self.inputEngine.inputMode = NCLKeyboardInputModeKana;
    
    float timeShiftDuration = [userDefaults doubleForKey:@"time-shift-duration"];
    self.inputEngine.delay = timeShiftDuration;
}

- (void)setupKeyboardView
{
    self.keyButtons = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < 35; i++) {
        NCLKeyboardButton *keyButton = [[NCLKeyboardButton alloc] initWithIndex:i];
        
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_kana_%02d", i]] forState:UIControlStateNormal];
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_kana_%02d_highlighted", i]] forState:UIControlStateHighlighted];
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_alphabet_%02d", i]] forState:UIControlStateSelected];
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_alphabet_%02d_highlighted", i]] forState:UIControlStateSelected | UIControlStateHighlighted];
        
        if (i == NCLKeyboardViewSpecialKeyDelete) {
            [keyButton addTarget:self action:@selector(touchDownDeleteKey:) forControlEvents:UIControlEventTouchDown];
            [keyButton addTarget:self action:@selector(touchUpDeleteKey:) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == NCLKeyboardViewSpecialKeyShift1 || i == NCLKeyboardViewSpecialKeyShift2) {
            [keyButton addTarget:self action:@selector(touchDownShiftKey:) forControlEvents:UIControlEventTouchDown];
            [keyButton addTarget:self action:@selector(touchUpShiftKey:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [keyButton addTarget:self action:@selector(touchDownKey:) forControlEvents:UIControlEventTouchDown];
            [keyButton addTarget:self action:@selector(touchUpKey:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.keyboardBackgroundView addSubview:keyButton];
        [self.keyButtons addObject:keyButton];
    }
    
    [self.alphabetKeyButton setImage:[UIImage imageNamed:@"key_kana_highlighted"] forState:UIControlStateSelected | UIControlStateHighlighted];
}

- (void)layoutKeyButtons
{
    UIApplication *app = [UIApplication sharedApplication];
    UIInterfaceOrientation orientation = app.statusBarOrientation;
    
    CGFloat leftMargin;
    CGFloat leftPadding;
    CGFloat topMargin;
    CGFloat horizontalSpacing;
    CGFloat verticalSpacing;
    CGFloat keyWidth;
    CGFloat keyHeight;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        leftMargin = 6.0f;
        leftPadding = 32.0f;
        topMargin = 8.0f;
        horizontalSpacing = 6.5f;
        verticalSpacing = 8.0f;
        keyWidth = 57.0f;
        keyHeight = 56.0f;
    } else {
        leftMargin = 7.0f;
        leftPadding = 38.0f;
        topMargin = 9.0f;
        horizontalSpacing = 9.0f;
        verticalSpacing = 11.0f;
        keyWidth = 76.0f;
        keyHeight = 75.0f;
    }

    NSInteger counter = 0;
    for (NSInteger row = 0; row < 3; row++) {
        NSInteger columns = 0;
        
        if (row % 2 == 0) {
            columns = 12;
        } else {
            columns = 10;
        }
        
        for (NSInteger column = 0; column < columns; column++) {
            NCLKeyboardButton *key = self.keyButtons[counter];
            if (row % 2 == 0) {
                key.frame = CGRectMake(leftMargin + (keyWidth + horizontalSpacing) * column,
                                       topMargin + (keyHeight + verticalSpacing) * row,
                                       keyWidth,
                                       keyHeight);
            } else {
                key.frame = CGRectMake(leftPadding +leftMargin + (keyWidth + horizontalSpacing) * column,
                                       topMargin + (keyHeight + verticalSpacing) * row,
                                       keyWidth,
                                       keyHeight);
            }
            
            counter++;
        }
    }
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.returnKeyButton.frame = CGRectMake(674.0f, 72.0f, 88.0f, keyHeight);
        self.numberKeyButton.frame = CGRectMake(5.0f, 200.0f, keyWidth, keyHeight);
        self.alphabetKeyButton.frame = CGRectMake(68.5f, 200.0f, keyWidth, keyHeight);
        self.leftShiftKeyButton.frame = CGRectMake(132.0f, 200.0f, 217.0f, keyHeight);
        self.rightShiftKeyButton.frame = CGRectMake(356.0f, 200.0f, 216.0f, keyHeight);
        self.spaceKeyButton.frame = CGRectMake(578.5f, 200.0f, 121.0f, keyHeight);
        self.keyboardKeyButton.frame = CGRectMake(706.0f, 200.0f, keyWidth, keyHeight);
    } else {
        self.returnKeyButton.frame = CGRectMake(895.0f, 95.0f, 122.0f, keyHeight);
        self.numberKeyButton.frame = CGRectMake(7.0f, 267.0f, keyWidth, keyHeight);
        self.alphabetKeyButton.frame = CGRectMake(92.0f, 267.0f, keyWidth, keyHeight);
        self.leftShiftKeyButton.frame = CGRectMake(177.0f, 267.0f, 289.0f, keyHeight);
        self.rightShiftKeyButton.frame = CGRectMake(475.0f, 267.0f, 288.0f, keyHeight);
        self.spaceKeyButton.frame = CGRectMake(772.0f, 267.0f, 161.0f, keyHeight);
        self.keyboardKeyButton.frame = CGRectMake(942.0f, 267.0f, keyWidth, keyHeight);
    }
}

- (void)shiftKeyBehaviorSettingsChanged:(NSNotification *)notification
{
    [self setupInputEngine];
}

#pragma mark -

- (void)touchDownKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    
    NCLKeyboardButton *keyButton = sender;
    NSInteger keyIndex = keyButton.index;
    [self.inputEngine addInput:keyIndex];
}

- (void)touchUpKey:(id)sender
{
    
}

- (IBAction)touchDownDeleteKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    [self.internalKeyboard performSelector:@selector(deleteFromInput) withObject:nil];
}

- (IBAction)touchUpDeleteKey:(id)sender
{
    
}

- (IBAction)touchDownReturnKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
}

- (IBAction)touchUpReturnKey:(id)sender
{
    BOOL hasCandidates = [[self.internalKeyboard valueForKey:@"_hasCandidates"] boolValue];
    if (hasCandidates) {
        [self.internalKeyboard performSelector:@selector(acceptCurrentCandidate) withObject:nil];
        return;
    }
    
    [self.internalKeyboard performSelector:@selector(addInputString:) withObject:@"\n"];
}

- (IBAction)touchDownShiftKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    [self.inputEngine setShifted:YES];
}

- (IBAction)touchUpShiftKey:(id)sender
{
    [self.inputEngine setShifted:NO];
}

- (IBAction)touchDownNumberKey:(id)sender
{
//    [[UIDevice currentDevice] playInputClick];
//    self.inputMode = NCLKeyboardInputModeNumber;
}

- (IBAction)touchDownAlphabetKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    
    if ([self.inputMode isEqualToString:NCLKeyboardInputModeKana]) {
        self.inputMode = NCLKeyboardInputModeAlphabet;
    } else {
        self.inputMode = NCLKeyboardInputModeKana;
    }
}

#pragma mark -

- (IBAction)touchDownLeftShiftKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    [self.inputEngine addLeftShiftKeyEvent:NCLKeyboardEventKeyPressed];
}

- (IBAction)touchUpLeftShiftKey:(id)sender
{
    [self.inputEngine addLeftShiftKeyEvent:NCLKeyboardEventKeyUp];
}

- (IBAction)touchDownRightShiftKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    [self.inputEngine addRightShiftKeyEvent:NCLKeyboardEventKeyPressed];
}

- (IBAction)touchUpRightShiftKey:(id)sender
{
    [self.inputEngine addRightShiftKeyEvent:NCLKeyboardEventKeyUp];
}

- (IBAction)touchDownSpaceKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
}

- (IBAction)touchUpSpaceKey:(id)sender
{
    [self.internalKeyboard performSelector:@selector(addInputString:) withObject:@" "];
}

- (IBAction)touchUpKeyboardKey:(id)sender
{
    [self.textView endEditing:NO];
}

#pragma mark -

- (void)keyboardInputEngine:(NCLKeyboardInputEngine *)engine processedText:(NSString *)text keyIndex:(NSInteger)keyIndex
{
    if (text.length > 0) {
        [self.internalKeyboard performSelector:@selector(addInputString:) withObject:text];
    }
}

- (void)keyboardInputEngineDidInputLeftShiftKey:(NCLKeyboardInputEngine *)engine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyFunction = [userDefaults stringForKey:@"shift-key-function-left"];
    if ([shiftKeyFunction isEqualToString:NCLKeyboardShiftKeyFunctionNextCandidate]) {
        [self.internalKeyboard performSelector:@selector(showNextCandidates) withObject:nil];
    } else if ([shiftKeyFunction isEqualToString:NCLKeyboardShiftKeyFunctionAcceptCandidate]) {
        BOOL hasCandidates = [[self.internalKeyboard valueForKey:@"_hasCandidates"] boolValue];
        if (hasCandidates) {
            [self.internalKeyboard performSelector:@selector(acceptCurrentCandidate) withObject:nil];
        }
    }
}

- (void)keyboardInputEngineDidInputRightShiftKey:(NCLKeyboardInputEngine *)engine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyFunction = [userDefaults stringForKey:@"shift-key-function-right"];
    if ([shiftKeyFunction isEqualToString:NCLKeyboardShiftKeyFunctionNextCandidate]) {
        [self.internalKeyboard performSelector:@selector(showNextCandidates) withObject:nil];
    } else if ([shiftKeyFunction isEqualToString:NCLKeyboardShiftKeyFunctionAcceptCandidate]) {
        BOOL hasCandidates = [[self.internalKeyboard valueForKey:@"_hasCandidates"] boolValue];
        if (hasCandidates) {
            [self.internalKeyboard performSelector:@selector(acceptCurrentCandidate) withObject:nil];
        }
    }
}

@end
