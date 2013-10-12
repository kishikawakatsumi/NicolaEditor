//
//  NCLShiftKeyBehaviorSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLShiftKeyBehaviorSettingsViewController.h"
#import "NCLSettingsViewController.h"
#import "NCLKeyboardView.h"

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
    NSString *shiftKeyBehavior = [userDefaults stringForKey:@"shift-key-behavior"];
    
    NSInteger row = indexPath.row;
    if (row == 0 && [shiftKeyBehavior isEqualToString:NCLKeyboardShiftKeyBehaviorTimeShift]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (row == 1 && [shiftKeyBehavior isEqualToString:NCLKeyboardShiftKeyBehaviorContinuityShift]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (row == 2 && [shiftKeyBehavior isEqualToString:NCLKeyboardShiftKeyBehaviorPrefixShift]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSObject cancelPreviousPerformRequestsWithTarget:tableView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"shift-key-behavior";
    
    NSInteger row = indexPath.row;
    if (row == 0) {
        [userDefaults setObject:@"Time-Shift" forKey:key];
    } else if (row == 1) {
        [userDefaults setObject:@"Continuity-Shift" forKey:key];
    } else if (row == 2) {
        [userDefaults setObject:@"Prefix-Shift" forKey:key];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLShiftKeyBehaviorSettingsChanged object:nil];
}

@end
