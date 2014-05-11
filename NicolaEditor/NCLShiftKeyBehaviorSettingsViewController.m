//
//  NCLShiftKeyBehaviorSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLShiftKeyBehaviorSettingsViewController.h"
#import "NCLConstants.h"

@interface NCLShiftKeyBehaviorSettingsViewController ()

@end

@implementation NCLShiftKeyBehaviorSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Shift Key Behavior", nil);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyBehavior = [userDefaults stringForKey:NCLSettingsShiftKeyBehaviorKey];
    
    NSInteger row = indexPath.row;
    if (row == 0 && [shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorTimeShift]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (row == 1 && [shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorContinuityShift]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (row == 2 && [shiftKeyBehavior isEqualToString:NCLShiftKeyBehaviorPrefixShift]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSObject cancelPreviousPerformRequestsWithTarget:tableView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = NCLSettingsShiftKeyBehaviorKey;
    
    NSInteger row = indexPath.row;
    if (row == 0) {
        [userDefaults setObject:NCLShiftKeyBehaviorTimeShift forKey:key];
    } else if (row == 1) {
        [userDefaults setObject:NCLShiftKeyBehaviorContinuityShift forKey:key];
    } else if (row == 2) {
        [userDefaults setObject:NCLShiftKeyBehaviorPrefixShift forKey:key];
    }
    [userDefaults synchronize];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

@end
