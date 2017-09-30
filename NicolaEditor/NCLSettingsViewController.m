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

    self.swapKeyLabel.text = NSLocalizedString(@"Swap ⌫ Key for ⏎ Key", nil);
    
    UISwitch *sw = self.swapKeySwitch;
    [sw removeFromSuperview];
    self.swapKeyCell.accessoryView = sw;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isSwapped = [userDefaults boolForKey:NCLSettingsSwapBackspaceReturnEnabledKey];
    self.swapKeySwitch.on = isSwapped;
    
    double fontSize = [userDefaults doubleForKey:NCLSettingsFontSizeKey];
    self.fontSizeStepper.value = fontSize;

    self.timeShiftDurationLabel.text = NSLocalizedString(@"Shift Key Delay", nil);
    
    float timeShiftDuration = [userDefaults doubleForKey:NCLSettingsTimeShiftDurationKey];
    self.timeShiftDurationSlider.value = timeShiftDuration;
    
    self.popup = [[[UINib nibWithNibName:NSStringFromClass([NCLSliderPopup class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    self.popup.alpha = 0.0;
    [self.view addSubview:self.popup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fontName = [userDefaults stringForKey:NCLSettingsFontNameKey];
    self.fontNameLabel.text = NSLocalizedString(fontName, nil);
    
    double fontSize = [userDefaults doubleForKey:NCLSettingsFontSizeKey];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%d pt", (int)fontSize];
    
    NSString *shiftKeyBehavior = [userDefaults stringForKey:NCLSettingsShiftKeyBehaviorKey];
    self.shiftKeyBehaviorLabel.text = NSLocalizedString(shiftKeyBehavior, nil);
    
    BOOL isTimeShift = [shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorTimeShift] || [shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorContinuityShift];
    self.timeShiftDurationLabel.textColor = isTimeShift ? [UIColor blackColor] : [UIColor lightGrayColor];
    self.timeShiftDurationSlider.enabled = isTimeShift;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier hasPrefix:NSStringFromClass([NCLShiftKeyFunctionsSettingsViewController class])]) {
        if ([segue.identifier hasSuffix:@"-Left"]) {
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
    [userDefaults synchronize];
    
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%d pt", (int)fontSize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLSettingsFontDidChangeNodification object:self];
}

- (IBAction)timeShiftSliderTouchUp:(id)sender
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.popup.alpha = 0.0;
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
                                 CGRectGetMinY(self.timeShiftDurationSlider.frame) - 44.0);
    center = [self.timeShiftDurationSlider convertPoint:center toView:self.view];
    center.x -= 2.0;

    self.popup.center = center;
    self.popup.alpha = 1.0;
    self.popup.valueLabel.text = [NSString stringWithFormat:@"%d", (int)(timeShiftDuration * 1000)];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:timeShiftDuration forKey:NCLSettingsTimeShiftDurationKey];
}

- (IBAction)swapKeySwitchValueChanged:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.swapKeySwitch.isOn forKey:NCLSettingsSwapBackspaceReturnEnabledKey];
    [userDefaults synchronize];
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
    } else if (section == 5) {
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
    } else if (section == 3) {
        if (row == 1) {
            cell.textLabel.text = NSLocalizedString(@"External Keyboard", nil);
        } else if (row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Connect to a Computer", nil);
        }
    } else if (section == 4) {
        cell.textLabel.text = NSLocalizedString(@"Help", nil);
    }
}

#pragma mark -

- (void)helpViewControllerShouldShowUserVoice:(NCLHelpViewController *)controller
{
    if ([self.delegate respondsToSelector:@selector(settingsViewControllerShouldShowUserVoice:)]) {
        [self.delegate settingsViewControllerShouldShowUserVoice:self];
    }
}

@end
