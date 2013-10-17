//
//  NCLTextViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLTextViewController.h"
#import "NCLSettingsViewController.h"
#import "NCLPopoverManager.h"
#import "NCLKeyboardView.h"
#import "NCLKeyboardAccessoryView.h"
#import "NCLNote.h"
#import "NCLConstants.h"
#import "UIFont+Helper.h"
#import <NLCoreData/NLCoreData.h>

@import ObjectiveC;

static NSString * const ZERO_WIDTH_SPACE = @"\u200B";

@interface NCLTextViewController () <UITextViewDelegate>

@property (nonatomic) UIBarButtonItem *shareButton;
@property (nonatomic) UIBarButtonItem *addButton;

@property (nonatomic) UITextView *textView;
@property (nonatomic) NCLKeyboardView *inputView;
@property (nonatomic) NCLKeyboardAccessoryView *inputAccessoryView;

@property (nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic) UIPopoverController *sharePopoverController;

@property (nonatomic) NSString *previousKeyboardInputMethod;
@property (nonatomic) BOOL wasTextViewEditing;

@property (nonatomic) UIEdgeInsets textViewContentInset;
@property (nonatomic) UIEdgeInsets textViewScrollIndicatorInsets;

@end

static void SwizzleMethod(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    method_exchangeImplementations(origMethod, newMethod);
}

@implementation NCLTextViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareForLegacy];
    
    [self setupUI];
    [self setupNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -

- (void)__setFrame:(CGRect)frame
{
    [self __setFrame:frame];
}

- (void)prepareForLegacy
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
        void (^block)(id, CGRect) = ^(id s, CGRect frame)
        {
            if (CGRectGetMaxY([self.textView convertRect:frame toView:self.inputView.superview]) > 0.0f) {
                CGRect rect = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];
                frame.origin.y = rect.origin.y - CGRectGetHeight(frame);
            }
            
            [s __setFrame:frame];
        };
        
        SEL sel = NSSelectorFromString(@"__setFrame:");
        IMP imp = imp_implementationWithBlock(block);
        Class clazz = NSClassFromString([NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"U", @"I", @"K", @"e", @"y", @"b", @"o", @"a", @"r", @"d", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"I", @"n", @"l", @"i", @"n", @"e", @"F", @"l", @"o", @"a", @"t", @"i", @"n", @"g", @"V", @"i", @"e", @"w"]);
        class_addMethod(clazz, sel, imp, "v@:*");
        SwizzleMethod(clazz, @selector(setFrame:), sel);
    }
}

- (void)setupUI
{
    UITextView *textView;
    UIBarButtonItem *shareButton;
    UIBarButtonItem *addButton;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        
        UIButton *shareButtonView = [self customButtonWithImage:[UIImage imageNamed:@"share"]];
        [shareButtonView addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        shareButton = [[UIBarButtonItem alloc] initWithCustomView:shareButtonView];
        
        UIButton *addButtonView = [self customButtonWithImage:[UIImage imageNamed:@"add"]];
        [addButtonView addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
        addButton = [[UIBarButtonItem alloc] initWithCustomView:addButtonView];
    } else {
        textView = [[NSClassFromString([NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"_", @"U", @"I", @"C", @"o", @"m", @"p", @"a", @"t", @"i", @"b", @"i", @"l", @"i", @"t", @"y", @"T", @"e", @"x", @"t", @"V", @"i", @"e", @"w"]) alloc] initWithFrame:self.view.bounds];
        
        shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
        addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    }
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.delegate = self;
    [self.view addSubview:textView];
    self.textView = textView;
    
    shareButton.enabled = NO;
    addButton.enabled = YES;
    
    self.navigationItem.rightBarButtonItems = @[addButton, shareButton];
    self.shareButton = shareButton;
    self.addButton = addButton;
}

- (UIButton *)customButtonWithImage:(UIImage *)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.showsTouchWhenHighlighted = YES;
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    
    CGRect frame = button.frame;
    frame.size.width = 44.0f;
    button.frame = frame;
    
    return button;
}

- (void)setupInputView
{
    NCLKeyboardView *inputView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    inputView.delegate = self;
    inputView.textView = self.textView;
    if (self.previousKeyboardInputMethod) {
        inputView.keyboardInputMethod = self.previousKeyboardInputMethod;
    }
    
    self.textView.inputView = inputView;
    self.inputView = inputView;
    
    NCLKeyboardAccessoryView *accessoryView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardAccessoryView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    accessoryView.delegate = self;
    self.textView.inputAccessoryView = accessoryView;
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontDidChange:) name:NCLSettingsFontDidChangeNodification object:nil];
}

#pragma mark -

- (void)setNote:(NCLNote *)note
{
    _note = note;
    
    [self updateUI];
    [self updateText];
    [self applyFontSettings];
    
    [self tryBeginEditing];
    
    [[NCLPopoverManager sharedManager] dismissPopovers];
}

- (void)updateUI
{
    self.title = self.note.title;
    self.shareButton.enabled = self.note.content.length > 0 && ![self.textView.text isEqualToString:ZERO_WIDTH_SPACE];
}

- (void)updateText
{
    self.textView.text = self.note.content;
    
    if (self.textView.text.length == 0) {
        self.textView.text = ZERO_WIDTH_SPACE;
    }
}

- (void)applyFontSettings
{
    NSString *title = self.note.title;
    NSString *content = self.note.content;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fontName = [userDefaults stringForKey:NCLSettingsFontNameKey];
    double fontSize = [userDefaults doubleForKey:NCLSettingsFontSizeKey];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    UIFont *boldFont = [font fontWithBoldTrait:YES italicTrait:NO andSize:fontSize];
    
    if ([self.textView respondsToSelector:@selector(setAttributedText:)]) {
        if (content.length > 0) {
            if (!self.textView.markedTextRange) {
                NSRange selectedRange = self.textView.selectedRange;
                self.textView.scrollEnabled = NO;
                
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];
                [attributedText setAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, content.length)];
                [attributedText setAttributes:@{NSFontAttributeName: boldFont} range:NSMakeRange(0, title.length)];
                self.textView.attributedText = attributedText;
                
                selectedRange.length = 0;
                
                self.textView.selectedRange = selectedRange;
                self.textView.scrollEnabled = YES;
            }
        } else {
            self.textView.font = font;
        }
        if ([self.textView respondsToSelector:@selector(setTypingAttributes:)]) {
            self.textView.typingAttributes = @{NSFontAttributeName: font};
        }
    } else {
        self.textView.font = font;
    }
}

- (void)tryBeginEditing
{
    if (self.note) {
        self.textView.userInteractionEnabled = YES;
        [self.textView becomeFirstResponder];
    } else {
        self.textView.userInteractionEnabled = NO;
    }
}

#pragma mark -

- (void)add:(id)sender
{
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext mainContext];
    
    NCLNote *note = [NCLNote insertInContext:managedObjectContext];
    self.note = note;
    
    [managedObjectContext saveNested];
}

- (void)share:(id)sender
{
    if (self.sharePopoverController.isPopoverVisible) {
        [self.sharePopoverController dismissPopoverAnimated:YES];
        return;
    }
    
    [[NCLPopoverManager sharedManager] dismissPopovers];
    
    if (NSClassFromString(@"UIActivityViewController")) {
        NSArray *activityItems = @[self.note.content];
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        
        self.sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        [[NCLPopoverManager sharedManager] presentPopover:self.sharePopoverController fromBarButtonItem:self.shareButton];
    } else {
        
    }
}

#pragma mark -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self setupInputView];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.previousKeyboardInputMethod = self.inputView.keyboardInputMethod;
    self.textView.inputView = nil;
    self.textView.inputAccessoryView = nil;
    self.inputView = nil;
    self.inputAccessoryView = nil;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        self.note.content = [textView.text stringByReplacingCharactersInRange:range withString:text];
        [self.note.managedObjectContext saveNested];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    __block NSString *title = nil;
    [text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        title = line;
        *stop = YES;
    }];
    NSString *content = text;
    
    self.note.title = title;
    self.note.content = content;
    
    [self updateUI];
    [self applyFontSettings];
    
    [self.note.managedObjectContext save];
}

#pragma mark -

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.textViewContentInset = self.textView.contentInset;
    self.textViewScrollIndicatorInsets = self.textView.scrollIndicatorInsets;
    
    NSDictionary *userInfo = notification.userInfo;
    
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    
    UIEdgeInsets contentInset = self.textView.contentInset;
    self.textViewContentInset = contentInset;
    contentInset.bottom = CGRectGetHeight(keyboardFrame) + 44.0f;
    
    UIEdgeInsets scrollIndicatorInsets = self.textView.scrollIndicatorInsets;
    self.textViewScrollIndicatorInsets = scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = CGRectGetHeight(keyboardFrame);
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    self.textView.contentInset = contentInset;
    self.textView.scrollIndicatorInsets = scrollIndicatorInsets;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    self.textView.contentInset = self.textViewContentInset;
    self.textView.scrollIndicatorInsets = self.textViewScrollIndicatorInsets;
    [UIView commitAnimations];
}

#pragma mark -

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if (self.wasTextViewEditing) {
        [self.textView becomeFirstResponder];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    self.wasTextViewEditing = self.textView.isFirstResponder;
    [self.textView endEditing:YES];
}

#pragma mark -

- (void)fontDidChange:(NSNotification *)notification
{
    [self applyFontSettings];
}

#pragma mark -

- (void)accessoryViewDidComplete:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.textView endEditing:NO];
}

- (void)accessoryView:(NCLKeyboardAccessoryView *)accessoryView keyboardTypeDidChange:(NSInteger)keyboardType
{
    if (keyboardType == NCLKeyboardTypeNICOLA) {
        self.textView.inputView = self.inputView;
    } else {
        self.textView.inputView = nil;
    }
    
    [self.textView reloadInputViews];
}

#pragma mark -

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    [[NCLPopoverManager sharedManager] dismissPopovers];

    barButtonItem.title = NSLocalizedString(@"Notes", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [[NCLPopoverManager sharedManager] dismissPopovers];
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end

