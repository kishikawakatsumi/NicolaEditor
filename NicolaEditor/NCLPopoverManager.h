//
//  NCLPopoverManager.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/17.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

@import Foundation;

@interface NCLPopoverManager : NSObject

@property (nonatomic, weak) UIDocumentInteractionController *interactionController;
@property (nonatomic, weak) UIActionSheet *actionSheet;

+ (instancetype)sharedManager;

- (void)presentPopover:(UIPopoverController *)popoverController fromBarButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)dismissPopovers;
- (void)dismissPopoversWithoutAnimation;

@end
