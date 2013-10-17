//
//  NCLPopoverManager.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/17.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLPopoverManager.h"

@interface NCLPopoverManager ()

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

- (void)presentPopover:(UIPopoverController *)popoverController fromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (popoverController.isPopoverVisible) {
        [popoverController dismissPopoverAnimated:YES];
    } else {
        [popoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [self.popoverControllers addObject:popoverController];
    }
}

- (void)dismissPopovers
{
    for (UIPopoverController *popoverController in self.popoverControllers) {
        if (popoverController.isPopoverVisible) {
            [popoverController dismissPopoverAnimated:YES];
        }
    }
}

@end
