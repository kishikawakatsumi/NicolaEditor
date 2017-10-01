//
//  NCLRFBInputViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2014/05/12.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "NCLRFBInputViewController.h"
#import "NCLKeyboardView.h"
#import "NCLKeyboardAccessoryView.h"
#import "RFBInputConnManager.h"
#import "RFBPointerEvent.h"
#import "RFBKeyEvent.h"
#import "RFBInputView.h"
#import "TouchInputTracker.h"
#import "UIViewController+Spinner.h"
#import "NSString+RomajiKanaConvert.h"

#define XK_MISCELLANY
#define XK_LATIN1
#import "keysymdef.h"

static dispatch_queue_t queue;

@interface NCLRFBInputViewController () <UITextViewDelegate, RFBInputConnManagerDelegate>

@property (nonatomic) RFBInputConnManager *rfbInputConnMgr;
@property (nonatomic) TouchInputTracker *touchInputTrkr;

@property (nonatomic, weak) IBOutlet UITextView *helpTextView;

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic) UIView *inputView;
@property (nonatomic) UIView *inputAccessoryView;

@end

@implementation NCLRFBInputViewController

- (void)dealloc
{
    [self.rfbInputConnMgr stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!queue) {
        queue = dispatch_queue_create("com.kishikawakatsumi.NicolaEditor.rfb", DISPATCH_QUEUE_SERIAL);
    }
    
	[self setupGestureRecognizers];
    [self setupInputView];
    
	if (self.serverProfile) {
		self.rfbInputConnMgr = [[RFBInputConnManager alloc] initWithProfile:self.serverProfile ProtocolDelegate:self];
        [self.rfbInputConnMgr start];
    } else {
        [self displayErrorMessage:NSLocalizedString(@"No VNC server to connect to", nil)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
	[self stopSpinner];
	
	self.rfbInputConnMgr = nil;
	DLogInf(@"Unloading Mouse View");
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -

- (void)displayErrorMessage:(NSString *)errorMsg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)setupGestureRecognizers
{
	UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleFingerTap:)];
	UITapGestureRecognizer *doubleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerTap:)];
	UITapGestureRecognizer *threeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(threeFingerTap:)];
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longSingleFingerTap:)];
	UIPanGestureRecognizer *singleFingerDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singleFingerDrag:)];
	UIPanGestureRecognizer *doubleFingerDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerDrag:)];
	
	doubleFingerTap.numberOfTouchesRequired = 2;
    threeFingerTap.numberOfTouchesRequired = 3;
    longTap.minimumPressDuration = 0.4;
	singleFingerDrag.minimumNumberOfTouches = 1;
	singleFingerDrag.maximumNumberOfTouches = singleFingerDrag.minimumNumberOfTouches;
	doubleFingerDrag.minimumNumberOfTouches = 2;
	doubleFingerDrag.maximumNumberOfTouches = doubleFingerDrag.minimumNumberOfTouches;
	
	[self.view addGestureRecognizer:singleFingerTap];
	[self.view addGestureRecognizer:doubleFingerTap];
    [self.view addGestureRecognizer:threeFingerTap];
    [self.view addGestureRecognizer:longTap];
	[self.view addGestureRecognizer:singleFingerDrag];
	[self.view addGestureRecognizer:doubleFingerDrag];
}

- (void)setupInputView
{
    NCLKeyboardView *inputView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    inputView.delegate = self;
    
    self.textView.inputView = inputView;
    self.inputView = inputView;
    
    NCLKeyboardAccessoryView *inputAccessoryView = [[[UINib nibWithNibName:NSStringFromClass([NCLKeyboardAccessoryView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    inputAccessoryView.delegate = self;
    self.textView.inputAccessoryView = inputAccessoryView;
    self.inputAccessoryView = inputAccessoryView;
}

#pragma mark -

- (void)singleFingerTap:(UITapGestureRecognizer *)tapper
{
	DLog(@"singleFingerTap");
    RFBPointerEvent *tapEvent = [[RFBPointerEvent alloc] initWithDt:0.0f Dx:0.0f Dy:0.0f Sx:0.0f Sy:0.0f V:CGPointZero Button1Pressed:YES Button2Pressed:NO ScrollSensitivity:0 ButtonPresses:1];
//    BWRFBPointerEvent *tapOffEvent = [[BWRFBPointerEvent alloc] init];
    [self.rfbInputConnMgr sendEvent:tapEvent];
//    [self.rfbInputConnMgr sendEvent:tapOffEvent];
}

- (void)doubleFingerTap:(UITapGestureRecognizer *)tapper
{
	DLog(@"doubleFingerTap");
    RFBPointerEvent *tapEvent = [[RFBPointerEvent alloc] initWithDt:0.0f Dx:0.0f Dy:0.0f Sx:0.0f Sy:0.0f V:CGPointZero Button1Pressed:NO Button2Pressed:YES ScrollSensitivity:0 ButtonPresses:1];
//    BWRFBPointerEvent *tapOffEvent = [[BWRFBPointerEvent alloc] init];
    [self.rfbInputConnMgr sendEvent:tapEvent];
//    [self.rfbInputConnMgr sendEvent:tapOffEvent];
}

- (void)threeFingerTap:(UITapGestureRecognizer *)tapper
{
	DLog(@"threeFingerTap");
    RFBPointerEvent *tapEvent = [[RFBPointerEvent alloc] initWithDt:0.0f Dx:0.0f Dy:0.0f Sx:0.0f Sy:0.0f V:CGPointZero Button1Pressed:YES Button2Pressed:YES ScrollSensitivity:0 ButtonPresses:1];
//    BWRFBPointerEvent *tapOffEvent = [[BWRFBPointerEvent alloc] init];
    [self.rfbInputConnMgr sendEvent:tapEvent];
//    [self.rfbInputConnMgr sendEvent:tapOffEvent];
}

- (void)longSingleFingerTap:(UILongPressGestureRecognizer *)lpresser
{
    if (lpresser.state == UIGestureRecognizerStateBegan) {
        DLog(@"LP start");
        [self.touchInputTrkr pointerEventInitialPositionForGesture:lpresser];
    } else if (lpresser.state == UIGestureRecognizerStateChanged) {
        RFBPointerEvent *tapHoldEvent = [self.touchInputTrkr button1HoldPointerEventForGesture:lpresser];
        [self.rfbInputConnMgr sendEvent:tapHoldEvent];
    } else if (lpresser.state == UIGestureRecognizerStateEnded) {
        DLog(@"LP end");
        [self.touchInputTrkr clearStoredInitialPosition];
        RFBPointerEvent *tapHoldEndEvent = [[RFBPointerEvent alloc] init];
        [self.rfbInputConnMgr sendEvent:tapHoldEndEvent];
    }
}

- (void)singleFingerDrag:(UIPanGestureRecognizer *)panner
{
    DLog(@"singleFingerDRAG");
    RFBPointerEvent *panEvent = [self.touchInputTrkr pointerEventForPanGesture:panner];
    [self.rfbInputConnMgr sendEvent:panEvent];
}

- (void)doubleFingerDrag:(UIPanGestureRecognizer *)panner
{
	DLog(@"doubleFingerDRAG");
    RFBPointerEvent *panEvent = [self.touchInputTrkr pointerEventForPanGesture:panner];
    [self.rfbInputConnMgr sendEvent:panEvent];
}

#pragma mark

- (void)keyboardView:(NCLKeyboardView *)view inputText:(NSString *)text
{
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Zenkaku];
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    
    NSString *string;
    if ([text isEqualToString:@"\u3002"] || [text isEqualToString:@"\uFF0E"]) {
        string = @".";
    } else if ([text isEqualToString:@"\u3001"] || [text isEqualToString:@"\uFF0C"]) {
        string = @",";
    } else {
        string = [text stringKanaToRomaji];
    }
    
    for (int i = 0; i < string.length; i++) {
        unichar keycode = [string characterAtIndex:i];
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:keycode];
        dispatch_async(queue, ^{
            [self.rfbInputConnMgr sendEvent:keyEvent];
        });
    }
}

- (void)keyboardViewInputEnter:(NCLKeyboardView *)view
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Return];
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)keyboardViewInputBackspace:(NCLKeyboardView *)view
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_BackSpace];
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)keyboardViewInputShiftDown:(NCLKeyboardView *)view
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Shift_L];
    keyEvent.up = NO;
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)keyboardViewInputShiftUp:(NCLKeyboardView *)view
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Shift_L];
    keyEvent.down = NO;
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)keyboardViewInputSpace:(NCLKeyboardView *)view
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_space];
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)keyboardViewInputNextCandidate:(NCLKeyboardView *)view
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Down];
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)keyboardViewInputHideKeyboard:(NCLKeyboardView *)view
{
    [self.textView resignFirstResponder];
}

#pragma mark -

- (void)accessoryView:(NCLKeyboardAccessoryView *)accessoryView keyboardTypeDidChange:(NSInteger)keyboardType
{
    if (keyboardType == NCLKeyboardTypeNICOLA) {
        [self setupInputView];
    } else {
        self.textView.inputView = nil;
    }
    
    [self.textView reloadInputViews];
}

- (void)accessoryViewDidComplete:(NCLKeyboardAccessoryView *)accessoryView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)accessoryViewArrowUp:(NCLKeyboardAccessoryView *)accessoryView
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Up];
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)accessoryViewArrowDown:(NCLKeyboardAccessoryView *)accessoryView
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Down];
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)accessoryViewArrowLeft:(NCLKeyboardAccessoryView *)accessoryView
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Left];
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)accessoryViewArrowRight:(NCLKeyboardAccessoryView *)accessoryView
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Right];
    [self.rfbInputConnMgr sendEvent:keyEvent];
}

- (void)accessoryViewCut:(NCLKeyboardAccessoryView *)accessoryView
{
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Super_L];
        keyEvent.up = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_x];
        keyEvent.up = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_x];
        keyEvent.down = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Super_L];
        keyEvent.down = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
}

- (void)accessoryViewCopy:(NCLKeyboardAccessoryView *)accessoryView
{
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Super_L];
        keyEvent.up = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_c];
        keyEvent.up = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_c];
        keyEvent.down = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Super_L];
        keyEvent.down = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
}

- (void)accessoryViewPaste:(NCLKeyboardAccessoryView *)accessoryView
{
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Super_L];
        keyEvent.up = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_v];
        keyEvent.up = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_v];
        keyEvent.down = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
    dispatch_async(queue, ^{
        RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeysym:XK_Super_L];
        keyEvent.down = NO;
        [self.rfbInputConnMgr sendEvent:keyEvent];
    });
}

#pragma mark -

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return NO;
}

#pragma mark -

- (void)rfbInputConnManager:(RFBInputConnManager *)inputConnMgr performedAction:(ActionList)action encounteredError:(NSError *)error
{
	if (error) {
        [self stopSpinner];
        
		NSString *errorMsg = [NSLocalizedString(@"Encountered Problem: ", nil) stringByAppendingString:error.localizedDescription];
		[self displayErrorMessage:errorMsg];
        
		return;
	}
	
	switch (action) {
		case CONNECTION_START:
			[self startSpinnerWithWaitText:NSLocalizedString(@"Connecting...", nil)];
			break;
		case CONNECTION_END:
			[self stopSpinner];
            self.touchInputTrkr = [[TouchInputTracker alloc] initWithScaleFactor:[self.rfbInputConnMgr serverScaleFactor]];
			break;
		case DISCONNECTION_START:
			[self startSpinnerWithWaitText:NSLocalizedString(@"Disconnecting...", nil)];
			break;
		case DISCONNECTION_END:
            DLog(@"input conn mgr stop end reached");
            self.touchInputTrkr = nil;
			[self stopSpinner];
			break;
		case INPUT_EVENT:
			break;
		default:
			break;
	}
}

@end
