//
//  NCLSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLSettingsViewController.h"

NSString * const NCLFontSettingsChanged = @"NCLFontSettingsChanged";
NSString * const NCLShiftKeyBehaviorSettingsChanged = @"NCLShiftKeyBehaviorSettingsChanged";

@interface NCLSettingsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *fontNameLabel;

@property (nonatomic, weak) IBOutlet UIStepper *fontSizeStepper;
@property (nonatomic, weak) IBOutlet UILabel *fontSizeLabel;

@property (nonatomic, weak) IBOutlet UILabel *shiftKeyBehaviorLabel;
@property (nonatomic, weak) IBOutlet UISlider *timeShiftDurationSlider;

@end

@implementation NCLSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Settings", nil);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    double fontSize = [userDefaults doubleForKey:@"font-size"];
    self.fontSizeStepper.value = fontSize;
    
    float timeShiftDuration = [userDefaults doubleForKey:@"time-shift-duration"];
    self.timeShiftDurationSlider.value = timeShiftDuration;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fontName = [userDefaults stringForKey:@"font-name"];
    self.fontNameLabel.text = NSLocalizedString(fontName, nil);
    
    double fontSize = [userDefaults doubleForKey:@"font-size"];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%d pt", (NSInteger)fontSize];
    
    NSString *shiftKeyBehavior = [userDefaults stringForKey:@"shift-key-behavior"];
    self.shiftKeyBehaviorLabel.text = NSLocalizedString(shiftKeyBehavior, nil);
}

#pragma mark -

- (IBAction)fontSizeChanged:(id)sender
{
    double fontSize = self.fontSizeStepper.value;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:fontSize forKey:@"font-size"];
    
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%d pt", (NSInteger)fontSize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLShiftKeyBehaviorSettingsChanged object:nil];
}

- (IBAction)timeShiftDurationChanged:(id)sender
{
    float timeShiftDuration = self.timeShiftDurationSlider.value;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:timeShiftDuration forKey:@"time-shift-duration"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLShiftKeyBehaviorSettingsChanged object:nil];
}

#pragma mark -

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Font", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Shift Key Behavior", nil);
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1 && row == 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *shiftKeyBehavior = [userDefaults stringForKey:@"shift-key-behavior"];
        cell.textLabel.text = NSLocalizedString(shiftKeyBehavior, nil);
    }
}

@end
