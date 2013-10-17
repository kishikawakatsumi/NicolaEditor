//
//  NCLShiftKeyFunctionsSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/16.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLShiftKeyFunctionsSettingsViewController.h"
#import "NCLConstants.h"

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
        shiftKeyFunction = [userDefaults stringForKey:NCLSettingsLeftShiftFunctionKey];
    } else {
        shiftKeyFunction = [userDefaults stringForKey:NCLSettingsRightShiftFunctionKey];
    }
    
    NSInteger row = indexPath.row;
    if (row == 0 && [shiftKeyFunction isEqualToString:NCLShiftKeyFunctionNextCandidate]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (row == 1 && [shiftKeyFunction isEqualToString:NCLShiftKeyFunctionAcceptCandidate]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (row == 2 && [shiftKeyFunction isEqualToString:NCLShiftKeyFunctionNone]) {
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
        key = NCLSettingsLeftShiftFunctionKey;
    } else {
        key = NCLSettingsRightShiftFunctionKey;
    }
    
    NSInteger row = indexPath.row;
    if (row == 0) {
        [userDefaults setObject:NCLShiftKeyFunctionNextCandidate forKey:key];
    } else if (row == 1) {
        [userDefaults setObject:NCLShiftKeyFunctionAcceptCandidate forKey:key];
    } else if (row == 2) {
        [userDefaults setObject:NCLShiftKeyFunctionNone forKey:key];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLSettingsShiftKeyFunctionDidChangeNodification object:nil];
}

@end
