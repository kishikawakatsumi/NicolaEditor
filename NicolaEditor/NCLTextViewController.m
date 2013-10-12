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

@property (nonatomic) UIEdgeInsets textViewContentInset;
@property (nonatomic) UIEdgeInsets textViewScrollIndicatorInsets;

@end

@implementation NCLTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
//    UIBarButtonItem *archiveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"archive"] style:UIBarButtonItemStyleBordered target:self action:@selector(archive:)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    self.navigationItem.rightBarButtonItems = @[addButton, shareButton];
    
    self.inputView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    self.inputView.delegate = self;
    self.inputView.textView = self.textView;
    
    self.textView.inputView = self.inputView;
    
    NCLKeyboardAccessoryView *accessoryView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardAccessoryView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    accessoryView.delegate = self;
    self.textView.inputAccessoryView = accessoryView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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
        self.navigationItem.title = self.note.title;
        
        self.textView.userInteractionEnabled = YES;
        
        self.textView.text = self.note.content;
        [self.textView becomeFirstResponder];
    } else {
        self.textView.userInteractionEnabled = NO;
    }
}

#pragma mark -

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    __block NSString *title = nil;
    [text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        title = line;
        *stop = YES;
    }];
    
    self.navigationItem.title = title;
    
    self.note.title = title;
    self.note.content = text;
    
    [self.note.managedObjectContext saveNested];
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
    CGFloat overlap = MAX(0.0f, CGRectGetMaxY(textViewFrame) - CGRectGetMinY(keyboardFrame));
    
    UIEdgeInsets contentInset = self.textView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.textView.scrollIndicatorInsets;
    contentInset.bottom = overlap;
    scrollIndicatorInsets.bottom = overlap;
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    self.textView.contentInset = contentInset;
    self.textView.scrollIndicatorInsets = contentInset;
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
    [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark -

- (void)accessoryViewDidComplete:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.textView resignFirstResponder];
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
