//
//  NCLNotesViewController.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class NCLTextViewController;

@interface NCLNotesViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic) NCLTextViewController *textViewController;

@end
