//
//  NCLVNCSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2014/05/12.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "NCLVNCSettingsViewController.h"
#import "NCLServerProfileViewController.h"
#import "NCLConstants.h"
#import "ProfileSaverFetcher.h"

@interface NCLVNCSettingsViewController ()

@property (nonatomic) NSMutableArray *savedProfileURLs;
@property (nonatomic) NSMutableArray *savedServerProfiles;

@end

@implementation NCLVNCSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Connect to a Computer", nil);
    
	self.tableView.allowsSelectionDuringEditing = YES;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.action = @selector(editButtonPushed:);
    
    NSError *error = nil;
    NSArray *savedProfileURLs = [ProfileSaverFetcher fetchSavedProfilesURLList:&error];
    
	if (!savedProfileURLs) {
		if (error) {
			DLogErr(@"Failed to retrieve list of saved Profiles, %@", error.localizedDescription);
        }
	}
    
    NSMutableArray *savedServerProfiles = [[NSMutableArray alloc] init];
	[savedProfileURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *profileURL = obj;
		NSDictionary *resources;
		if (profileURL) {
			resources = [ProfileSaverFetcher fetchTitleAndSubtitleFromURL:profileURL];
			if (resources) {
				[savedServerProfiles addObject:resources];
			}
		}
    }];
    
    self.savedProfileURLs = savedProfileURLs.mutableCopy;
    self.savedServerProfiles = savedServerProfiles;
    
    if (self.savedServerProfiles.count == 0) {
        self.editButtonItem.enabled = NO;
    } else {
        self.editButtonItem.enabled = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -

- (void)editButtonPushed:(UIBarButtonItem *)sender
{
	if (!self.tableView.editing) {
		[self tableEditingStart];
	} else {
		[self tableEditingDone];
	}
}

- (void)tableEditingStart
{
	[self.tableView setEditing:YES animated:YES];
	self.editButtonItem.title = NSLocalizedString(@"Done", nil);
}

- (void)tableEditingDone
{
	[self.tableView setEditing:NO animated:YES];
	self.editButtonItem.title = NSLocalizedString(@"Edit", nil);
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Create a New Server Profile", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Saved Server Profiles", nil);
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return self.savedServerProfiles.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddServerCell"];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DiscoveryCell"];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ServerProfileCell"];
        
        NSDictionary *resources = self.savedServerProfiles[indexPath.row];
        cell.textLabel.text = resources[PROFILE_TITLE_KEY];
        cell.detailTextLabel.text = resources[PROFILE_SUBTITLE_KEY];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    
	NSURL *profileURL = self.savedProfileURLs[indexPath.row];
    
    ServerProfile *profile = nil;
    NSError *error = nil;
    if (profileURL) {
        profile = [ProfileSaverFetcher readSavedProfileFromURL:profileURL Error:&error];
    }
	
	if (error) {
		DLogErr(@"Error: Failed to load profile, Error: %@", error.localizedDescription);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Errpr" message:NSLocalizedString(@"Failed to load saved profile for connection", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
	
	if (tableView.editing) {
        NCLServerProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([NCLServerProfileViewController class])];
        controller.delegate = self;
        if (profileURL && profile) {
            controller.savedURL = profileURL;
            controller.serverProfile = profile;
            [self tableEditingDone];
        }
        
        [self.navigationController pushViewController:controller animated:YES];
	} else {
        [[NSNotificationCenter defaultCenter] postNotificationName:NCLVNCServerWillConnectNodification object:self userInfo:@{NCLVNCServerProfileKey: profile}];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSURL *profileURL = self.savedProfileURLs[row];
        if (![ProfileSaverFetcher deleteSavedProfileFromURL:profileURL Error:nil]) {
            return;
        }
        
        [self.savedProfileURLs removeObjectAtIndex:row];
        [self.savedServerProfiles removeObjectAtIndex:row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
