//
//  NCLHelpViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/18.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLHelpViewController.h"

@interface NCLHelpViewController ()

@end

@implementation NCLHelpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Help", nil);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0 && row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Report Issue", nil);
    } else if (section == 1 && row == 0) {
        cell.textLabel.text = NSLocalizedString(@"About N+Note", nil);
    }
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0 && row == 0) {
        if ([self.delegate respondsToSelector:@selector(helpViewControllerShouldShowUserVoice:)]) {
            [self.delegate helpViewControllerShouldShowUserVoice:self];
        }
    }
}

@end
