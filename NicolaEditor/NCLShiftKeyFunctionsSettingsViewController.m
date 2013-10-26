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

@property (nonatomic) NSArray *functions;

@end

@implementation NCLShiftKeyFunctionsSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Shift Key Function", nil);
    self.functions = @[NCLShiftKeyFunctionNextCandidate, NCLShiftKeyFunctionAcceptCandidate, NCLShiftKeyFunctionNone];
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
    
    NSString *function = self.functions[indexPath.row];
    cell.textLabel.text = NSLocalizedString(function, nil);
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
    
    if ([shiftKeyFunction isEqualToString:function]) {
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
    
    NSString *function = self.functions[indexPath.row];
    [userDefaults setObject:function forKey:key];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLSettingsShiftKeyFunctionDidChangeNodification object:nil];
}

@end
