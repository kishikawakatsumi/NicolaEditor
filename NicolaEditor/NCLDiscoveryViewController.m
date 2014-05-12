//
//  NCLDiscoveryViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2014/05/12.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "NCLDiscoveryViewController.h"
#import "NCLServerProfileViewController.h"
#import "MDNSDiscoverer.h"
#import "ServerProfile.h"
#import "UIViewController+Spinner.h"

@interface NCLDiscoveryViewController () <MDNSDiscovererDelegateProtocol>

@property (nonatomic) MDNSDiscoverer *discoverer;
@property (nonatomic) NSMutableArray *searchResults;

@end

@implementation NCLDiscoveryViewController

- (void)awakeFromNib
{
    _discoverer = [[MDNSDiscoverer alloc] init];
    _searchResults = [[NSMutableArray alloc] init];
}

- (void)dealloc
{
    self.discoverer.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"VNC Servers Found", nil);
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                            target:self
                                                                            action:@selector(startRFBDiscovery)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [self startRFBDiscovery];
}

#pragma mark -

- (void)startRFBDiscovery
{
    [self.searchResults removeAllObjects];
    
    self.discoverer.delegate = self;
    [self.discoverer startSearch];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"discoveredCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (self.searchResults.count > 0) {
        NSDictionary *serviceDetails = self.searchResults[indexPath.row];
        cell.textLabel.text = serviceDetails[SERVICE_NAME];
        
        NSString *address = serviceDetails[SERVICE_ADDRESS];
        NSString *port = serviceDetails[SERVICE_PORT];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ : %@", address, port];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *serviceDetails = self.searchResults[indexPath.row];
    ServerProfile *serverProfile = [[ServerProfile alloc] initWithAddress:serviceDetails[SERVICE_ADDRESS]
                                                                     Port:[serviceDetails[SERVICE_PORT] intValue]
                                                                 Username:@""
                                                                 Password:@""
                                                               ServerName:serviceDetails[SERVICE_NAME]
                                                            ServerVersion:@""
                                                                    ARD35:NO
                                                                  MacAuth:NO];
    
	NCLServerProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([NCLServerProfileViewController class])];
	controller.serverProfile = serverProfile;
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -

- (void)MDNSDiscovererStartedSearch:(MDNSDiscoverer *)discoverer
{
    [self startSpinnerWithWaitText:NSLocalizedString(@"Searching...", nil)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)MDNSDiscoverer:(MDNSDiscoverer *)discoverer completedSearch:(NSArray *)searchResults
{
    [self stopSpinner];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (searchResults.count > 0) {
        self.searchResults = searchResults.mutableCopy;
        [self.tableView reloadData];
    }
}

- (void)MDNSDiscoverer:(MDNSDiscoverer *)discoverer failedSearch:(NSError *)error
{
    DLog(@"Failed search, error: %@", [error localizedDescription]);
    [self stopSpinner];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.tableView reloadData];
}

@end
