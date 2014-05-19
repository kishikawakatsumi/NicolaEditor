//
//  NCLHardwareKeyboardSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2014/05/11.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "NCLExternalKeyboardSettingsViewController.h"
#import "NCLConstants.h"

@interface NCLExternalKeyboardSettingsViewController ()

@end

@implementation NCLExternalKeyboardSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"External Keyboard", nil);
}

- (NSDictionary *)layoutDefinitions
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedKeyboard = [userDefaults stringForKey:NCLSettingsExternalKeyboardKey];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSData *data = [NSData dataWithContentsOfURL:[mainBundle URLForResource:selectedKeyboard withExtension:@"json"]];
    NSArray *layouts;
    if (data) {
        layouts = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = paths.lastObject;
        NSString *filename = [selectedKeyboard stringByAppendingPathExtension:@"json"];
        
        data = [NSData dataWithContentsOfFile:[documentDirectory stringByAppendingPathComponent:filename]];
        layouts = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    
    NSDictionary *layoutDefinitions = layouts[2];
    return layoutDefinitions;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else {
        return self.layoutDefinitions.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Keyboard", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Layout", nil);
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedKeyboard = [userDefaults stringForKey:NCLSettingsExternalKeyboardKey];
    
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"Wireless Keyboard JIS";
            if ([selectedKeyboard isEqualToString:NCLKeyboardAppleWirelessKeyboardJIS]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (row == 1) {
            cell.textLabel.text = @"Wireless Keyboard US";
            if ([selectedKeyboard isEqualToString:NCLKeyboardAppleWirelessKeyboardUS]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            cell.textLabel.text = NSLocalizedString(@"User Defined", nil);
            if ([selectedKeyboard isEqualToString:NCLKeyboardUserDefined]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if (section == 1) {
        NSArray *layoutNames = [self.layoutDefinitions.allKeys sortedArrayUsingSelector:@selector(compare:)];
        NSString *layoutName = layoutNames[row];
        
        cell.textLabel.text = layoutName;
        
        NSString *selectedLayout = [userDefaults stringForKey:NCLSettingsExternalKeyboardLayoutKey];
        if ([selectedLayout isEqualToString:layoutName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSObject cancelPreviousPerformRequestsWithTarget:tableView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        NSString *key = NCLSettingsExternalKeyboardKey;
        
        if (row == 0) {
            [userDefaults setObject:NCLKeyboardAppleWirelessKeyboardJIS forKey:key];
        } else if (row == 1) {
            [userDefaults setObject:NCLKeyboardAppleWirelessKeyboardUS forKey:key];
        } else if (row == 2) {
            [userDefaults setObject:NCLKeyboardUserDefined forKey:key];
        }
        
        NSArray *layoutNames = [self.layoutDefinitions.allKeys sortedArrayUsingSelector:@selector(compare:)];
        NSString *selectedLayout = [userDefaults stringForKey:NCLSettingsExternalKeyboardLayoutKey];
        if ([layoutNames indexOfObject:selectedLayout] == NSNotFound) {
            [userDefaults setObject:layoutNames.firstObject forKey:NCLSettingsExternalKeyboardLayoutKey];
        }
    } else if (section == 1) {
        NSString *key = NCLSettingsExternalKeyboardLayoutKey;
        
        NSArray *layoutNames = [self.layoutDefinitions.allKeys sortedArrayUsingSelector:@selector(compare:)];
        NSString *layoutName = layoutNames[row];
        
        [userDefaults setObject:layoutName forKey:key];
    }
    
    [userDefaults synchronize];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

@end