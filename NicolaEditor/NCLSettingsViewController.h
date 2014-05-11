//
//  NCLSettingsViewController.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

@import UIKit;

@interface NCLSettingsViewController : UITableViewController

@property (nonatomic, weak) id delegate;

@end

@protocol NCLSettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerShouldShowUserVoice:(NCLSettingsViewController *)controller;

@end
