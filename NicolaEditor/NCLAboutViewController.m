//
//  NCLAboutViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/22.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLAboutViewController.h"

@interface NCLAboutViewController ()

@property (nonatomic, weak) IBOutlet UITableViewCell *versionCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *creditCell;

@end

@implementation NCLAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.versionCell.textLabel.text = NSLocalizedString(@"Version", nil);
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *version = [mainBundle objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [mainBundle objectForInfoDictionaryKey: @"CFBundleVersion"];
    self.versionCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", version, build];
    
    self.creditCell.textLabel.text = NSLocalizedString(@"Developer", nil);
    self.creditCell.detailTextLabel.text = NSLocalizedString(@"kishikawa katsumi", nil);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
}

@end
