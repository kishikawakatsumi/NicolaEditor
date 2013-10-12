//
//  NCLKeyboardAccessoryView.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLKeyboardAccessoryView.h"

@interface NCLKeyboardAccessoryView ()

@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

@end

@implementation NCLKeyboardAccessoryView

- (IBAction)selectionChanged:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if ([self.delegate respondsToSelector:@selector(accessoryView:keyboardTypeDidChange:)]) {
        [self.delegate accessoryView:self keyboardTypeDidChange:segmentedControl.selectedSegmentIndex];
    }
}

- (IBAction)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryViewDidComplete:)]) {
        [self.delegate accessoryViewDidComplete:self];
    }
}

@end
