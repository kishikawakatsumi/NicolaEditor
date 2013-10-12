//
//  NCLFontSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLFontSettingsViewController.h"
#import "NCLSettingsViewController.h"

@interface NCLFontSettingsViewController ()

@end

@implementation NCLFontSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Font", nil);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fontName = [userDefaults stringForKey:@"font-name"];
    
    NSInteger row = indexPath.row;
    if (row == 0 && [fontName isEqualToString:@"HiraMinProN-W3"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (row == 1 && [fontName isEqualToString:@"HiraKakuProN-W3"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSObject cancelPreviousPerformRequestsWithTarget:tableView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"font-name";
    
    NSInteger row = indexPath.row;
    if (row == 0) {
        [userDefaults setObject:@"HiraMinProN-W3" forKey:key];
    } else if (row == 1) {
        [userDefaults setObject:@"HiraKakuProN-W3" forKey:key];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLShiftKeyBehaviorSettingsChanged object:nil];
}

@end
