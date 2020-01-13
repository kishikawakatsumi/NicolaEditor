//
//  NCLTextViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLTextViewController.h"
#import "NCLSettingsViewController.h"
#import "NCLPhysicalKeyboardManager.h"
#import "NCLPopoverManager.h"
#import "NCLKeyboardView.h"
#import "NCLKeyboardAccessoryView.h"
#import "NCLNote.h"
#import "NCLConstants.h"
#import "UIFont+Helper.h"
#import "NCLRuntimeUtils.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <NLCoreData/NLCoreData.h>
#import <EvernoteSDK/EvernoteSDK.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@import MobileCoreServices;
@import ObjectiveC;

// UIKeyboardImpl
static NSString *NKpUsnTSGEypVViLAF8r;
// + (BOOL)supportsSplit
static NSString *m4RUtJ6WRZjaZSsAgy23;
// UIKeyboardCandidateInlineFloatingView
static NSString *pVMFNL8kttj7sP5jkXmW;
// - (void)setFrame:
static NSString *ag2hWVYaGi9H7hDQEtMV;
// _UICompatibilityTextView
static NSString *nuAcYW37RZfT9A3gNRm3;

@interface NCLTextViewController () <UITextViewDelegate, UIDocumentInteractionControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic) UIBarButtonItem *addButton;
@property (nonatomic) UIBarButtonItem *shareButton;
@property (nonatomic) UIBarButtonItem *actionButton;
@property (nonatomic) UIBarButtonItem *cloudUploadButton;

@property (nonatomic) UITextView *textView;
@property (nonatomic) NCLKeyboardView *inputView;
@property (nonatomic) NCLKeyboardAccessoryView *inputAccessoryView;

@property (nonatomic) UIAlertView *alertView;

@property (nonatomic) NCLKeyboardType previousKeyboardType;
@property (nonatomic) BOOL wasTextViewEditing;

@property (nonatomic) UIEdgeInsets textViewContentInset;
@property (nonatomic) UIEdgeInsets textViewScrollIndicatorInsets;

@end

@implementation NCLTextViewController

+ (void)initialize
{
    NKpUsnTSGEypVViLAF8r = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"U", @"I", @"K", @"e", @"y", @"b", @"o", @"a", @"r", @"d", @"I", @"m", @"p", @"l"];
    m4RUtJ6WRZjaZSsAgy23 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", @"s", @"u", @"p", @"p", @"o", @"r", @"t", @"s", @"S", @"p", @"l", @"i", @"t"];
    pVMFNL8kttj7sP5jkXmW = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"U", @"I", @"K", @"e", @"y", @"b", @"o", @"a", @"r", @"d", @"C", @"a", @"n", @"d", @"i", @"d", @"a", @"t", @"e", @"I", @"n", @"l", @"i", @"n", @"e", @"F", @"l", @"o", @"a", @"t", @"i", @"n", @"g", @"V", @"i", @"e", @"w"];
    ag2hWVYaGi9H7hDQEtMV = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", @"s", @"e", @"t", @"F", @"r", @"a", @"m", @"e", @":"];
    nuAcYW37RZfT9A3gNRm3 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"_", @"U", @"I", @"C", @"o", @"m", @"p", @"a", @"t", @"i", @"b", @"i", @"l", @"i", @"t", @"y", @"T", @"e", @"x", @"t", @"V", @"i", @"e", @"w"];
}

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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.inputAccessoryView.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.inputAccessoryView.hidden = NO;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.inputView invalidateIntrinsicContentSize];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

#pragma mark -

+ (BOOL)__supportsSplit
{
    return [self __supportsSplit];
}

- (void)__setFrame:(CGRect)frame
{
    [self __setFrame:frame];
}

- (void)prepareForLegacy
{
    NSString *className = NKpUsnTSGEypVViLAF8r;
    NSString *original = m4RUtJ6WRZjaZSsAgy23;
    NSString *replacement = [NSString stringWithFormat:@"__%@",  m4RUtJ6WRZjaZSsAgy23];

    BOOL (^block)(id) = ^(id s) {
        return NO;
    };

    addClassMethod(className, replacement, block, @"c@:");
    swizzleClassMethod(className, original, replacement);
}

- (void)setupUI
{
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(action:)];
    UIBarButtonItem *cloudUploadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cloud_upload"] style:UIBarButtonItemStylePlain target:self action:@selector(cloudUpload:)];
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.delegate = self;
    textView.userInteractionEnabled = NO;
    [self.view addSubview:textView];
    self.textView = textView;
    
    addButton.enabled = YES;
    shareButton.enabled = NO;
    actionButton.enabled = NO;
    cloudUploadButton.enabled = NO;

    self.navigationItem.rightBarButtonItems = @[addButton, shareButton, actionButton, cloudUploadButton];
    self.addButton = addButton;
    self.shareButton = shareButton;
    self.actionButton = actionButton;
    self.cloudUploadButton = cloudUploadButton;
}

- (UIButton *)customButtonWithImage:(UIImage *)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.showsTouchWhenHighlighted = YES;
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    
    CGRect frame = button.frame;
    frame.size.width = 44.0;
    button.frame = frame;
    
    return button;
}

- (void)setupInputView
{
    if (!self.inputView) {
        NCLKeyboardView *inputView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        inputView.delegate = self;
        inputView.textView = self.textView;
        self.inputView = inputView;
    }
    if (!self.inputAccessoryView) {
        NCLKeyboardAccessoryView *inputAccessoryView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardAccessoryView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        inputAccessoryView.keyboardType = self.previousKeyboardType;
        inputAccessoryView.delegate = self;
        self.inputAccessoryView = inputAccessoryView;
    }

    NCLPhysicalKeyboardManager *keyboardManager = [NCLPhysicalKeyboardManager sharedManager];
    if (self.inputAccessoryView.keyboardType == NCLKeyboardTypeNICOLA) {
        if (keyboardManager.isPhysicalKeyboardAttached) {
            self.textView.inputView = nil;
        } else {
            self.textView.inputView = self.inputView;
        }
        self.textView.inputAccessoryView = self.inputAccessoryView;
    } else {
        self.textView.inputView = nil;
        self.textView.inputAccessoryView = nil;
    }
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(physicalKeyboardAvailabilityChanged:) name:NCLPhysicalKeyboardAvailabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontDidChange:) name:NCLSettingsFontDidChangeNodification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
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
    if (self.masterPopoverController.isPopoverVisible) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)updateUI
{
    self.title = self.note.title;
    self.shareButton.enabled = self.actionButton.enabled = self.cloudUploadButton.enabled = self.note.content.length > 0;
}

- (void)updateText
{
    self.textView.text = self.note.content;
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
    
    if (!font) {
        return;
    }
    if (!boldFont) {
        boldFont = font;
    }
    
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
    if ([[NCLPopoverManager sharedManager] isPopoverVisible]) {
        [[NCLPopoverManager sharedManager] dismissPopovers];
        return;
    }
    
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext mainContext];
    
    NCLNote *note = [NCLNote insertInContext:managedObjectContext];
    self.note = note;
    
    [managedObjectContext saveNested];
}

- (void)share:(id)sender
{
    if ([[NCLPopoverManager sharedManager] isPopoverVisible]) {
        [[NCLPopoverManager sharedManager] dismissPopovers];
        return;
    }
    
    NSArray *activityItems = @[self.note.content];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    [[NCLPopoverManager sharedManager] presentPopover:popoverController fromBarButtonItem:self.shareButton];
}

- (void)action:(id)sender
{
    if ([[NCLPopoverManager sharedManager] isPopoverVisible]) {
        [[NCLPopoverManager sharedManager] dismissPopovers];
        return;
    }
    
    NSURL *fileURL = [self saveNoteWithFilename:self.note.title];
    
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    interactionController.UTI = (__bridge NSString *)kUTTypeUTF8PlainText;
    interactionController.delegate = self;
    
    [[NCLPopoverManager sharedManager] presentInteractionController:interactionController fromBarButtonItem:self.actionButton];
}

- (void)cloudUpload:(id)sender
{
    if ([[NCLPopoverManager sharedManager] isPopoverVisible]) {
        [[NCLPopoverManager sharedManager] dismissPopovers];
        return;
    }
    
    UIActionSheet *actionSheet;
    
    if (DBClientsManager.authorizedClient) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Send to Evernote", nil), NSLocalizedString(@"Save to Dropbox", nil), nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Send to Evernote", nil), NSLocalizedString(@"Login to Dropbox", nil), nil];
    }

    [[NCLPopoverManager sharedManager] presentActionSheet:actionSheet fromBarButtonItem:self.cloudUploadButton];
}

- (void)sendToEvernote:(NCLNote *)note
{
    ENSession *session = [ENSession sharedSession];
    if (session.isAuthenticated) {
        NSString *title = note.title;
        NSString *content = note.content;
        
        NSMutableString *contentBody = [[NSMutableString alloc] init];
        [content enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            [contentBody appendFormat:@"%@<br/>", line];
        }];
        
        NSArray *tagNames = @[];
        [self evernoteCreateNote:title image:nil contentBody:contentBody tagNames:tagNames];
    } else {
        [self authenticateEvernote];
    }
}

- (void)evernoteCreateNote:(NSString *)title image:(UIImage *)image contentBody:(NSString *)contentBody tagNames:(NSArray *)tagNames
{
    [SVProgressHUD show];
    
    NSMutableString *content = [[NSMutableString alloc] init];
    [content setString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
    [content appendString:@"<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"];
    [content appendString:@"<en-note>"];
    [content appendString:contentBody];
    [content appendString:@"</en-note>"];
    
    EDAMNoteAttributes *noteAttributes = [[EDAMNoteAttributes alloc] init];
    EDAMNote *note = [[EDAMNote alloc] init];
    note.title = title;
    note.content = content;
    note.attributes = noteAttributes;
    note.created = @([[NSDate date] timeIntervalSince1970] * 1000);
    
    ENNoteStoreClient *noteStore = [[ENSession sharedSession] primaryNoteStore];
    [noteStore createNote:note completion:^(EDAMNote * _Nullable note, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:nil];
        } else {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:nil];
        }
    }];
}

- (void)authenticateEvernote
{
    ENSession *session = [ENSession sharedSession];
    [session authenticateWithViewController:self preferRegistration:NO completion:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == ENErrorCodeCancelled) {
                return;
            }
            
            [self presentError:error message:nil];
            return;
        }
        if (!session.isAuthenticated) {
            [self presentError:nil message:NSLocalizedString(@"Session not authenticated", nil)];
            return;
        }
        
        ENUserStoreClient *userStore = [session userStore];
        [userStore fetchUserWithCompletion:^(EDAMUser * _Nullable user, NSError * _Nullable error) {
            if (error) {
                [self presentError:error message:nil];
            } else {
                [self sendToEvernote:nil];
            }
        }];
    }];
}

#pragma mark -

- (void)saveToDropbox:(NCLNote *)note
{
    if (DBClientsManager.authorizedClient) {
        [SVProgressHUD show];

        NSURL *fileURL = [self saveNoteWithFilename:self.note.title];
        NSString *localPath = fileURL.path;
        NSString *remotePath = [NSString stringWithFormat:@"/%@", fileURL.lastPathComponent];
        [[DBClientsManager.authorizedClient.filesRoutes uploadUrl:remotePath inputUrl:localPath] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
            if (result) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:nil];

            } else {
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:nil];
            }
        }];

    } else {
        [DBClientsManager authorizeFromController:UIApplication.sharedApplication controller:self openURL:^(NSURL * _Nonnull url) {
            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
        }];
    }
}

#pragma mark -

- (NSURL *)saveNoteWithFilename:(NSString *)filename
{
    NSString *identifier = self.note.identifier;
    NSString *content = self.note.content;
    
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    if (!filename) {
        filename = identifier;
    }
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:filename] URLByAppendingPathExtension:@"txt"];
    
    [[content dataUsingEncoding:NSUTF8StringEncoding] writeToURL:fileURL atomically:YES];
    
    return fileURL;
}

#pragma mark -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self setupInputView];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.textView reloadInputViews];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.previousKeyboardType = self.inputAccessoryView.keyboardType;
    self.textView.inputView = nil;
    self.textView.inputAccessoryView = nil;
    self.inputView = nil;
    self.inputAccessoryView = nil;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
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

    [[NCLPopoverManager sharedManager] dismissPopovers];
    
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
    
    CGFloat keyboardHeight = CGRectGetHeight(keyboardFrame);
    
    UIEdgeInsets contentInset = self.textView.contentInset;
    self.textViewContentInset = contentInset;
    contentInset.bottom = keyboardHeight + 44.0;
    
    UIEdgeInsets scrollIndicatorInsets = self.textView.scrollIndicatorInsets;
    self.textViewScrollIndicatorInsets = scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = keyboardHeight;
    
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
    [[NCLPopoverManager sharedManager] dismissPopoversWithoutAnimation];
    
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
    self.alertView = nil;
    
    self.wasTextViewEditing = self.textView.isFirstResponder;
    [self.textView endEditing:YES];
}

#pragma mark -

- (void)physicalKeyboardAvailabilityChanged:(NSNotification *)notification
{
    [self accessoryView:self.inputAccessoryView keyboardTypeDidChange:self.inputAccessoryView.keyboardType];
}

- (void)fontDidChange:(NSNotification *)notification
{
    [self applyFontSettings];
}

#pragma mark -

- (void)accessoryView:(NCLKeyboardAccessoryView *)accessoryView keyboardTypeDidChange:(NSInteger)keyboardType
{
    [self setupInputView];
    [self.textView reloadInputViews];
}

- (void)accessoryViewDidComplete:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.textView endEditing:NO];
}

- (void)accessoryViewArrowUp:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.inputView cursorUp];
}

- (void)accessoryViewArrowDown:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.inputView cursorDown];
}

- (void)accessoryViewArrowLeft:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.inputView cursorLeft];
}

- (void)accessoryViewArrowRight:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.inputView cursorRight];
}

- (void)accessoryViewCut:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.textView cut:nil];
}

- (void)accessoryViewCopy:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.textView copy:nil];
}

- (void)accessoryViewPaste:(NCLKeyboardAccessoryView *)accessoryView
{
    [self.textView paste:nil];
}

#pragma mark -

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    [[NCLPopoverManager sharedManager] dismissPopoversWithoutAnimation];

    barButtonItem.title = NSLocalizedString(@"Notes", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [[NCLPopoverManager sharedManager] dismissPopoversWithoutAnimation];
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (UIInterfaceOrientation)splitViewControllerPreferredInterfaceOrientationForPresentation:(UISplitViewController *)splitViewController;
{
    return UIInterfaceOrientationLandscapeRight;
}

#pragma mark -

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    [[NCLPopoverManager sharedManager] dismissPopoversWithoutAnimation];
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    [[NCLPopoverManager sharedManager] dismissPopoversWithoutAnimation];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    [[NCLPopoverManager sharedManager] dismissPopoversWithoutAnimation];
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Send to Evernote", nil)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendToEvernote:self.note];
        });
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Login to Dropbox", nil)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [DBClientsManager authorizeFromController:UIApplication.sharedApplication controller:self openURL:^(NSURL * _Nonnull url) {
                [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
            }];
        });
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Save to Dropbox", nil)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self saveToDropbox:self.note];
        });
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[NCLPopoverManager sharedManager] dismissPopoversWithoutAnimation];
}

#pragma mark -

- (void)presentError:(NSError *)error message:(NSString *) message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *infoDictionary = bundle.localizedInfoDictionary;
        if (infoDictionary.count == 0) {
            infoDictionary = bundle.infoDictionary;
        }
        NSString *appName = infoDictionary[(id)kCFBundleNameKey];
        NSString *description;
        if (error) {
            description = [NSString stringWithFormat:@"%@: %@", message, error.localizedDescription];
        } else {
            description = message;
        }
        
        self.alertView = [[UIAlertView alloc] initWithTitle:appName message:description delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [self.alertView show];
    });
}

@end

