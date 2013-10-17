//
//  NCLSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLSettingsViewController.h"
#import "NCLShiftKeyFunctionsSettingsViewController.h"
#import "NCLConstants.h"

@interface NCLSettingsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *fontNameLabel;

@property (nonatomic, weak) IBOutlet UITableViewCell *fontSizeCell;
@property (nonatomic, weak) IBOutlet UIStepper *fontSizeStepper;
@property (nonatomic, weak) IBOutlet UILabel *fontSizeLabel;

@property (nonatomic, weak) IBOutlet UILabel *shiftKeyBehaviorLabel;
@property (nonatomic, weak) IBOutlet UISlider *timeShiftDurationSlider;
@property (nonatomic, weak) IBOutlet UITableViewCell *timeShiftSliderCell;

@end

@implementation NCLSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Settings", nil);
    
    [self.fontSizeStepper removeFromSuperview];
    self.fontSizeCell.accessoryView = self.fontSizeStepper;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    double fontSize = [userDefaults doubleForKey:NCLSettingsFontSizeKey];
    self.fontSizeStepper.value = fontSize;
    
    float timeShiftDuration = [userDefaults doubleForKey:NCLSettingsTimeShiftDurationKey];
    self.timeShiftDurationSlider.value = timeShiftDuration;
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([NCLShiftKeyFunctionsSettingsViewController class])]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        if (indexPath.section == 2 && indexPath.row == 0) {
            NCLShiftKeyFunctionsSettingsViewController *controller = segue.destinationViewController;
            controller.left = YES;
        }
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

- (IBAction)timeShiftDurationChanged:(id)sender
{
    float timeShiftDuration = self.timeShiftDurationSlider.value;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:timeShiftDuration forKey:NCLSettingsTimeShiftDurationKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLSettingsShiftKeyBehaviorDidChangeNodification object:nil];
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
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        [self performSegueWithIdentifier:NSStringFromClass([NCLShiftKeyFunctionsSettingsViewController class]) sender:self];
    }
}

@end
