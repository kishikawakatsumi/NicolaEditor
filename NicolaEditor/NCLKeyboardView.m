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
#import "NCLPhysicalKeyboardManager.h"
#import "NCLConstants.h"

@import ObjectiveC;

int const NCLKeyButtonIndexSpecialKeyDelete = 11;
int const NCLKeyButtonIndexSpecialKeyShift1 = 22;
int const NCLKeyButtonIndexSpecialKeyShift2 = 33;

// setInputMode:
static NSString *HTcj2RHKk78UgtYwx3Z8;
// addInputString
static NSString *mb6FzfJW6t9XaDQkna7m;
// deleteFromInput
static NSString *PArjMGcJEYULesZzYbwp;
// startAutoDeleteTimer
static NSString *G2AmM5eQZ4RxKLM3TCKZ;
// stopAutoDelete
static NSString *jLdpi9URsHKDRWf36aE6;
// movePhraseBoundaryToDirection:
static NSString *c4TdPa3m8nDVPeha877N;
// _hasCandidates
static NSString *TBH2nEKQNPBmyDkQdzCx;
// showPreviousCandidate
static NSString *L98fTVmwP43UFtL579EB;
// showNextCandidates
static NSString *GUU2JdGW8jGWuc388rJR;
// setShowsCandidateInline:
static NSString *SxYmcXP2AFEYh4CXYBMJ;
// userSelectedCurrentCandidate
static NSString *CsLigQ6mK4n6e6ChunPz;
// acceptCurrentCandidate
static NSString *wsjiFCKRrgQ3ipQpec6L;
// en_US@hw=US;sw=QWERTY
static NSString *en_US;
// ja_JP-Kana@sw=Kana-Flick;hw=US
static NSString *ja_JP;
// defaultCandidate
static NSString *ejUGacPiwpO2dAdcF02M;
// acceptCandidate:
static NSString *Eqo0llHPe80vNAN1bvDB;
// acceptCurrentCandidateIfSelected
static NSString *uNTmdpaswc3OpK7Q3JxE;
// _collectionViewController
static NSString *JrWofcSm4A8qSWOcgTEg;
// m_candidateList
static NSString *khK6OMhSKZlcaj4VrGn3;
// m_candidateResultSet
static NSString *zfojM79sdi9CCtYPwy3H;

static NSCache *cache;

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

@property (nonatomic) NSString *lastUsedKeyboardInputMethod;

@property (nonatomic, getter = isShifted) BOOL shifted;
@property (nonatomic, getter = isShiftLocked) BOOL shiftLocked;

@property (nonatomic) BOOL swapBackspaceReturnEnabled;

@end

@implementation NCLKeyboardView

+ (void)initialize
{
    // setInputMode:
    HTcj2RHKk78UgtYwx3Z8 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"I", @"n", @"p", @"u", @"t", @"M", @"o", @"d", @"e", @":"];
    // addInputString
    mb6FzfJW6t9XaDQkna7m = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"d", @"d", @"I", @"n", @"p", @"u", @"t", @"S", @"t", @"r", @"i", @"n", @"g", @":"];
    // deleteFromInput
    PArjMGcJEYULesZzYbwp = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"d", @"e", @"l", @"e", @"t", @"e", @"F", @"r", @"o", @"m", @"I", @"n", @"p", @"u", @"t"];
    // startAutoDeleteTimer
    G2AmM5eQZ4RxKLM3TCKZ = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"t", @"a", @"r", @"t", @"A", @"u", @"t", @"o", @"D", @"e", @"l", @"e", @"t", @"e", @"T", @"i", @"m", @"e", @"r"];
    // stopAutoDelete
    jLdpi9URsHKDRWf36aE6 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"t", @"o", @"p", @"A", @"u", @"t", @"o", @"D", @"e", @"l", @"e", @"t", @"e"];
    // movePhraseBoundaryToDirection:
    c4TdPa3m8nDVPeha877N = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"m", @"o", @"v", @"e", @"P", @"h", @"r", @"a", @"s", @"e", @"B", @"o", @"u", @"n", @"d", @"a", @"r", @"y", @"T", @"o", @"D", @"i", @"r", @"e", @"c", @"t", @"i", @"o", @"n", @":"];
    // _hasCandidates
    TBH2nEKQNPBmyDkQdzCx = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"_", @"h", @"a", @"s", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"s"];
    // showPreviousCandidate
    L98fTVmwP43UFtL579EB = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"h", @"o", @"w", @"P", @"r", @"e", @"v", @"i", @"o", @"u", @"s", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"];
    // showNextCandidates
    GUU2JdGW8jGWuc388rJR = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"h", @"o", @"w", @"N", @"e", @"x", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"s"];
    // setShowsCandidateInline:
    SxYmcXP2AFEYh4CXYBMJ = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"S", @"h", @"o", @"w", @"s", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"I", @"n", @"l", @"i", @"n", @"e", @":"];
    // acceptCurrentCandidate
    wsjiFCKRrgQ3ipQpec6L = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"c", @"c", @"e", @"p", @"t", @"C", @"u", @"r", @"r", @"e", @"n", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"];
    // userSelectedCurrentCandidate
    CsLigQ6mK4n6e6ChunPz = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"u", @"s", @"e", @"r", @"S", @"e", @"l", @"e", @"c", @"t", @"e", @"d", @"C", @"u", @"r", @"r", @"e", @"n", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"];
    // en_US@hw=US;sw=QWERTY
    en_US = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"e", @"n", @"_", @"U", @"S", @"@", @"h", @"w", @"=", @"U", @"S", @";", @"s", @"w", @"=", @"Q", @"W", @"E", @"R", @"T", @"Y"];
    // ja_JP-Kana@sw=Kana-Flick;hw=US
    ja_JP = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"j", @"a", @"_", @"J", @"P", @"-", @"K", @"a", @"n", @"a", @"@", @"s", @"w", @"=", @"K", @"a", @"n", @"a", @"-", @"F", @"l", @"i", @"c", @"k", @";", @"h", @"w", @"=", @"U", @"S"];
    // defaultCandidate
    ejUGacPiwpO2dAdcF02M = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"d", @"e", @"f", @"a", @"u", @"l", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"];
    // acceptCandidate:
    Eqo0llHPe80vNAN1bvDB = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"c", @"c", @"e", @"p", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @":"];
    // acceptCurrentCandidateIfSelected
    uNTmdpaswc3OpK7Q3JxE = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"c", @"c", @"e", @"p", @"t", @"C", @"u", @"r", @"r", @"e", @"n", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"I", @"f", @"S", @"e", @"l", @"e", @"c", @"t", @"e", @"d"];
    // _collectionViewController
    JrWofcSm4A8qSWOcgTEg = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"_", @"c", @"o", @"l", @"l", @"e", @"c", @"t", @"i", @"o", @"n", @"V", @"i", @"e", @"w", @"C", @"o", @"n", @"t", @"r", @"o", @"l", @"l", @"e", @"r"];
    // m_candidateList
    khK6OMhSKZlcaj4VrGn3 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"m", @"_", @"c", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"L", @"i", @"s", @"t"];
    // m_candidateResultSet
    zfojM79sdi9CCtYPwy3H = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"m", @"_", @"c", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"R", @"e", @"s", @"u", @"l", @"t", @"S", @"e", @"t"];

    cache = [[NSCache alloc] init];
}

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
    self.keyboardBackgroundView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.5];
    
    [self setupInputEngine];
    [self setupKeyboardView];
    
    self.keyboardInputMethod = NCLKeyboardInputMethodKana;
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
    
    NSString *inputMode = ja_JP;
    if ([[NCLPhysicalKeyboardManager sharedManager] isPhysicalKeyboardAttached] && ![inputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
        inputMode = en_US;
    }
    [self sendMessage:self.internalKeyboard forName:HTcj2RHKk78UgtYwx3Z8 attachments:@[@{@"Object": inputMode}]];
    
    NSString *keyboardType;
    if ([inputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
        keyboardType = @"kana";
        [self.alphabetKeyButton setImage:[UIImage imageNamed:@"key_alphabet"] forState:UIControlStateNormal];
        [self.alphabetKeyButton setImage:[UIImage imageNamed:@"key_alphabet_highlighted"] forState:UIControlStateHighlighted];
        
        [self.numberKeyButton setImage:[UIImage imageNamed:@"key_number"] forState:UIControlStateNormal];
        [self.numberKeyButton setImage:[UIImage imageNamed:@"key_number_highlighted"] forState:UIControlStateHighlighted];
    } else if ([inputMethod isEqualToString:NCLKeyboardInputMethodAlphabet]) {
        keyboardType = @"alphabet";
        [self.alphabetKeyButton setImage:[UIImage imageNamed:@"key_kana"] forState:UIControlStateNormal];
        [self.alphabetKeyButton setImage:[UIImage imageNamed:@"key_kana_highlighted"] forState:UIControlStateHighlighted];
        
        [self.numberKeyButton setImage:[UIImage imageNamed:@"key_number"] forState:UIControlStateNormal];
        [self.numberKeyButton setImage:[UIImage imageNamed:@"key_number_highlighted"] forState:UIControlStateHighlighted];
    } else if ([inputMethod isEqualToString:NCLKeyboardInputMethodNumberPunctuation]) {
        keyboardType = @"number";
        if ([self.lastUsedKeyboardInputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
            [self.numberKeyButton setImage:[UIImage imageNamed:@"key_kana"] forState:UIControlStateNormal];
            [self.numberKeyButton setImage:[UIImage imageNamed:@"key_kana_highlighted"] forState:UIControlStateHighlighted];
        } else if ([self.lastUsedKeyboardInputMethod isEqualToString:NCLKeyboardInputMethodAlphabet]) {
            [self.numberKeyButton setImage:[UIImage imageNamed:@"key_alphabet"] forState:UIControlStateNormal];
            [self.numberKeyButton setImage:[UIImage imageNamed:@"key_alphabet_highlighted"] forState:UIControlStateHighlighted];
        }
    }
    
    int i = 0;
    for (NCLKeyboardButton *keyButton in _keyButtons) {
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_%@_%02d", keyboardType, i]] forState:UIControlStateNormal];
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_%@_%02d_highlighted", keyboardType, i]] forState:UIControlStateHighlighted];
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_%@_%02d_highlighted", keyboardType, i]] forState:UIControlStateSelected];
        [keyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_%@_%02d_highlighted", keyboardType, i]] forState:UIControlStateSelected | UIControlStateHighlighted];
        i++;
    }
    
    [self applySwapBackspaceReturnState];
}

- (void)cursorUp
{
    BOOL hasCandidates = [[self.internalKeyboard valueForKey:TBH2nEKQNPBmyDkQdzCx] boolValue];
    if (hasCandidates) {
        NSString *name = L98fTVmwP43UFtL579EB;
        if ([self.internalKeyboard respondsToSelector:NSSelectorFromString(name)]) {
            [self sendMessage:self.internalKeyboard forName:name attachments:nil];
        }
    } else {
        UITextRange *selectedTextRange = self.textView.selectedTextRange;
        CGRect rect = [self.textView caretRectForPosition:selectedTextRange.start];
        
        CGPoint origin = rect.origin;
        origin.y -= CGRectGetHeight(rect) / 2;
        UITextPosition *position = [self.textView closestPositionToPoint:origin];
        UITextRange *textRange = [self.textView textRangeFromPosition:position toPosition:position];
        self.textView.selectedTextRange = textRange;
    }
}

- (void)cursorDown
{
    BOOL hasCandidates = [[self.internalKeyboard valueForKey:TBH2nEKQNPBmyDkQdzCx] boolValue];
    if (hasCandidates) {
        [self sendMessage:self.internalKeyboard forName:GUU2JdGW8jGWuc388rJR attachments:nil];
    } else {
        UITextRange *selectedTextRange = self.textView.selectedTextRange;
        CGRect rect = [self.textView caretRectForPosition:selectedTextRange.start];
        
        CGPoint origin = rect.origin;
        origin.y += CGRectGetHeight(rect) + CGRectGetHeight(rect) / 2;
        UITextPosition *position = [self.textView closestPositionToPoint:origin];
        UITextRange *textRange = [self.textView textRangeFromPosition:position toPosition:position];
        self.textView.selectedTextRange = textRange;
    }
}

- (void)cursorLeft
{
    if (self.textView.markedTextRange) {
        [self sendMessage:self.internalKeyboard forName:c4TdPa3m8nDVPeha877N attachments:@[@{@"NSInteger": @(1)}]];
    } else if (self.isShifted) {
        NSRange selectedRange = self.textView.selectedRange;
        if (selectedRange.location > 0) {
            selectedRange.location--;
            selectedRange.length++;
            
            self.textView.scrollEnabled = NO;
            self.textView.selectedRange = selectedRange;
            self.textView.scrollEnabled = YES;
        }
    } else {
        NSRange selectedRange = self.textView.selectedRange;
        if (selectedRange.length == 0) {
            if (selectedRange.location > 0) {
                selectedRange.location--;
                
                self.textView.scrollEnabled = NO;
                self.textView.selectedRange = selectedRange;
                self.textView.scrollEnabled = YES;
            }
        } else {
            selectedRange.length = 0;
            
            self.textView.scrollEnabled = NO;
            self.textView.selectedRange = selectedRange;
            self.textView.scrollEnabled = YES;
        }
    }
}

- (void)cursorRight
{
    if (self.textView.markedTextRange) {
        [self sendMessage:self.internalKeyboard forName:c4TdPa3m8nDVPeha877N attachments:@[@{@"NSInteger": @(0)}]];
    } else if (self.isShifted) {
        NSRange selectedRange = self.textView.selectedRange;
        if (selectedRange.location < self.textView.text.length) {
            selectedRange.length++;
            
            self.textView.scrollEnabled = NO;
            self.textView.selectedRange = selectedRange;
            self.textView.scrollEnabled = YES;
        }
    } else {
        NSRange selectedRange = self.textView.selectedRange;
        if (selectedRange.length == 0) {
            if (selectedRange.location < self.textView.text.length) {
                selectedRange.location++;
                
                self.textView.scrollEnabled = NO;
                self.textView.selectedRange = selectedRange;
                self.textView.scrollEnabled = YES;
            }
        } else {
            selectedRange.location = NSMaxRange(selectedRange);
            selectedRange.length = 0;
            
            self.textView.scrollEnabled = NO;
            self.textView.selectedRange = selectedRange;
            self.textView.scrollEnabled = YES;
        }
    }
}

#pragma mark -

- (void)setupInputEngine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyBehavior = [userDefaults stringForKey:NCLSettingsShiftKeyBehaviorKey];
    self.inputEngine = [NCLKeyboardInputEngine inputEngineWithShiftKeyBehavior:shiftKeyBehavior];
    self.inputEngine.delegate = self;
    self.inputEngine.inputMethod = NCLKeyboardInputMethodKana;
    
    float timeShiftDuration = [userDefaults doubleForKey:NCLSettingsTimeShiftDurationKey];
    self.inputEngine.delay = timeShiftDuration;
}

- (void)setupKeyboardView
{
    self.keyButtons = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < 35; i++) {
        NCLKeyboardButton *keyButton = [[NCLKeyboardButton alloc] initWithIndex:i];
        if (i == NCLKeyButtonIndexSpecialKeyDelete) {
            [keyButton addTarget:self action:@selector(touchDownDeleteKey:) forControlEvents:UIControlEventTouchDown];
            [keyButton addTarget:self action:@selector(touchUpDeleteKey:) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == NCLKeyButtonIndexSpecialKeyShift1 || i == NCLKeyButtonIndexSpecialKeyShift2) {
            [keyButton addTarget:self action:@selector(touchDownShiftKey:) forControlEvents:UIControlEventTouchDown];
            [keyButton addTarget:self action:@selector(touchUpShiftKey:) forControlEvents:UIControlEventTouchUpInside];
            [keyButton addTarget:self action:@selector(touchDownRepeatShiftKey:) forControlEvents:UIControlEventTouchDownRepeat];
        } else {
            [keyButton addTarget:self action:@selector(touchDownKey:) forControlEvents:UIControlEventTouchDown];
            [keyButton addTarget:self action:@selector(touchUpKey:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.keyboardBackgroundView addSubview:keyButton];
        [self.keyButtons addObject:keyButton];
    }
}

- (void)setupKeyboardIfNeeded
{
    if (!self.internalKeyboard) {
        self.internalKeyboard = self.textView.inputDelegate;
        [self sendMessage:self.internalKeyboard forName:HTcj2RHKk78UgtYwx3Z8 attachments:@[@{@"Object": ja_JP}]];
        [self sendMessage:self.internalKeyboard forName:SxYmcXP2AFEYh4CXYBMJ attachments:@[@{@"BOOL": @YES}]];
        
        [[NCLPhysicalKeyboardManager sharedManager] setKeyboardView:self];
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
    CGFloat offset;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        CGFloat width = CGRectGetWidth(self.frame);
        offset = (width - 768.0) / 2;

        leftMargin = 6.0 + offset;
        leftPadding = 32.0;
        topMargin = 8.0;
        horizontalSpacing = 6.5;
        verticalSpacing = 8.0;
        keyWidth = 57.0;
        keyHeight = 56.0;
    } else {
        CGFloat width = CGRectGetWidth(self.frame);
        offset = (width - 1024.0) / 2;

        leftMargin = 7.0 + offset;
        leftPadding = 38.0;
        topMargin = 9.0;
        horizontalSpacing = 9.0;
        verticalSpacing = 11.0;
        keyWidth = 76.0;
        keyHeight = 75.0;
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
        self.returnKeyButton.frame = CGRectMake(674.0 + offset, 72.0, 88.0, keyHeight);
        self.numberKeyButton.frame = CGRectMake(5.0 + offset, 200.0, keyWidth, keyHeight);
        self.alphabetKeyButton.frame = CGRectMake(68.5 + offset, 200.0, keyWidth, keyHeight);
        self.leftShiftKeyButton.frame = CGRectMake(132.0 + offset, 200.0, 217.0, keyHeight);
        self.rightShiftKeyButton.frame = CGRectMake(356.0 + offset, 200.0, 216.0, keyHeight);
        self.spaceKeyButton.frame = CGRectMake(578.5 + offset, 200.0, 121.0, keyHeight);
        self.keyboardKeyButton.frame = CGRectMake(706.0 + offset, 200.0, keyWidth, keyHeight);
    } else {
        self.returnKeyButton.frame = CGRectMake(895.0 + offset, 95.0, 122.0, keyHeight);
        self.numberKeyButton.frame = CGRectMake(7.0 + offset, 267.0, keyWidth, keyHeight);
        self.alphabetKeyButton.frame = CGRectMake(92.0 + offset, 267.0, keyWidth, keyHeight);
        self.leftShiftKeyButton.frame = CGRectMake(177.0 + offset, 267.0, 289.0, keyHeight);
        self.rightShiftKeyButton.frame = CGRectMake(475.0 + offset, 267.0, 288.0, keyHeight);
        self.spaceKeyButton.frame = CGRectMake(772.0 + offset, 267.0, 161.0, keyHeight);
        self.keyboardKeyButton.frame = CGRectMake(942.0 + offset, 267.0, keyWidth, keyHeight);
    }
}

- (void)applySwapBackspaceReturnState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL enabled = [userDefaults boolForKey:NCLSettingsSwapBackspaceReturnEnabledKey];
    self.swapBackspaceReturnEnabled = enabled;
}

- (void)setSwapBackspaceReturnEnabled:(BOOL)swapBackspaceReturnEnabled
{
    _swapBackspaceReturnEnabled = swapBackspaceReturnEnabled;
    if (swapBackspaceReturnEnabled) {
        NCLKeyboardButton *deleteKeyButton = self.keyButtons[NCLKeyButtonIndexSpecialKeyDelete];
        [deleteKeyButton setImage:[UIImage imageNamed:@"key_return_swapped"] forState:UIControlStateNormal];
        [deleteKeyButton setImage:[UIImage imageNamed:@"key_return_swapped_highlighted"] forState:UIControlStateHighlighted];
        
        [self.returnKeyButton setImage:[UIImage imageNamed:@"key_delete_swapped"] forState:UIControlStateNormal];
        [self.returnKeyButton setImage:[UIImage imageNamed:@"key_delete_swapped_highlighted"] forState:UIControlStateHighlighted];
    } else {
        NCLKeyboardButton *deleteKeyButton = self.keyButtons[NCLKeyButtonIndexSpecialKeyDelete];
        [deleteKeyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_kana_%02d", NCLKeyButtonIndexSpecialKeyDelete]] forState:UIControlStateNormal];
        [deleteKeyButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"key_kana_%02d_highlighted", NCLKeyButtonIndexSpecialKeyDelete]] forState:UIControlStateHighlighted];
        
        [self.returnKeyButton setImage:[UIImage imageNamed:@"key_return"] forState:UIControlStateNormal];
        [self.returnKeyButton setImage:[UIImage imageNamed:@"key_return_highlighted"] forState:UIControlStateHighlighted];
    }
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

#pragma mark -

- (IBAction)touchDownDeleteKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    
    if (!self.swapBackspaceReturnEnabled) {
        [self processDeleteKeyDown];
    }
}

- (IBAction)touchUpDeleteKey:(id)sender
{
    if (self.swapBackspaceReturnEnabled) {
        [self processReturnKey];
    } else {
        [self processDeleteKeyUp];
    }
}

- (IBAction)touchDownReturnKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    if (self.swapBackspaceReturnEnabled) {
        [self processDeleteKeyDown];
    }
}

- (IBAction)touchUpReturnKey:(id)sender
{
    if (!self.swapBackspaceReturnEnabled) {
        [self processReturnKey];
    } else {
        [self sendMessage:self.internalKeyboard forName:jLdpi9URsHKDRWf36aE6 attachments:nil];
    }
}

- (void)processDeleteKeyDown
{
    [self sendMessage:self.internalKeyboard forName:PArjMGcJEYULesZzYbwp attachments:nil];
    [self sendMessage:self.internalKeyboard forName:G2AmM5eQZ4RxKLM3TCKZ attachments:nil];
    
    if ([self.delegate respondsToSelector:@selector(keyboardViewInputEnter:)]) {
        [self.delegate keyboardViewInputBackspace:self];
    }
}

- (void)processDeleteKeyUp
{
    [self sendMessage:self.internalKeyboard forName:jLdpi9URsHKDRWf36aE6 attachments:nil];
}

- (void)processReturnKey
{
    if (![self acceptCandidate]) {
        [self sendMessage:self.internalKeyboard forName:mb6FzfJW6t9XaDQkna7m attachments:@[@{@"Object": @"\n"}]];
    }
    if ([self.delegate respondsToSelector:@selector(keyboardViewInputEnter:)]) {
        [self.delegate keyboardViewInputEnter:self];
    }
}

- (BOOL)acceptCandidate {
    BOOL hasCandidates = [[self.internalKeyboard valueForKey:TBH2nEKQNPBmyDkQdzCx] boolValue];
    if (hasCandidates) {
        id candidateResultSet = [self.internalKeyboard valueForKey:zfojM79sdi9CCtYPwy3H];
        id candidateList = [self.internalKeyboard valueForKey:khK6OMhSKZlcaj4VrGn3];

        UICollectionViewController *collectionViewController = [candidateList valueForKey:JrWofcSm4A8qSWOcgTEg];
        UICollectionView *collectionView = collectionViewController.collectionView;
        NSArray *selectedIndexPaths = collectionView.indexPathsForSelectedItems;
        if (selectedIndexPaths.count > 0) {
            [self sendMessage:self.internalKeyboard forName:uNTmdpaswc3OpK7Q3JxE attachments:nil];
            return YES;
        } else {
            id defaultCandidate = [candidateResultSet valueForKey:ejUGacPiwpO2dAdcF02M];
            if (defaultCandidate) {
                [self sendMessage:self.internalKeyboard forName:Eqo0llHPe80vNAN1bvDB attachments:@[@{@"Object": defaultCandidate}]];
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark -

- (void)touchDownShiftKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    
    self.shiftLocked = NO;
    self.shifted = YES;
}

- (void)touchUpShiftKey:(id)sender
{
    if (self.shiftLocked) {
        return;
    }
    
    self.shiftLocked = NO;
    self.shifted = NO;
}

- (void)touchDownRepeatShiftKey:(id)sender
{
    self.shiftLocked = !self.shiftLocked;
    self.shifted = self.shiftLocked;
}

- (void)setShifted:(BOOL)shifted
{
    _shifted = shifted;
    self.inputEngine.shifted = shifted;
    
    if (shifted) {
        if ([self.delegate respondsToSelector:@selector(keyboardViewInputShiftDown:)]) {
            [self.delegate keyboardViewInputShiftDown:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(keyboardViewInputShiftUp:)]) {
            [self.delegate keyboardViewInputShiftUp:self];
        }
    }
}

- (void)setShiftLocked:(BOOL)shiftLocked
{
    _shiftLocked = shiftLocked;
    
    NCLKeyboardButton *shift1KeyButton = self.keyButtons[NCLKeyButtonIndexSpecialKeyShift1];
    shift1KeyButton.selected = shiftLocked;
    
    NCLKeyboardButton *shift2KeyButton = self.keyButtons[NCLKeyButtonIndexSpecialKeyShift2];
    shift2KeyButton.selected = shiftLocked;
}

#pragma mark -

- (IBAction)touchDownNumberKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    
    if ([self.keyboardInputMethod isEqualToString:NCLKeyboardInputMethodNumberPunctuation]) {
        self.keyboardInputMethod = self.lastUsedKeyboardInputMethod;
    } else {
        self.lastUsedKeyboardInputMethod = self.keyboardInputMethod;
        self.keyboardInputMethod = NCLKeyboardInputMethodNumberPunctuation;
    }
}

- (IBAction)touchDownAlphabetKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    
    if ([self.keyboardInputMethod isEqualToString:NCLKeyboardInputMethodNumberPunctuation]) {
        if ([self.lastUsedKeyboardInputMethod isEqualToString:NCLKeyboardInputMethodKana]) {
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
    [self sendMessage:self.internalKeyboard　forName:mb6FzfJW6t9XaDQkna7m　attachments:@[@{@"Object": @" "}]];
    
    if ([self.delegate respondsToSelector:@selector(keyboardViewInputSpace:)]) {
        [self.delegate keyboardViewInputSpace:self];
    }
}

- (IBAction)touchUpKeyboardKey:(id)sender
{
    [self.textView endEditing:NO];
    
    if ([self.delegate respondsToSelector:@selector(keyboardViewInputHideKeyboard:)]) {
        [self.delegate keyboardViewInputHideKeyboard:self];
    }
}

#pragma mark -

- (void)keyboardInputEngine:(NCLKeyboardInputEngine *)engine processedText:(NSString *)text keyIndex:(NSInteger)keyIndex
{
    if (text.length > 0) {
        [self sendMessage:self.internalKeyboard forName:mb6FzfJW6t9XaDQkna7m attachments:@[@{@"Object": text}]];
        
        if ([self.delegate respondsToSelector:@selector(keyboardView:inputText:)]) {
            [self.delegate keyboardView:self inputText:text];
        }
    }
}

- (void)keyboardInputEngineDidInputLeftShiftKey:(NCLKeyboardInputEngine *)engine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyFunction = [userDefaults stringForKey:NCLSettingsLeftShiftFunctionKey];
    if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionNextCandidate]) {
        [self sendMessage:self.internalKeyboard forName:GUU2JdGW8jGWuc388rJR attachments:nil];
        
        if ([self.delegate respondsToSelector:@selector(keyboardViewInputNextCandidate:)]) {
            [self.delegate keyboardViewInputNextCandidate:self];
        }
    } else if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionAcceptCandidate]) {
        [self acceptCandidate];

        if ([self.delegate respondsToSelector:@selector(keyboardViewInputEnter:)]) {
            [self.delegate keyboardViewInputEnter:self];
        }
    }
}

- (void)keyboardInputEngineDidInputRightShiftKey:(NCLKeyboardInputEngine *)engine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyFunction = [userDefaults stringForKey:NCLSettingsRightShiftFunctionKey];
    if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionNextCandidate]) {
        [self sendMessage:self.internalKeyboard forName:GUU2JdGW8jGWuc388rJR attachments:nil];
        
        if ([self.delegate respondsToSelector:@selector(keyboardViewInputNextCandidate:)]) {
            [self.delegate keyboardViewInputNextCandidate:self];
        }
    } else if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionAcceptCandidate]) {
        [self acceptCandidate];

        if ([self.delegate respondsToSelector:@selector(keyboardViewInputEnter:)]) {
            [self.delegate keyboardViewInputEnter:self];
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
    if (!methodSignature) {
        return nil;
    }
    
    NSInvocation *invocation = [cache objectForKey:name];
    if (!invocation) {
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = selector;
        
        [cache setObject:invocation forKey:name];
    }
    
    invocation.target = target;
    NSInteger index = 2;
    for (NSDictionary *attachment in attachments) {
        for (NSString *type in attachment.allKeys) {
            if ([type isEqualToString:@"Object"]) {
                id argument = attachment[type];
                [invocation setArgument:&argument atIndex:index];
            } else if ([type isEqualToString:@"BOOL"]) {
                BOOL argument = [attachment[type] boolValue];
                [invocation setArgument:&argument atIndex:index];
            } else if ([type isEqualToString:@"NSInteger"]) {
                NSInteger argument = [attachment[type] integerValue];
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

- (CGSize)intrinsicContentSize {
    NCLPhysicalKeyboardManager *keyboardManager = [NCLPhysicalKeyboardManager sharedManager];
    if (keyboardManager.isPhysicalKeyboardAttached) {
        return CGSizeMake(UIViewNoIntrinsicMetric, 0.0);
    }
    UIScreen *mainScreen = [UIScreen mainScreen];
    if(mainScreen.bounds.size.width < mainScreen.bounds.size.height){
        return CGSizeMake(UIViewNoIntrinsicMetric, 264.0);
    }
    else{
        return CGSizeMake(UIViewNoIntrinsicMetric, 352.0);
    }

}

@end
