//
//  NCLServerProfileViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2014/05/12.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "NCLServerProfileViewController.h"
#import "NCLConstants.h"
#import "ProfileSaverFetcher.h"
#import "RFBSecurityNone.h"
#import "BDHost.h"
#import "ServerProfile.h"
#import "ServerProfile+Probe.h"
#import "UIViewController+Spinner.h"

@interface NCLServerProfileViewController () <UITextFieldDelegate>

@property (nonatomic) BOOL fieldChanged;
@property (nonatomic) BOOL successfulSecurityProbe;
@property (nonatomic) BOOL successfulAuthProbe;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) UITextField *activeTextField;

@property (nonatomic, weak) IBOutlet UITextField *ServerAddressField;
@property (nonatomic, weak) IBOutlet UITextField *PortNumberField;
@property (nonatomic, weak) IBOutlet UITextField *UsernameField;
@property (nonatomic, weak) IBOutlet UITextField *PasswordField;
@property (nonatomic, weak) IBOutlet UITextField *ServerNameField;
@property (nonatomic, weak) IBOutlet UISwitch *ard35CompatSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *macAuthSwitch;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *ConnectBtn;

@property (nonatomic, weak) IBOutlet UINavigationItem *serverProfileDetailsNavigationBar;

@end

@implementation NCLServerProfileViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    _serverProfile =  [[ServerProfile alloc] init];
    _successfulAuthProbe = NO;
    _successfulSecurityProbe = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self registerTapGestureForKBDismiss];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIView *contentView = self.scrollView.subviews.firstObject;
    self.scrollView.contentSize = contentView.frame.size;
    
    if (!self.savedURL) {
		[self disableUsernameFields];
		[self disableMacARDSwitches];
		[self disableConnectButton];
		self.serverProfileDetailsNavigationBar.title = NSLocalizedString(@"Add Server", nil);
        
        if (self.serverProfile.address.length > 0 && self.serverProfile.port > 0) {
            [self textFieldSetupFromProfile:self.serverProfile];
            [self checkAddressPortAndProbeServerProfile:self.serverProfile];
        }
	} else {
		self.serverProfileDetailsNavigationBar.title = NSLocalizedString(@"Edit Server", nil);
		[self textFieldSetupFromProfile:self.serverProfile];
	}
}

#pragma mark -

- (void)textFieldSetupFromProfile:(ServerProfile *)profile
{
    if (profile.username.length > 0) {
        self.UsernameField.text = profile.username;
    }
    if (profile.password.length > 0) {
        self.PasswordField.text = profile.password;
    }
    if (profile.serverName.length > 0) {
        self.ServerNameField.text = profile.serverName;
    }
    if (profile.address.length > 0) {
        self.ServerAddressField.text = profile.address;
    }
    if (profile.ard35Compatibility) {
        self.ard35CompatSwitch.on = profile.ard35Compatibility;
    }
    if (profile.macAuthentication) {
        self.macAuthSwitch.on = profile.macAuthentication;
    }
}

- (void)saveProfileButtonClicked
{
    [self startSpinnerWithWaitText:NSLocalizedString(@"Saving...", nil)];
    
    __weak NCLServerProfileViewController *blockSafeSelf = self;
    dispatch_queue_t saveQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(saveQueue, ^ {
        NSError *error = nil;
        BOOL saved = [ProfileSaverFetcher saveServerProfile:blockSafeSelf.serverProfile
                                                      ToURL:self.savedURL
                                                      Error:&error];
        [blockSafeSelf stopSpinner];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!saved || error) {
                if ([error code] == FileDuplicateError) {
                    [blockSafeSelf handleDisplayErrors:[error localizedDescription]];
                } else {
                    [blockSafeSelf handleDisplayErrors:NSLocalizedString(@"Error encountered during profile save.  Refer to Logs", nil)];
                }
                DLogErr(@"Error: failed to save details into profile file: %@", error.localizedDescription);
                return;
            }
            
            if (blockSafeSelf.delegate) {
                [blockSafeSelf.delegate serverProfileViewControllerSaveSuccessful:blockSafeSelf];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NCLVNCServerWillConnectNodification object:blockSafeSelf userInfo:@{NCLVNCServerProfileKey: blockSafeSelf.serverProfile}];
        });
    });
}

#pragma mark -

- (IBAction)saveProfileButtonPressed:(id)sender
{
    [self saveProfileButtonClicked];
}

#pragma mark -

- (IBAction)fieldChanged:(id)sender
{
    [self captureFieldChanged];
}

- (IBAction)serverAddressEditingDidEnd:(id)sender
{
    [self captureAddressEditingEnd:sender];
}

- (IBAction)portEditingDidEnd:(id)sender
{
    [self capturePortEditingEnd:sender];
}

- (IBAction)serverNameEditingDidEnd:(id)sender
{
    [self captureNameEditingEnd:sender];
}

- (IBAction)usernameFieldEditingDidEnd:(id)sender
{
    [self captureUsernameEditingEnd:sender];
}

- (IBAction)passwordFieldEditingDidEnd:(id)sender
{
    [self capturePasswordEditingEnd:sender];
}

- (IBAction)ardSwitchTouchUpInside:(id)sender
{
    [self captureARDSwitch];
}

- (IBAction)macAuthSwitchTouchUpInside:(id)sender
{
    [self captureMacAuthSwitch:sender];
}

#pragma mark -

- (BOOL)zeroLengthAfterTrimmingWhiteSpace:(NSString *)text
{
	NSString *temp = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if (temp.length == 0) {
		return YES;
    }
	return NO;
}

#pragma mark - Error Handling

- (void)handleDisplayErrors:(NSString *)errorText
{
	if (errorText && errorText.length > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorText delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
	}
}

#pragma mark -

- (void)captureFieldChanged
{
	if (!self.fieldChanged) {
		self.fieldChanged = YES;
    }
}

- (void)captureAddressEditingEnd:(UITextField *)sender
{
	if (self.fieldChanged && ![self zeroLengthAfterTrimmingWhiteSpace:sender.text] && ![self zeroLengthAfterTrimmingWhiteSpace:self.PortNumberField.text]) {
		self.fieldChanged = NO;
		
		self.serverProfile.address = sender.text;
		self.serverProfile.port = [self.PortNumberField.text intValue];
		self.successfulSecurityProbe = NO;
		[self checkAddressPortAndProbeServerProfile:self.serverProfile];
	}
}

- (void)capturePortEditingEnd:(UITextField *)sender
{
	if (self.fieldChanged && ![self zeroLengthAfterTrimmingWhiteSpace:sender.text] && ![self zeroLengthAfterTrimmingWhiteSpace:self.ServerAddressField.text]) {
		self.fieldChanged = NO;
		
		self.serverProfile.address = self.ServerAddressField.text;
		self.serverProfile.port = [sender.text intValue];
		self.successfulSecurityProbe = NO;
		[self checkAddressPortAndProbeServerProfile:self.serverProfile];
	}
}

- (void)captureNameEditingEnd:(UITextField *)sender
{
	if (![self zeroLengthAfterTrimmingWhiteSpace:sender.text]) {
		self.serverProfile.serverName = self.ServerNameField.text;
    }
}

- (void)captureUsernameEditingEnd:(UITextField *)sender
{
	if (![self zeroLengthAfterTrimmingWhiteSpace:sender.text]) {
		self.serverProfile.username = self.UsernameField.text;
    }
	
	if (self.serverProfile.macAuthentication && self.PasswordField.text.length == 0) {
		return;
    }
	
	if (self.fieldChanged && self.successfulSecurityProbe) {
		self.fieldChanged = NO;
		
		self.successfulAuthProbe = NO;
		[self checkUsernamePwdAndProbeServerProfile:self.serverProfile];
	}
}

- (void)capturePasswordEditingEnd:(UITextField *)sender
{
	if (![self zeroLengthAfterTrimmingWhiteSpace:sender.text]) {
		self.serverProfile.password = self.PasswordField.text;
    }
	
	if (self.serverProfile.macAuthentication && self.UsernameField.text.length == 0) {
		return;
    }
	
	if (self.successfulSecurityProbe) {
		self.fieldChanged = NO;
		
		self.successfulAuthProbe = NO;
		[self checkUsernamePwdAndProbeServerProfile:self.serverProfile];
	}
}

- (void)captureARDSwitch
{
	self.serverProfile.ard35Compatibility = self.ard35CompatSwitch.on;
}

- (void)captureMacAuthSwitch:(UISwitch *)sender
{
    DLog(@"macAuth: %i", sender.on);
	self.serverProfile.macAuthentication = sender.on;
    if (self.serverProfile.macAuthentication) {
        [self enableUsernameFields];
    } else {
        [self disableUsernameFields];
    }
}

#pragma mark -

- (void)disableUsernameFields
{
	self.UsernameField.enabled = NO;
    self.UsernameField.alpha = 0.5;
}

- (void)enableUsernameFields
{
	self.UsernameField.enabled = YES;
    self.UsernameField.alpha = 1.0;
}

- (void)enableConnectButton
{
	self.ConnectBtn.enabled = YES;
}

- (void)disableConnectButton
{
	self.ConnectBtn.enabled = NO;
}

- (void)disableMacARDSwitches
{
	self.macAuthSwitch.enabled = NO;
	self.ard35CompatSwitch.enabled = NO;
}

- (void)enableMacARDSwitches
{
	self.macAuthSwitch.enabled = YES;
	self.ard35CompatSwitch.enabled = YES;
}

#pragma mark -

- (void)probe
{
    [self startSpinnerWithWaitText:NSLocalizedString(@"Probing Server...", nil)];
    
    __weak NCLServerProfileViewController *blockSafeSelf = self;
    __block NSDictionary *probeResults;
    __block NSError *error = nil;
    dispatch_queue_t probeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(probeQueue, ^{
        if (!blockSafeSelf.successfulSecurityProbe) {
            probeResults = [ServerProfile probeServerProfile:blockSafeSelf.serverProfile
                                                   ProbeType:ProbeSecurity
                                                       Error:&error];
        } else if (!blockSafeSelf.successfulAuthProbe) {
            probeResults = [ServerProfile probeServerProfile:blockSafeSelf.serverProfile
                                                   ProbeType:ProbeAuth
                                                       Error:&error];
        }
        
		dispatch_async(dispatch_get_main_queue(), ^{
			[blockSafeSelf stopSpinner];
            
            if (!probeResults || !(probeResults.count == ProbeResultFieldCount)) {
                NSString *header = NSLocalizedString(@"Connection Error: ", nil);
                [blockSafeSelf handleDisplayErrors:[NSString stringWithFormat:@"%@ %@", header, error.localizedDescription]];
                DLogErr(@"Error: Probe problem - %@", [error localizedDescription]);
                return;
            }
            
            ServerProfile *probeProfile = [probeResults objectForKey:ProbeResultKey_ServerProfile];
            if (!probeProfile) {
                [blockSafeSelf handleDisplayErrors:NSLocalizedString(@"Could not read probe results for server details", nil)];
                DLogErr(@"Probe profile read error from probe results, %@", probeProfile);
                return;
            }
            blockSafeSelf.serverProfile = probeProfile;
            
            ProbeType probeType = [[probeResults objectForKey:ProbeResultKey_Type] unsignedIntValue];
            if (probeType != ProbeSecurity && probeType != ProbeAuth) {
                [blockSafeSelf handleDisplayErrors:NSLocalizedString(@"Could not read probe results for probe type", nil)];
                DLogErr(@"Probe type read error from probe results, %i", probeType);
                return;
            }
            
            if (blockSafeSelf.serverProfile.serverName.length > 0) {
                blockSafeSelf.ServerNameField.text = self.serverProfile.serverName;
            }
            
            if (probeType == ProbeSecurity) {
                VersionMsg *serverVersion = [probeResults objectForKey:ProbeResultKey_SVer];
                if (!serverVersion) {
                    [blockSafeSelf handleDisplayErrors:NSLocalizedString(@"Could not determine server protocol version", nil)];
                    DLogErr(@"No server version from probe results");
                    return;
                }
                NSArray *securityTypesList = [probeResults objectForKey:ProbeResultKey_SecTypes];
                if (!securityTypesList || securityTypesList.count <= 0) {
                    [blockSafeSelf handleDisplayErrors:NSLocalizedString(@"Could not read probe results for probe type", nil)];
                    DLogErr(@"Security type read error from probe results, %@", securityTypesList);
                    return;
                }
                
                [blockSafeSelf disableMacARDSwitches];
                if ([serverVersion isAppleRemoteDesktop]) {
                    [blockSafeSelf enableMacARDSwitches];
                }
                
                if ([securityTypesList containsObject:[NSNumber numberWithUnsignedChar:[RFBSecurityNone type]]]) {
                    [blockSafeSelf enableConnectButton];
                }
                
                blockSafeSelf.successfulSecurityProbe = YES;
            } else if (probeType == ProbeAuth) {
                blockSafeSelf.successfulAuthProbe = YES;
                [blockSafeSelf enableConnectButton];
            }
            
            if (error) {
                NSString *header = NSLocalizedString(@"Warning: ", nil);
                [blockSafeSelf handleDisplayErrors:[NSString stringWithFormat:@"%@ %@", header, error.localizedDescription]];
            }
		});
    });
}

#pragma mark - 

- (void)checkAddressPortAndProbeServerProfile:(ServerProfile *)serverProfile
{
    NSString *addressCheck = [BDHost addressForHostname:serverProfile.address];
    if (addressCheck) {
        [self probe];
    } else {
        [self handleDisplayErrors:NSLocalizedString(@"Invalid IP address supplied, cannot start checks", nil)];
        DLogWar(@"Invalid IP address supplied, cannot start probe");
    }
}

- (void)checkUsernamePwdAndProbeServerProfile:(ServerProfile *)serverProfile
{
	if (self.serverProfile.macAuthentication) {
		if (self.serverProfile.username.length == 0 || self.serverProfile.username.length == 0) {
			[self handleDisplayErrors:NSLocalizedString(@"Username cannot be blank", nil)];
			return;
		}
		if (self.serverProfile.password.length == 0 || self.serverProfile.password.length == 0) {
			[self handleDisplayErrors:NSLocalizedString(@"Password cannot be blank", nil)];
			return;
		}
	}
    
	[self probe];
}

#pragma mark -

- (void)registerTapGestureForKBDismiss
{
	UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce)];
	tapOnce.cancelsTouchesInView = NO; //Allow other touches to pass thru to view
	[self.scrollView addGestureRecognizer:tapOnce];
}

- (void)tapOnce
{
	[self.view endEditing:YES];
}

#pragma mark -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

@end
