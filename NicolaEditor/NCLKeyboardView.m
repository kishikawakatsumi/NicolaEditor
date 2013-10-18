//
//  NCLKeyboardView.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/05.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLKeyboardView.h"
#import "NCLKeyboardButton.h"
#import "NCLKeyboardInputEngine.h"
#import "NCLConstants.h"

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

@property (nonatomic, weak) id internalKeyboard;
@property (nonatomic) NCLKeyboardInputEngine *inputEngine;

@property (nonatomic) NSString *previousKeyboardInputMethod;

@end

@implementation NCLKeyboardView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
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
    
    self.keyboardInputMethod = NCLKeyboardInputMethodKana;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shiftKeyBehaviorDidChange:) name:NCLSettingsShiftKeyBehaviorDidChangeNodification object:nil];
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
    [self setupKeyboardIfNeeded];
}

#pragma mark -

- (void)setKeyboardInputMethod:(NSString *)inputMethod
{
    _keyboardInputMethod = inputMethod;
    self.inputEngine.inputMethod = inputMethod;
    
    if ([inputMethod isEqualToString:NCLKeyboardInputMethodAlphabet]) {
        [self sendMessage:self.internalKeyboard
                  forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"I", @"n", @"p", @"u", @"t", @"M", @"o", @"d", @"e", @":"]
              attachments:@[@{@"Object": [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"e", @"n", @"_", @"U", @"S", @"@", @"h", @"w", @"=", @"U", @"S", @";", @"s", @"w", @"=", @"Q", @"W", @"E", @"R", @"T", @"Y"]}]];
    } else if ([inputMethod isEqualToString:NCLKeyboardInputMethodNumberPunctuation]) {
        [self sendMessage:self.internalKeyboard
                  forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"I", @"n", @"p", @"u", @"t", @"M", @"o", @"d", @"e", @":"]
              attachments:@[@{@"Object": [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"e", @"n", @"_", @"U", @"S", @"@", @"h", @"w", @"=", @"U", @"S", @";", @"s", @"w", @"=", @"Q", @"W", @"E", @"R", @"T", @"Y"]}]];
    } else if ([inputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
        [self sendMessage:self.internalKeyboard
                  forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"I", @"n", @"p", @"u", @"t", @"M", @"o", @"d", @"e", @":"]
              attachments:@[@{@"Object": [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"j", @"a", @"_", @"J", @"P", @"-", @"K", @"a", @"n", @"a", @"@", @"s", @"w", @"=", @"K", @"a", @"n", @"a", @"-", @"F", @"l", @"i", @"c", @"k", @";", @"h", @"w", @"=", @"U", @"S"]}]];
    }
    
    NSString *keyboardType;
    if ([inputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
        keyboardType = @"kana";
        [self.alphabetKeyButton setImage:[UIImage imageNamed:@"key_alphabet"] forState:UIControlStateNormal];
        [self.alphabetKeyButton setImage:[UIImage imageNamed:@"key_alphabet_highlighted"] forState:UIControlStateHighlighted];
    } else if ([inputMethod isEqualToString:NCLKeyboardInputMethodAlphabet]) {
        keyboardType = @"alphabet";
        [self.alphabetKeyButton setImage:[UIImage imageNamed:@"key_kana"] forState:UIControlStateNormal];
        [self.alphabetKeyButton setImage:[UIImage imageNamed:@"key_kana_highlighted"] forState:UIControlStateHighlighted];
    } else if ([inputMethod isEqualToString:NCLKeyboardInputMethodNumberPunctuation]) {
        keyboardType = @"number";
    }
    NSInteger i = 0;
    for (NCLKeyboardButton *keyButton in self.keyButtons) {
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_%@_%02d", keyboardType, i]] forState:UIControlStateNormal];
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_%@_%02d_highlighted", keyboardType, i]] forState:UIControlStateHighlighted];
        i++;
    }
}

#pragma mark -

- (void)setupInputEngine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyBehavior = [userDefaults stringForKey:@"shift-key-behavior"];
    self.inputEngine = [NCLKeyboardInputEngine inputEngineWithShiftKeyBehavior:shiftKeyBehavior];
    self.inputEngine.delegate = self;
    self.inputEngine.inputMethod = NCLKeyboardInputMethodKana;
    
    float timeShiftDuration = [userDefaults doubleForKey:@"time-shift-duration"];
    self.inputEngine.delay = timeShiftDuration;
}

- (void)setupKeyboardView
{
    self.keyButtons = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < 35; i++) {
        NCLKeyboardButton *keyButton = [[NCLKeyboardButton alloc] initWithIndex:i];
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

- (void)setupKeyboardIfNeeded
{
    if (!self.internalKeyboard) {
        self.internalKeyboard = self.textView.inputDelegate;
        [self sendMessage:self.internalKeyboard
                  forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"I", @"n", @"p", @"u", @"t", @"M", @"o", @"d", @"e", @":"]
              attachments:@[@{@"Object": [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"j", @"a", @"_", @"J", @"P", @"-", @"K", @"a", @"n", @"a", @"@", @"s", @"w", @"=", @"K", @"a", @"n", @"a", @"-", @"F", @"l", @"i", @"c", @"k", @";", @"h", @"w", @"=", @"U", @"S"]}]];
        [self sendMessage:self.internalKeyboard
                  forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"S", @"h", @"o", @"w", @"s", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"I", @"n", @"l", @"i", @"n", @"e", @":"]
              attachments:@[@{@"BOOL": @YES}]];
    }
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

- (void)shiftKeyBehaviorDidChange:(NSNotification *)notification
{
    [self setupInputEngine];
}

#pragma mark -

- (void)touchDownKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    
    NCLKeyboardButton *keyButton = sender;
    NSInteger keyIndex = keyButton.index;
    [self.inputEngine addKeyInput:keyIndex];
}

- (void)touchUpKey:(id)sender
{
    
}

- (IBAction)touchDownDeleteKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    [self sendMessage:self.internalKeyboard
              forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"d", @"e", @"l", @"e", @"t", @"e", @"F", @"r", @"o", @"m", @"I", @"n", @"p", @"u", @"t"]
          attachments:nil];
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
        [self sendMessage:self.internalKeyboard
                  forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"c", @"c", @"e", @"p", @"t", @"C", @"u", @"r", @"r", @"e", @"n", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"]
              attachments:nil];
        return;
    }
    
    [self sendMessage:self.internalKeyboard
              forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"d", @"d", @"I", @"n", @"p", @"u", @"t", @"S", @"t", @"r", @"i", @"n", @"g", @":"]
          attachments:@[@{@"Object": @"\n"}]];
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
    [[UIDevice currentDevice] playInputClick];
    if (![self.keyboardInputMethod isEqualToString:NCLKeyboardInputMethodNumberPunctuation]) {
        self.previousKeyboardInputMethod = self.keyboardInputMethod;
    }
    self.keyboardInputMethod = NCLKeyboardInputMethodNumberPunctuation;
}

- (IBAction)touchDownAlphabetKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    
    if ([self.keyboardInputMethod isEqualToString:NCLKeyboardInputMethodNumberPunctuation]) {
        if ([self.previousKeyboardInputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
            self.keyboardInputMethod = NCLKeyboardInputMethodAlphabet;
        } else {
            self.keyboardInputMethod = NCLKeyboardInputMethodKana;
        }
    } else {
        if ([self.keyboardInputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
            self.keyboardInputMethod = NCLKeyboardInputMethodAlphabet;
        } else {
            self.keyboardInputMethod = NCLKeyboardInputMethodKana;
        }
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
    [self sendMessage:self.internalKeyboard
              forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"d", @"d", @"I", @"n", @"p", @"u", @"t", @"S", @"t", @"r", @"i", @"n", @"g", @":"]
          attachments:@[@{@"Object": @" "}]];
}

- (IBAction)touchUpKeyboardKey:(id)sender
{
    [self.textView endEditing:NO];
}

#pragma mark -

- (void)keyboardInputEngine:(NCLKeyboardInputEngine *)engine processedText:(NSString *)text keyIndex:(NSInteger)keyIndex
{
    if (text.length > 0) {
        [self sendMessage:self.internalKeyboard
                  forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"d", @"d", @"I", @"n", @"p", @"u", @"t", @"S", @"t", @"r", @"i", @"n", @"g", @":"]
              attachments:@[@{@"Object": text}]];
    }
}

- (void)keyboardInputEngineDidInputLeftShiftKey:(NCLKeyboardInputEngine *)engine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyFunction = [userDefaults stringForKey:@"shift-key-function-left"];
    if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionNextCandidate]) {
        [self sendMessage:self.internalKeyboard
                  forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"h", @"o", @"w", @"N", @"e", @"x", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"s"]
              attachments:nil];
    } else if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionAcceptCandidate]) {
        BOOL hasCandidates = [[self.internalKeyboard valueForKey:@"_hasCandidates"] boolValue];
        if (hasCandidates) {
            [self sendMessage:self.internalKeyboard
                      forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"c", @"c", @"e", @"p", @"t", @"C", @"u", @"r", @"r", @"e", @"n", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"]
                  attachments:nil];
        }
    }
}

- (void)keyboardInputEngineDidInputRightShiftKey:(NCLKeyboardInputEngine *)engine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyFunction = [userDefaults stringForKey:@"shift-key-function-right"];
    if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionNextCandidate]) {
        [self sendMessage:self.internalKeyboard
                  forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"h", @"o", @"w", @"N", @"e", @"x", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"s"]
              attachments:nil];
    } else if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionAcceptCandidate]) {
        BOOL hasCandidates = [[self.internalKeyboard valueForKey:@"_hasCandidates"] boolValue];
        if (hasCandidates) {
            [self sendMessage:self.internalKeyboard
                      forName:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"c", @"c", @"e", @"p", @"t", @"C", @"u", @"r", @"r", @"e", @"n", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"]
                  attachments:nil];
        }
    }
}

#pragma mark -

- (id)sendMessage:(id)target forName:(NSString *)name attachments:(NSArray *)attachments
{
    if (!target) {
        return nil;
    }
    SEL selector = NSSelectorFromString(name);
    NSMethodSignature *methodSignature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.target = target;
    invocation.selector = selector;
    NSInteger index = 2;
    for (NSDictionary *attachment in attachments) {
        for (NSString *type in attachment.allKeys) {
            if ([type isEqualToString:@"Object"]) {
                id argument = attachment[type];
                [invocation setArgument:&argument atIndex:index];
            } else if ([type isEqualToString:@"BOOL"]) {
                BOOL argument = [attachment[type] boolValue];
                [invocation setArgument:&argument atIndex:index];
            }
        }
        
        index++;
    }
    [invocation invoke];
    
    const char *methodReturnType = methodSignature.methodReturnType;
    if (0 == strcmp(methodReturnType, @encode(id))) {
        id returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    
    return nil;
}

@end
