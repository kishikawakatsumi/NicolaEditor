//
//  NCLSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLSettingsViewController.h"
#import "NCLShiftKeyFunctionsSettingsViewController.h"
#import "NCLHelpViewController.h"
#import "NCLSliderPopup.h"
#import "NCLConstants.h"

@interface NCLSettingsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *fontNameLabel;

@property (nonatomic, weak) IBOutlet UITableViewCell *fontSizeCell;
@property (nonatomic, weak) IBOutlet UIStepper *fontSizeStepper;
@property (nonatomic, weak) IBOutlet UILabel *fontSizeLabel;

@property (nonatomic, weak) IBOutlet UILabel *shiftKeyBehaviorLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeShiftDurationLabel;
@property (nonatomic, weak) IBOutlet UISlider *timeShiftDurationSlider;
@property (nonatomic, weak) IBOutlet UITableViewCell *timeShiftSliderCell;

@property (nonatomic, weak) IBOutlet UITableViewCell *swapKeyCell;
@property (nonatomic, weak) IBOutlet UILabel *swapKeyLabel;
@property (nonatomic, weak) IBOutlet UISwitch *swapKeySwitch;

@property (nonatomic) NCLSliderPopup *popup;

@end

@implementation NCLSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Settings", nil);
    
    UIStepper *stepper = self.fontSizeStepper;
    [stepper removeFromSuperview];
    self.fontSizeCell.accessoryView = stepper;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        CGRect frame = self.swapKeyLabel.frame;
        frame.origin.x = 10.0f;
        frame.origin.y += 4.0f;
        frame.size.width = 200.0f;
        self.swapKeyLabel.frame = frame;
        self.swapKeyLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16.0f];
    }
    
    UISwitch *sw = self.swapKeySwitch;
    [sw removeFromSuperview];
    self.swapKeyCell.accessoryView = sw;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    double fontSize = [userDefaults doubleForKey:NCLSettingsFontSizeKey];
    self.fontSizeStepper.value = fontSize;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        CGRect frame = self.timeShiftDurationLabel.frame;
        frame.origin.x = 10.0f;
        self.timeShiftDurationLabel.frame = frame;
    }
    float timeShiftDuration = [userDefaults doubleForKey:NCLSettingsTimeShiftDurationKey];
    self.timeShiftDurationSlider.value = timeShiftDuration;
    
    self.popup = [[[UINib nibWithNibName:NSStringFromClass([NCLSliderPopup class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    self.popup.alpha = 0.0f;
    [self.view addSubview:self.popup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fontName = [userDefaults stringForKey:NCLSettingsFontNameKey];
    self.fontNameLabel.text = NSLocalizedString(fontName, nil);
    
    double fontSize = [userDefaults doubleForKey:NCLSettingsFontSizeKey];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%d pt", (NSInteger)fontSize];
    
    NSString *shiftKeyBehavior = [userDefaults stringForKey:NCLSettingsShiftKeyBehaviorKey];
    self.shiftKeyBehaviorLabel.text = NSLocalizedString(shiftKeyBehavior, nil);
    
    BOOL isTimeShift = [shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorTimeShift] || [shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorContinuityShift];
    self.timeShiftDurationLabel.textColor = isTimeShift ? [UIColor blackColor] : [UIColor lightGrayColor];
    self.timeShiftDurationSlider.enabled = isTimeShift;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([NCLShiftKeyFunctionsSettingsViewController class])]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        if (indexPath.section == 2 && indexPath.row == 0) {
            NCLShiftKeyFunctionsSettingsViewController *controller = segue.destinationViewController;
            controller.left = YES;
        }
    } else if ([segue.identifier isEqualToString:NSStringFromClass([NCLHelpViewController class])]) {
        NCLHelpViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

#pragma mark -

- (IBAction)fontSizeChanged:(id)sender
{
    double fontSize = self.fontSizeStepper.value;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:fontSize forKey:NCLSettingsFontSizeKey];
    
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%d pt", (NSInteger)fontSize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLSettingsFontDidChangeNodification object:nil];
}

- (IBAction)timeShiftSliderTouchUp:(id)sender
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.popup.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)timeShiftDurationChanged:(id)sender
{
    float timeShiftDuration = self.timeShiftDurationSlider.value;

    CGRect trackRect = [self.timeShiftDurationSlider trackRectForBounds:self.timeShiftDurationSlider.bounds];
    CGRect thumbRect = [self.timeShiftDurationSlider thumbRectForBounds:self.timeShiftDurationSlider.bounds
                                                              trackRect:trackRect
                                                                  value:timeShiftDuration];
    CGPoint center = CGPointMake(CGRectGetMinX(thumbRect) + CGRectGetMinX(self.timeShiftDurationSlider.frame),
                                 CGRectGetMinY(self.timeShiftDurationSlider.frame) - 44.0f);
    center = [self.timeShiftDurationSlider convertPoint:center toView:self.view];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        center.x -= CGRectGetWidth(thumbRect) / 4;
    } else {
        center.x -= 2.0f;
    }
    self.popup.center = center;
    self.popup.alpha = 1.0f;
    self.popup.valueLabel.text = [NSString stringWithFormat:@"%d", (NSInteger)(timeShiftDuration * 1000)];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:timeShiftDuration forKey:NCLSettingsTimeShiftDurationKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLSettingsShiftKeyBehaviorDidChangeNodification object:nil];
}

- (IBAction)swapKeySwitchValueChanged:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.swapKeySwitch.isOn forKey:NCLSettingsSwapBackspaceReturnEnabledKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLSettingsSwapBackspaceReturnEnabledDidChangeNodification object:nil];
}

#pragma mark -

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Font", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Shift Key Behavior", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Shift Key Functions", nil);
    } else if (section == 3) {
        return NSLocalizedString(@"Special", nil);
    } else if (section == 4) {
        return NSLocalizedString(@"Help", nil);
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1 && row == 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *shiftKeyBehavior = [userDefaults stringForKey:NCLSettingsShiftKeyBehaviorKey];
        cell.textLabel.text = NSLocalizedString(shiftKeyBehavior, nil);
    } else if (section == 2 && row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Left Shift Key", nil);
    } else if (section == 2 && row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Right Shift Key", nil);
    } else if (section == 4) {
        cell.textLabel.text = NSLocalizedString(@"Help", nil);
    }
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    }
}

#pragma mark -

- (void)helpViewControllerShouldShowSupport:(NCLHelpViewController *)controller
{
    if ([self.delegate respondsToSelector:@selector(settingsViewControllerShouldShowSupport:)]) {
        [self.delegate settingsViewControllerShouldShowSupport:self];
    }
}

- (void)helpViewControllerShouldShowReportIssue:(NCLHelpViewController *)controller
{
    if ([self.delegate respondsToSelector:@selector(settingsViewControllerShouldShowReportIssue:)]) {
        [self.delegate settingsViewControllerShouldShowReportIssue:self];
    }
}

- (void)helpViewControllerShouldShowInbox:(NCLHelpViewController *)controller
{
    if ([self.delegate respondsToSelector:@selector(settingsViewControllerShouldShowInbox:)]) {
        [self.delegate settingsViewControllerShouldShowInbox:self];
    }
}

- (void)helpViewControllerShouldShowFAQs:(NCLHelpViewController *)controller
{
    if ([self.delegate respondsToSelector:@selector(settingsViewControllerShouldShowFAQs:)]) {
        [self.delegate settingsViewControllerShouldShowFAQs:self];
    }
}

@end
