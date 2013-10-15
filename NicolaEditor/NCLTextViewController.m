//
//  NCLTextViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLTextViewController.h"
#import "NCLSettingsViewController.h"
#import "NCLKeyboardView.h"
#import "NCLKeyboardAccessoryView.h"
#import "NCLNote.h"
#import <NLCoreData/NLCoreData.h>

@interface NCLTextViewController () <UITextViewDelegate>

@property (nonatomic) UIPopoverController *popover;

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic) NCLKeyboardView *inputView;
@property (nonatomic) NSString *previousInputMode;

@property (nonatomic) UIEdgeInsets textViewContentInset;
@property (nonatomic) UIEdgeInsets textViewScrollIndicatorInsets;

@property (nonatomic) UIBarButtonItem *shareButton;

@end

@implementation NCLTextViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [shareButton sizeToFit];
        CGRect frame = shareButton.frame;
        frame.size.width = 44.0f;
        shareButton.frame = frame;
        shareButton.showsTouchWhenHighlighted = YES;
        [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        
        self.shareButton = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
        self.shareButton.enabled = NO;
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [addButton sizeToFit];
        frame = addButton.frame;
        frame.size.width = 44.0f;
        addButton.frame = frame;
        addButton.showsTouchWhenHighlighted = YES;
        [addButton addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        
        self.navigationItem.rightBarButtonItems = @[addBarButton, self.shareButton];
    } else {
        self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
        self.shareButton.enabled = NO;
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
        
        self.navigationItem.rightBarButtonItems = @[addButton, self.shareButton];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSettingsChanged:) name:NCLFontSettingsChanged object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -

- (void)setupInputView
{
    self.inputView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    self.inputView.delegate = self;
    self.inputView.textView = self.textView;
    
    self.textView.inputView = self.inputView;
    
    NCLKeyboardAccessoryView *accessoryView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardAccessoryView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    accessoryView.delegate = self;
    self.textView.inputAccessoryView = accessoryView;
}

#pragma mark -

- (void)setNote:(NCLNote *)note
{
    _note = note;
    [self updateUI];
    
    if (self.popover.isPopoverVisible) {
        [self.popover dismissPopoverAnimated:YES];
    }
}

- (void)updateUI
{
    [self fontSettingsChanged:nil];
    
    if (self.note) {
        NSString *title = self.note.title;
        NSString *content = self.note.content;
        
        self.navigationItem.title = title;
        self.shareButton.enabled = content.length > 0;
        
        self.textView.text = content;
        [self titleChanged:title];
        
        self.textView.userInteractionEnabled = YES;
        [self.textView becomeFirstResponder];
        
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self keyboardDidShow:nil];
        });
    } else {
        self.textView.userInteractionEnabled = NO;
    }
}

- (void)titleChanged:(NSString *)title
{
    UITextView *textView = self.textView;
    NSString *text = textView.text;
    NSRange selectedRange = textView.selectedRange;
    
    self.navigationItem.title = title;
    self.shareButton.enabled = text.length > 0;
    
    self.note.title = title;
    
    if (!textView.markedTextRange && [textView respondsToSelector:@selector(setAttributedText:)]) {
        UIFont *font;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *fontName = [userDefaults stringForKey:@"font-name"];
        double fontSize = [userDefaults doubleForKey:@"font-size"];
        
        if ([fontName isEqualToString:@"HiraMinProN-W3"]) {
            font = [UIFont fontWithName:@"HiraMinProN-W6" size:fontSize];
        } else if ([fontName isEqualToString:@"HiraKakuProN-W3"]) {
            font = [UIFont fontWithName:@"HiraKakuProN-W6" size:fontSize];
        }
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedText setAttributes:@{NSFontAttributeName: [UIFont fontWithName:fontName size:fontSize]} range:NSMakeRange(0, text.length)];
        [attributedText setAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, title.length)];
        textView.attributedText = attributedText;
        
        textView.selectedRange = selectedRange;
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
    self.previousInputMode = self.inputView.inputMode;
    self.textView.inputView = nil;
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
    NSRange selection = textView.selectedRange;
    if (textView.text.length > 0 && selection.location + selection.length == textView.text.length && [textView.text characterAtIndex:textView.text.length - 1] == '\n') {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            [textView layoutSubviews];
            [textView scrollRectToVisible:CGRectMake(0.0f, textView.contentSize.height - 1.0f, 1.0f, 1.0f) animated:YES];
        }
    } else {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            [textView scrollRangeToVisible:textView.selectedRange];
        }
    }
    
    NSString *text = textView.text;
    __block NSString *title = nil;
    [text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        title = line;
        *stop = YES;
    }];
    
    [self titleChanged:title];
    
    self.note.content = text;
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
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.size.height = CGRectGetMinY(keyboardFrame);
    
    UIEdgeInsets contentInset = self.textView.contentInset;
    self.textViewContentInset = contentInset;
    contentInset.bottom = 44.0f;
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    self.textView.frame = textViewFrame;
    self.textView.contentInset = contentInset;
    [UIView commitAnimations];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [self.textView insertText:@""];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    self.textView.frame = self.view.bounds;
    self.textView.contentInset = self.textViewContentInset;
    [UIView commitAnimations];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self.textView endEditing:YES];
}

#pragma mark -

- (void)fontSettingsChanged:(NSNotification *)notification
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fontName = [userDefaults stringForKey:@"font-name"];
    double fontSize = [userDefaults doubleForKey:@"font-size"];
    
    self.textView.font = [UIFont fontWithName:fontName size:fontSize];
}

#pragma mark -

- (void)add:(id)sender
{
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext mainContext];
    
    NCLNote *note = [NCLNote insertInContext:managedObjectContext];
    self.note = note;
    
    [managedObjectContext saveNested];
}

- (void)archive:(id)sender
{
    
}

- (void)share:(id)sender
{
    NSArray *activityItems = @[self.note.content];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    if (self.popover.isPopoverVisible) {
        [self.popover dismissPopoverAnimated:YES];
    }
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    [self.popover presentPopoverFromBarButtonItem:self.shareButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    barButtonItem.title = NSLocalizedString(@"Notes", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popover = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.popover = nil;
}

@end

@implementation NCLTextView

- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    point.y -= self.textContainerInset.top;
    point.x -= self.textContainerInset.left;
    
    CGFloat fraction = 1;
    NSUInteger glyphIndex = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceThroughGlyph:&fraction];
    
    NSInteger index = glyphIndex;
    if (![[self.text substringFromIndex:self.text.length - 1] isEqualToString:@"\n"]) {
        if (index == [self.text length] - 1 && roundf(fraction) > 0) {
            index++;
        }
    }
    
    NSUInteger characterIndex = [self.layoutManager characterIndexForGlyphAtIndex:index];
    UITextPosition *pos = [self positionFromPosition:self.beginningOfDocument offset:characterIndex];
    return pos;
}

@end
