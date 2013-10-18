//
//  NCLHelpViewController.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/18.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCLHelpViewController : UITableViewController

@property (nonatomic, weak) id delegate;

@end

@protocol NCLHelpViewControllerDelegate <NSObject>

- (void)helpViewControllerShouldShowSupport:(NCLHelpViewController *)controller;
- (void)helpViewControllerShouldShowReportIssue:(NCLHelpViewController *)controller;
- (void)helpViewControllerShouldShowInbox:(NCLHelpViewController *)controller;
- (void)helpViewControllerShouldShowFAQs:(NCLHelpViewController *)controller;

@end

