//
//  NCLPopoverManager.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/17.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

@import Foundation;

@interface NCLPopoverManager : NSObject

@property (nonatomic, getter = isPopoverVisible) BOOL popoverVisible;

+ (instancetype)sharedManager;

- (void)presentPopover:(UIPopoverController *)popoverController fromBarButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)presentInteractionController:(UIDocumentInteractionController *)interactionController fromBarButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)presentActionSheet:(UIActionSheet *)actionSheet fromBarButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)dismissPopovers;
- (void)dismissPopoversWithoutAnimation;

@end
