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
@property (nonatomic, weak) IBOutlet UISegmentedControl *keyboardChooser;

@end

@implementation NCLKeyboardAccessoryView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        if ([UIToolbar instancesRespondToSelector:@selector(setShadowImage:forToolbarPosition:)]) {
            [self.toolbar setBackgroundImage:[[UIImage imageNamed:@"toolbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsZero] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            [self.toolbar setShadowImage:[UIImage imageNamed:@"shadow"] forToolbarPosition:UIBarPositionAny];
        } else {
            [self.toolbar setBackgroundImage:[[UIImage imageNamed:@"toolbar_bg_with_shadow"] resizableImageWithCapInsets:UIEdgeInsetsZero] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
    } else {
        [self.keyboardChooser setContentOffset:CGSizeMake(0.0f, 1.0f) forSegmentAtIndex:0];
        [self.keyboardChooser setContentOffset:CGSizeMake(0.0f, 1.0f) forSegmentAtIndex:1];
    }
}

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
