//
//  NCLSettingsViewController.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCLSettingsViewController : UITableViewController

@property (nonatomic, weak) id delegate;

@end

@protocol NCLSettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerShouldShowSupport:(NCLSettingsViewController *)controller;
- (void)settingsViewControllerShouldShowReportIssue:(NCLSettingsViewController *)controller;
- (void)settingsViewControllerShouldShowInbox:(NCLSettingsViewController *)controller;
- (void)settingsViewControllerShouldShowFAQs:(NCLSettingsViewController *)controller;

@end
