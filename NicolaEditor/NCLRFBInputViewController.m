//
//  NCLRFBInputViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2014/05/12.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "NCLRFBInputViewController.h"
#import "RFBInputConnManager.h"
#import "RFBPointerEvent.h"
#import "RFBKeyEvent.h"
#import "RFBInputView.h"
#import "TouchInputTracker.h"
#import "UIViewController+Spinner.h"

@interface NCLRFBInputViewController ()<KeyboardInputDelegate, RFBInputConnManagerDelegate>

@property (nonatomic) RFBInputConnManager *rfbInputConnMgr;
@property (nonatomic) TouchInputTracker *touchInputTrkr;

@property (nonatomic, weak) IBOutlet UITextView *helpTextView;

@end

@implementation NCLRFBInputViewController

- (void)dealloc
{
    [self.rfbInputConnMgr stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	((RFBInputView *)self.view).delegate = self;
    
	[self setupGestureRecognizers];
    
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
    [self.view becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
	[self stopSpinner];
	
	self.rfbInputConnMgr = nil;
	DLogInf(@"Unloading Mouse View");
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

- (void)rfbInputView:(RFBInputView *)view receivedKey:(unichar)keycode
{
    RFBKeyEvent *keyEvent = [[RFBKeyEvent alloc] initWithKeypress:keycode];
    [self.rfbInputConnMgr sendEvent:keyEvent];
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
    
    self.helpTextView.hidden = NO;
	
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
