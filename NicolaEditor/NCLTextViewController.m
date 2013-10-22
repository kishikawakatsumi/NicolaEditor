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
#import <SVProgressHUD/SVProgressHUD.h>
#import <NLCoreData/NLCoreData.h>
//#import <Evernote-SDK-iOS/EvernoteSDK.h>
#import <DropboxSDK/DropboxSDK.h>

@import MobileCoreServices;
@import ObjectiveC;

// UIKeyboardImpl
static NSString *NKpUsnTSGEypVViLAF8r;
// supportsSplit
static NSString *m4RUtJ6WRZjaZSsAgy23;
// UIKeyboardCandidateInlineFloatingView
static NSString *pVMFNL8kttj7sP5jkXmW;
// setFrame:
static NSString *ag2hWVYaGi9H7hDQEtMV;
// _UICompatibilityTextView:
static NSString *nuAcYW37RZfT9A3gNRm3;

static void swizzleClassMethod(NSString *className, NSString *original, NSString *replacement)
{
    Class c = NSClassFromString(className);
    SEL orig = NSSelectorFromString(original);
    SEL rep = NSSelectorFromString(replacement);
    Method originalMethod = class_getClassMethod(c, orig);
    Method replacementMethod = class_getClassMethod(c, rep);
    method_exchangeImplementations(originalMethod, replacementMethod);
}

static void swizzleInstanceMethod(NSString *className, NSString *original, NSString *replacement)
{
    Class c = NSClassFromString(className);
    SEL orig = NSSelectorFromString(original);
    SEL rep = NSSelectorFromString(replacement);
    Method originalMethod = class_getInstanceMethod(c, orig);
    Method replacementMethod = class_getInstanceMethod(c, rep);
    method_exchangeImplementations(originalMethod, replacementMethod);
}

static void _addMethod(Class c, NSString *selector, id block, NSString *sig)
{
    SEL sel = NSSelectorFromString(selector);
    IMP imp = imp_implementationWithBlock(block);
    class_addMethod(c, sel, imp, sig.UTF8String);
}

static void addClassMethod(NSString *className, NSString *selector, id block, NSString *signature)
{
    Class metaClass = objc_getMetaClass([className UTF8String]);
    _addMethod(metaClass, selector, block, signature);
}

static void addInstanceMethod(NSString *className, NSString *selector, id block, NSString *signature)
{
    Class clazz = NSClassFromString(className);
    _addMethod(clazz, selector, block, signature);
}

@interface NCLTextViewController () <UITextViewDelegate, UIDocumentInteractionControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, DBRestClientDelegate>

@property (nonatomic) UIBarButtonItem *addButton;
@property (nonatomic) UIBarButtonItem *shareButton;
@property (nonatomic) UIBarButtonItem *actionButton;
@property (nonatomic) UIBarButtonItem *cloudUploadButton;

@property (nonatomic) UITextView *textView;
@property (nonatomic) NCLKeyboardView *inputView;
@property (nonatomic) NCLKeyboardAccessoryView *inputAccessoryView;

@property (nonatomic) UIAlertView *alertView;

@property (nonatomic) NSString *previousKeyboardInputMethod;
@property (nonatomic) BOOL wasTextViewEditing;

@property (nonatomic) UIEdgeInsets textViewContentInset;
@property (nonatomic) UIEdgeInsets textViewScrollIndicatorInsets;

@property (nonatomic) DBRestClient *restClient;

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
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        if ([UINavigationBar instancesRespondToSelector:@selector(setShadowImage:)]) {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg"] forBarMetrics:UIBarMetricsDefault];
            [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"shadow"]];
        } else {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg_with_shadow"] forBarMetrics:UIBarMetricsDefault];
        }
    }
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
        {
            NSString *className = pVMFNL8kttj7sP5jkXmW;
            NSString *original = ag2hWVYaGi9H7hDQEtMV;
            NSString *replacement = [NSString stringWithFormat:@"__%@", ag2hWVYaGi9H7hDQEtMV];
           
            void (^block)(id, CGRect) = ^(id s, CGRect frame)
            {
                UIView *view = self.inputAccessoryView.superview;
                if (view) {
                    if (CGRectGetMaxY([self.textView convertRect:frame toView:view]) > 0.0f) {
                        CGRect rect = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];
                        frame.origin.y = rect.origin.y - CGRectGetHeight(frame);
                    }
                }
                
                [s __setFrame:frame];
            };
            
            addInstanceMethod(className, replacement, block, @"v@:*");
            swizzleInstanceMethod(className, original, replacement);
        }
        {
            BOOL (^block)(id, UIDocumentInteractionController *, SEL) = ^(id s, UIDocumentInteractionController *controller, SEL action)
            {
                if (action == @selector(copy:)) {
                    return YES;
                }
                return NO;
            };
            
            addInstanceMethod(NSStringFromClass(self.class), @"documentInteractionController:canPerformAction:", block, @"c@:@:");
        }
        {
            BOOL (^block)(id, UIDocumentInteractionController *, SEL) = ^(id s, UIDocumentInteractionController *controller, SEL action)
            {
                if (action == @selector(copy:)) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = self.note.content;
                    return YES;
                }
                
                return NO;
            };
            
            addInstanceMethod(NSStringFromClass(self.class), @"documentInteractionController:performAction:", block, @"c@:@:");
        }
    }
}

- (void)setupUI
{
    UITextView *textView;
    UIBarButtonItem *addButton;
    UIBarButtonItem *shareButton;
    UIBarButtonItem *actionButton;
    UIBarButtonItem *cloudUploadButton;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        
        UIButton *addButtonView = [self customButtonWithImage:[UIImage imageNamed:@"add"]];
        addButtonView.exclusiveTouch = YES;
        [addButtonView addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
        addButton = [[UIBarButtonItem alloc] initWithCustomView:addButtonView];
        
        UIButton *shareButtonView = [self customButtonWithImage:[UIImage imageNamed:@"share"]];
        shareButtonView.exclusiveTouch = YES;
        [shareButtonView addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        shareButton = [[UIBarButtonItem alloc] initWithCustomView:shareButtonView];
        
        UIButton *actionButtonView = [self customButtonWithImage:[UIImage imageNamed:@"action"]];
        actionButtonView.exclusiveTouch = YES;
        [actionButtonView addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        actionButton = [[UIBarButtonItem alloc] initWithCustomView:actionButtonView];
        
        UIButton *cloudUploadButtonView = [self customButtonWithImage:[UIImage imageNamed:@"cloud_upload"]];
        cloudUploadButtonView.exclusiveTouch = YES;
        [cloudUploadButtonView addTarget:self action:@selector(cloudUpload:) forControlEvents:UIControlEventTouchUpInside];
        cloudUploadButton = [[UIBarButtonItem alloc] initWithCustomView:cloudUploadButtonView];
    } else {
        textView = [[NSClassFromString(nuAcYW37RZfT9A3gNRm3) alloc] initWithFrame:self.view.bounds];
        
        addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
        shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
        actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(action:)];
        cloudUploadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cloud_upload"] style:UIBarButtonItemStylePlain target:self action:@selector(cloudUpload:)];
    }
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.delegate = self;
    textView.userInteractionEnabled = NO;
    [self.view addSubview:textView];
    self.textView = textView;
    
    addButton.enabled = YES;
    shareButton.enabled = NO;
    actionButton.enabled = NO;
    cloudUploadButton.enabled = NO;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
        self.navigationItem.rightBarButtonItems = @[addButton, actionButton, cloudUploadButton];
    } else {
        self.navigationItem.rightBarButtonItems = @[addButton, shareButton, actionButton, cloudUploadButton];
    }
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
    
    NCLKeyboardAccessoryView *inputAccessoryView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardAccessoryView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    inputAccessoryView.delegate = self;
    self.textView.inputAccessoryView = inputAccessoryView;
    self.inputAccessoryView = inputAccessoryView;
}

- (void)setupNotifications
{
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
    
    NSURL *fileURL = [self saveNoteWithFilename:nil];
    
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
    
    DBSession *sharedSession = [DBSession sharedSession];
//    if (sharedSession.isLinked) {
//        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                  delegate:self
//                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
//                                    destructiveButtonTitle:nil
//                                         otherButtonTitles:NSLocalizedString(@"Send to Evernote", nil), NSLocalizedString(@"Save to Dropbox", nil), nil];
//    } else {
//        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                  delegate:self
//                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
//                                    destructiveButtonTitle:nil
//                                         otherButtonTitles:NSLocalizedString(@"Send to Evernote", nil), NSLocalizedString(@"Login to Dropbox", nil), nil];
//    }
    if (sharedSession.isLinked) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Save to Dropbox", nil), nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Login to Dropbox", nil), nil];
    }
    
    [[NCLPopoverManager sharedManager] presentActionSheet:actionSheet fromBarButtonItem:self.cloudUploadButton];
}

- (void)sendToEvernote:(NCLNote *)note
{
//    EvernoteSession *session = [EvernoteSession sharedSession];
//    if (session.isAuthenticated) {
//        NSString *title = note.title;
//        NSString *content = note.content;
//        
//        NSMutableString *contentBody = [[NSMutableString alloc] init];
//        [content enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
//            [contentBody appendFormat:@"%@<br/>", line];
//        }];
//        
//        NSArray *tagNames = @[];
//        [self evernoteCreateNote:title image:nil contentBody:contentBody tagNames:tagNames];
//    } else {
//        [self authenticateEvernote];
//    }
}

- (void)evernoteCreateNote:(NSString *)title image:(UIImage *)image contentBody:(NSString *)contentBody tagNames:(NSArray *)tagNames
{
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//    
//    NSMutableString *content = [[NSMutableString alloc] init];
//    [content setString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
//    [content appendString:@"<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"];
//    [content appendString:@"<en-note>"];
//    [content appendString:contentBody];
//    [content appendString:@"</en-note>"];
//    
//    EDAMNoteAttributes *noteAttributes = [[EDAMNoteAttributes alloc] init];
//    EDAMNote *note = [[EDAMNote alloc] init];
//    note.title = title;
//    note.content = content;
////    note.tagNames = tagNames.mutableCopy;
//    note.attributes = noteAttributes;
//    note.created = (long long)[[NSDate date] timeIntervalSince1970] * 1000;
//    
//    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
//    [noteStore createNote:note success:^(EDAMNote *note) {
//        [SVProgressHUD dismiss];
//        [SVProgressHUD showSuccessWithStatus:nil];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//        [SVProgressHUD showErrorWithStatus:nil];
//    }];
}

- (void)authenticateEvernote
{
//    EvernoteSession *session = [EvernoteSession sharedSession];
//    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
//        if (error) {
//            if (error.code == EvernoteSDKErrorCode_USER_CANCELLED) {
//                return;
//            }
//            
//            [self presentError:error message:nil];
//            return;
//        }
//        if (!session.isAuthenticated) {
//            [self presentError:nil message:NSLocalizedString(@"Session not authenticated", nil)];
//            return;
//        }
//        
//        EvernoteUserStore *userStore = [EvernoteUserStore userStore];
//        [userStore getUserWithSuccess:^(EDAMUser *user) {
//            [self sendToEvernote:nil];
//        } failure:^(NSError *error) {
//            [self presentError:error message:nil];
//        }];
//    }];
}

#pragma mark -

- (void)saveToDropbox:(NCLNote *)note
{
    DBSession *session = [DBSession sharedSession];
    if (!session.isLinked) {
        [session linkFromController:self];
    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        NSURL *fileURL = [self saveNoteWithFilename:self.note.title];
        NSString *localPath = fileURL.path;
        NSString *filename = fileURL.lastPathComponent;
        NSString *destDir = @"/";
        [[self restClient] uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
    }
}

- (DBRestClient *)restClient
{
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    
    return _restClient;
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showSuccessWithStatus:nil];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:nil];
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
    [[NCLPopoverManager sharedManager] dismissPopoversWithoutAnimation];
    
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
    self.alertView = nil;
    
    self.wasTextViewEditing = self.textView.isFirstResponder;
    [self.textView endEditing:YES];
}

#pragma mark -

- (void)fontDidChange:(NSNotification *)notification
{
    [self applyFontSettings];
}

#pragma mark -

- (void)accessoryView:(NCLKeyboardAccessoryView *)accessoryView keyboardTypeDidChange:(NSInteger)keyboardType
{
    if (keyboardType == NCLKeyboardTypeNICOLA) {
        [self setupInputView];
    } else {
        self.previousKeyboardInputMethod = self.inputView.keyboardInputMethod;
        self.textView.inputView = nil;
    }
    
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
        [self sendToEvernote:self.note];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Login to Dropbox", nil)]) {
        [[DBSession sharedSession] linkFromController:self];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Save to Dropbox", nil)]) {
        [self saveToDropbox:self.note];
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

