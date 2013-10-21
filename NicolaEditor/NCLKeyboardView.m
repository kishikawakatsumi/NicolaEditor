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

@import ObjectiveC;

NSInteger const NCLKeyButtonIndexSpecialKeyDelete = 11;
NSInteger const NCLKeyButtonIndexSpecialKeyShift1 = 22;
NSInteger const NCLKeyButtonIndexSpecialKeyShift2 = 33;

static NSString *a_d_d_I_n_p_u_t_S_t_r_i_n_g_$;
static NSString *d_e_l_e_t_e_F_r_o_m_I_n_p_u_t;
static NSString *s_t_a_r_t_A_u_t_o_D_e_l_e_t_e_T_i_m_e_r;
static NSString *s_t_o_p_A_u_t_o_D_e_l_e_t_e;
static NSString *s_e_t_I_n_p_u_t_M_o_d_e_$;
static NSString *m_o_v_e_P_h_r_a_s_e_B_o_u_n_d_a_r_y_T_o_D_i_r_e_c_t_i_o_n_$;
static NSString *__h_a_s_C_a_n_d_i_d_a_t_e_s;
static NSString *u_s_e_r_S_e_l_e_c_t_e_d_C_u_r_r_e_n_t_C_a_n_d_i_d_a_t_e;
static NSString *s_h_o_w_P_r_e_v_i_o_u_s_C_a_n_d_i_d_a_t_e;
static NSString *s_h_o_w_N_e_x_t_C_a_n_d_i_d_a_t_e_s;
static NSString *s_e_t_S_h_o_w_s_C_a_n_d_i_d_a_t_e_I_n_l_i_n_e_$;
static NSString *a_c_c_e_p_t_C_u_r_r_e_n_t_C_a_n_d_i_d_a_t_e;
static NSString *en_US;
static NSString *ja_JP;

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
    __h_a_s_C_a_n_d_i_d_a_t_e_s = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"_", @"h", @"a", @"s", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"s"];
    s_e_t_I_n_p_u_t_M_o_d_e_$ = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"I", @"n", @"p", @"u", @"t", @"M", @"o", @"d", @"e", @":"];
    en_US = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"e", @"n", @"_", @"U", @"S", @"@", @"h", @"w", @"=", @"U", @"S", @";", @"s", @"w", @"=", @"Q", @"W", @"E", @"R", @"T", @"Y"];
    ja_JP = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"j", @"a", @"_", @"J", @"P", @"-", @"K", @"a", @"n", @"a", @"@", @"s", @"w", @"=", @"K", @"a", @"n", @"a", @"-", @"F", @"l", @"i", @"c", @"k", @";", @"h", @"w", @"=", @"U", @"S"];
    s_h_o_w_P_r_e_v_i_o_u_s_C_a_n_d_i_d_a_t_e = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"h", @"o", @"w", @"P", @"r", @"e", @"v", @"i", @"o", @"u", @"s", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"];
    s_h_o_w_N_e_x_t_C_a_n_d_i_d_a_t_e_s = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"h", @"o", @"w", @"N", @"e", @"x", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"s"];
    m_o_v_e_P_h_r_a_s_e_B_o_u_n_d_a_r_y_T_o_D_i_r_e_c_t_i_o_n_$ = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"m", @"o", @"v", @"e", @"P", @"h", @"r", @"a", @"s", @"e", @"B", @"o", @"u", @"n", @"d", @"a", @"r", @"y", @"T", @"o", @"D", @"i", @"r", @"e", @"c", @"t", @"i", @"o", @"n", @":"];
    s_e_t_S_h_o_w_s_C_a_n_d_i_d_a_t_e_I_n_l_i_n_e_$ = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"S", @"h", @"o", @"w", @"s", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"I", @"n", @"l", @"i", @"n", @"e", @":"];
    d_e_l_e_t_e_F_r_o_m_I_n_p_u_t = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"d", @"e", @"l", @"e", @"t", @"e", @"F", @"r", @"o", @"m", @"I", @"n", @"p", @"u", @"t"];
    s_t_a_r_t_A_u_t_o_D_e_l_e_t_e_T_i_m_e_r = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"t", @"a", @"r", @"t", @"A", @"u", @"t", @"o", @"D", @"e", @"l", @"e", @"t", @"e", @"T", @"i", @"m", @"e", @"r"];
    s_t_o_p_A_u_t_o_D_e_l_e_t_e = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"t", @"o", @"p", @"A", @"u", @"t", @"o", @"D", @"e", @"l", @"e", @"t", @"e"];
    a_c_c_e_p_t_C_u_r_r_e_n_t_C_a_n_d_i_d_a_t_e = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"c", @"c", @"e", @"p", @"t", @"C", @"u", @"r", @"r", @"e", @"n", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"];
    a_d_d_I_n_p_u_t_S_t_r_i_n_g_$ = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"a", @"d", @"d", @"I", @"n", @"p", @"u", @"t", @"S", @"t", @"r", @"i", @"n", @"g", @":"];
    u_s_e_r_S_e_l_e_c_t_e_d_C_u_r_r_e_n_t_C_a_n_d_i_d_a_t_e = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"u", @"s", @"e", @"r", @"S", @"e", @"l", @"e", @"c", @"t", @"e", @"d", @"C", @"u", @"r", @"r", @"e", @"n", @"t", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e"];
    
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
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.keyboardBackgroundView.backgroundColor = [UIColor colorWithRed:0.812 green:0.824 blue:0.839 alpha:1.000];
    }
    
    [self setupInputEngine];
    [self setupKeyboardView];
    
    self.keyboardInputMethod = NCLKeyboardInputMethodKana;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shiftKeyBehaviorDidChange:) name:NCLSettingsShiftKeyBehaviorDidChangeNodification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swapBackspaceReturnEnabledDidChange:) name:NCLSettingsSwapBackspaceReturnEnabledDidChangeNodification object:nil];
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
    [self sendMessage:self.internalKeyboard
              forName:s_e_t_I_n_p_u_t_M_o_d_e_$
          attachments:@[@{@"Object": ja_JP}]];
    
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
    
    NSInteger i = 0;
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
    BOOL hasCandidates = [[self.internalKeyboard valueForKey:__h_a_s_C_a_n_d_i_d_a_t_e_s] boolValue];
    if (hasCandidates) {
        NSString *name = s_h_o_w_P_r_e_v_i_o_u_s_C_a_n_d_i_d_a_t_e;
        if ([self.internalKeyboard respondsToSelector:NSSelectorFromString(name)]) {
            [self sendMessage:self.internalKeyboard
                      forName:name
                  attachments:nil];
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
    BOOL hasCandidates = [[self.internalKeyboard valueForKey:__h_a_s_C_a_n_d_i_d_a_t_e_s] boolValue];
    if (hasCandidates) {
        [self sendMessage:self.internalKeyboard
                  forName:s_h_o_w_N_e_x_t_C_a_n_d_i_d_a_t_e_s
              attachments:nil];
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
        [self sendMessage:self.internalKeyboard
                  forName:m_o_v_e_P_h_r_a_s_e_B_o_u_n_d_a_r_y_T_o_D_i_r_e_c_t_i_o_n_$
              attachments:@[@{@"NSInteger": @(1)}]];
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
        [self sendMessage:self.internalKeyboard
                  forName:m_o_v_e_P_h_r_a_s_e_B_o_u_n_d_a_r_y_T_o_D_i_r_e_c_t_i_o_n_$
              attachments:@[@{@"NSInteger": @(0)}]];
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
        [self sendMessage:self.internalKeyboard
                  forName:s_e_t_I_n_p_u_t_M_o_d_e_$
              attachments:@[@{@"Object": ja_JP}]];
        [self sendMessage:self.internalKeyboard
                  forName:s_e_t_S_h_o_w_s_C_a_n_d_i_d_a_t_e_I_n_l_i_n_e_$
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

- (void)swapBackspaceReturnEnabledDidChange:(NSNotification *)notification
{
    [self applySwapBackspaceReturnState];
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
        [self processDeleteKey];
    }
}

- (IBAction)touchUpDeleteKey:(id)sender
{
    if (self.swapBackspaceReturnEnabled) {
        [self processReturnKey];
    } else {
        [self sendMessage:self.internalKeyboard
                  forName:s_t_o_p_A_u_t_o_D_e_l_e_t_e
              attachments:nil];
    }
}

- (IBAction)touchDownReturnKey:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    if (self.swapBackspaceReturnEnabled) {
        [self processDeleteKey];
    }
}

- (IBAction)touchUpReturnKey:(id)sender
{
    if (!self.swapBackspaceReturnEnabled) {
        [self processReturnKey];
    } else {
        [self sendMessage:self.internalKeyboard
                  forName:s_t_o_p_A_u_t_o_D_e_l_e_t_e
              attachments:nil];
    }
}

- (void)processDeleteKey
{
    [self sendMessage:self.internalKeyboard
              forName:d_e_l_e_t_e_F_r_o_m_I_n_p_u_t
          attachments:nil];
    [self sendMessage:self.internalKeyboard
              forName:s_t_a_r_t_A_u_t_o_D_e_l_e_t_e_T_i_m_e_r
          attachments:nil];
}

- (void)processReturnKey
{
    BOOL hasCandidates = [[self.internalKeyboard valueForKey:__h_a_s_C_a_n_d_i_d_a_t_e_s] boolValue];
    if (hasCandidates) {
        [self sendMessage:self.internalKeyboard
                  forName:a_c_c_e_p_t_C_u_r_r_e_n_t_C_a_n_d_i_d_a_t_e
              attachments:nil];
        return;
    }
    
    [self sendMessage:self.internalKeyboard
              forName:a_d_d_I_n_p_u_t_S_t_r_i_n_g_$
          attachments:@[@{@"Object": @"\n"}]];
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

- (IBAction)touchDownRepeatShiftKey:(id)sender
{
    self.shiftLocked = !self.shiftLocked;
    self.shifted = self.shiftLocked;
}

- (void)setShifted:(BOOL)shifted
{
    _shifted = shifted;
    self.inputEngine.shifted = shifted;
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
    [self sendMessage:self.internalKeyboard
              forName:a_d_d_I_n_p_u_t_S_t_r_i_n_g_$
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
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            NSString *key = u_s_e_r_S_e_l_e_c_t_e_d_C_u_r_r_e_n_t_C_a_n_d_i_d_a_t_e;
            if ([self.internalKeyboard respondsToSelector:NSSelectorFromString(key)]) {
                BOOL userSelectedCurrentCandidate = [[self.internalKeyboard valueForKey:key] boolValue];
                if (userSelectedCurrentCandidate) {
                    [self sendMessage:self.internalKeyboard
                              forName:a_c_c_e_p_t_C_u_r_r_e_n_t_C_a_n_d_i_d_a_t_e
                          attachments:nil];
                }
            }
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self sendMessage:self.internalKeyboard
                          forName:a_d_d_I_n_p_u_t_S_t_r_i_n_g_$
                      attachments:@[@{@"Object": text}]];
            });
        } else {
            [self sendMessage:self.internalKeyboard
                      forName:a_d_d_I_n_p_u_t_S_t_r_i_n_g_$
                  attachments:@[@{@"Object": text}]];
        }
    }
}

- (void)keyboardInputEngineDidInputLeftShiftKey:(NCLKeyboardInputEngine *)engine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyFunction = [userDefaults stringForKey:NCLSettingsLeftShiftFunctionKey];
    if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionNextCandidate]) {
        [self sendMessage:self.internalKeyboard
                  forName:s_h_o_w_N_e_x_t_C_a_n_d_i_d_a_t_e_s
              attachments:nil];
    } else if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionAcceptCandidate]) {
        BOOL hasCandidates = [[self.internalKeyboard valueForKey:__h_a_s_C_a_n_d_i_d_a_t_e_s] boolValue];
        if (hasCandidates) {
            [self sendMessage:self.internalKeyboard
                      forName:a_c_c_e_p_t_C_u_r_r_e_n_t_C_a_n_d_i_d_a_t_e
                  attachments:nil];
        }
    }
}

- (void)keyboardInputEngineDidInputRightShiftKey:(NCLKeyboardInputEngine *)engine
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyFunction = [userDefaults stringForKey:NCLSettingsRightShiftFunctionKey];
    if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionNextCandidate]) {
        [self sendMessage:self.internalKeyboard
                  forName:s_h_o_w_N_e_x_t_C_a_n_d_i_d_a_t_e_s
              attachments:nil];
    } else if ([shiftKeyFunction isEqualToString:NCLShiftKeyFunctionAcceptCandidate]) {
        BOOL hasCandidates = [[self.internalKeyboard valueForKey:__h_a_s_C_a_n_d_i_d_a_t_e_s] boolValue];
        if (hasCandidates) {
            [self sendMessage:self.internalKeyboard
                      forName:a_c_c_e_p_t_C_u_r_r_e_n_t_C_a_n_d_i_d_a_t_e
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

@end
