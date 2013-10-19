//
//  NCLPopoverManager.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/17.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLPopoverManager.h"

@interface NCLPopoverManager ()

@property (nonatomic) UIDocumentInteractionController *interactionController;
@property (nonatomic) UIActionSheet *actionSheet;

@property (nonatomic) NSMutableSet *popoverControllers;

@end

@implementation NCLPopoverManager

+ (instancetype)sharedManager
{
    static NCLPopoverManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[NCLPopoverManager alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _popoverControllers = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (BOOL)isPopoverVisible
{
    for (UIPopoverController *popoverController in self.popoverControllers) {
        if (popoverController.isPopoverVisible) {
            return YES;
        }
    }
    if (self.interactionController || self.actionSheet) {
        return YES;
    }
    
    return NO;
}

- (void)presentPopover:(UIPopoverController *)popoverController fromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (self.isPopoverVisible) {
        [self dismissPopovers];
    } else {
        [popoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [self.popoverControllers addObject:popoverController];
    }
}

- (void)presentInteractionController:(UIDocumentInteractionController *)interactionController fromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (self.isPopoverVisible) {
        [self dismissPopovers];
    } else {
        [interactionController presentOptionsMenuFromBarButtonItem:barButtonItem animated:YES];
        self.interactionController = interactionController;
    }
}

- (void)presentActionSheet:(UIActionSheet *)actionSheet fromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (self.isPopoverVisible) {
        [self dismissPopovers];
    } else {
        [actionSheet showFromBarButtonItem:barButtonItem animated:YES];
        self.actionSheet = actionSheet;
    }
}

- (void)dismissPopovers
{
    [self dismissPopoversAnimated:YES];
}

- (void)dismissPopoversWithoutAnimation
{
    [self dismissPopoversAnimated:NO];
}

- (void)dismissPopoversAnimated:(BOOL)animated
{
    for (UIPopoverController *popoverController in self.popoverControllers) {
        if (popoverController.isPopoverVisible) {
            [popoverController dismissPopoverAnimated:animated];
        }
    }
    [self.popoverControllers removeAllObjects];
    
    [self dismissSystemPopoversAnimated:animated];
}

- (void)dismissSystemPopovers
{
    [self dismissSystemPopoversAnimated:YES];
}

- (void)dismissSystemPopoversAnimated:(BOOL)animated
{
    [self.interactionController dismissMenuAnimated:animated];
    self.interactionController = nil;
    
    [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:animated];
    self.actionSheet = nil;
}

@end
