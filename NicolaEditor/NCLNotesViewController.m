//
//  NCLNotesViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLNotesViewController.h"
#import "NCLTextViewController.h"
#import "NCLRFBInputViewController.h"
#import "NCLSettingsViewController.h"
#import "NCLPopoverManager.h"
#import "NCLNote.h"
#import "NCLConstants.h"
#import <NLCoreData/NLCoreData.h>
#import <uservoice-iphone-sdk/UserVoice.h>

@interface NCLNotesViewController ()

@property (nonatomic) UIPopoverController *settingsPopoverController;

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation NCLNotesViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Notes", nil);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.textViewController = (NCLTextViewController *)[self.splitViewController.viewControllers.lastObject topViewController];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext mainContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntity:[NCLNote class] context:managedObjectContext];
    fetchRequest.fetchBatchSize = 20;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverWillConnect:) name:NCLVNCServerWillConnectNodification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -

- (IBAction)presentSettings:(id)sender
{
    if ([[NCLPopoverManager sharedManager] isPopoverVisible]) {
        [[NCLPopoverManager sharedManager] dismissPopovers];
        return;
    }
    
    if (!self.settingsPopoverController) {
        NCLSettingsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([NCLSettingsViewController class])];
        controller.delegate = self;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        self.settingsPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    }
    
    [self.textViewController.view endEditing:YES];
    [[NCLPopoverManager sharedManager] presentPopover:self.settingsPopoverController fromBarButtonItem:self.navigationItem.leftBarButtonItem];
}

- (void)setEditing:(BOOL)editing
{
    if ([[NCLPopoverManager sharedManager] isPopoverVisible]) {
        [[NCLPopoverManager sharedManager] dismissPopovers];
        return;
    }
    
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    });
    
    [super setEditing:editing];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if ([[NCLPopoverManager sharedManager] isPopoverVisible]) {
        [[NCLPopoverManager sharedManager] dismissPopovers];
        return;
    }
    
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    });
    
    [super setEditing:editing animated:animated];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *managedObjectContext = self.fetchedResultsController.managedObjectContext;
        [managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [managedObjectContext saveNested];
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NCLNote *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.textViewController.note = note;
    
    self.selectedIndexPath = indexPath;
    
    [tableView reloadData];
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NCLNote *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = note.title;
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:note.createdAt];
    
    [cell setNeedsLayout];
}

#pragma mark -

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            });
            break;
        }
        case NSFetchedResultsChangeDelete: {
            if ([tableView.indexPathForSelectedRow isEqual:indexPath]) {
                self.textViewController.note = nil;
            }
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark -

- (void)serverWillConnect:(NSNotification *)notification
{
    [[NCLPopoverManager sharedManager] dismissPopovers];
    
    NCLRFBInputViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([NCLRFBInputViewController class])];
    controller.serverProfile = notification.userInfo[NCLVNCServerProfileKey];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)settingsViewControllerShouldShowUserVoice:(NCLSettingsViewController *)controller
{
    [[NCLPopoverManager sharedManager] dismissPopovers];
    if (self.textViewController.masterPopoverController.isPopoverVisible) {
        [self.textViewController.masterPopoverController dismissPopoverAnimated:YES];
    }
    
    [UserVoice presentUserVoiceInterfaceForParentViewController:self.textViewController];
}

@end
