//
//  NCLMasterViewController.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013年 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCLDetailViewController;

#import <CoreData/CoreData.h>

@interface NCLMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NCLDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
