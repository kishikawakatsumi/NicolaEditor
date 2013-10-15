//
//  NCLShiftKeyFunctionsSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/16.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLShiftKeyFunctionsSettingsViewController.h"
#import "NCLSettingsViewController.h"
#import "NCLKeyboardView.h"

@interface NCLShiftKeyFunctionsSettingsViewController ()

@end

@implementation NCLShiftKeyFunctionsSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Shift Key Function", nil);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *shiftKeyFunction;
    if (self.isLeft) {
        shiftKeyFunction = [userDefaults stringForKey:@"shift-key-function-left"];
    } else {
        shiftKeyFunction = [userDefaults stringForKey:@"shift-key-function-right"];
    }
    
    NSInteger row = indexPath.row;
    if (row == 0 && [shiftKeyFunction isEqualToString:NCLKeyboardShiftKeyFunctionNextCandidate]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (row == 1 && [shiftKeyFunction isEqualToString:NCLKeyboardShiftKeyFunctionAcceptCandidate]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (row == 2 && [shiftKeyFunction isEqualToString:NCLKeyboardShiftKeyFunctionNone]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSObject cancelPreviousPerformRequestsWithTarget:tableView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key;
    if (self.isLeft) {
        key = @"shift-key-function-left";
    } else {
        key = @"shift-key-function-right";
    }
    
    NSInteger row = indexPath.row;
    if (row == 0) {
        [userDefaults setObject:NCLKeyboardShiftKeyFunctionNextCandidate forKey:key];
    } else if (row == 1) {
        [userDefaults setObject:NCLKeyboardShiftKeyFunctionAcceptCandidate forKey:key];
    } else if (row == 2) {
        [userDefaults setObject:NCLKeyboardShiftKeyFunctionNone forKey:key];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLShiftKeyFunctionSettingsChanged object:nil];
}

@end
