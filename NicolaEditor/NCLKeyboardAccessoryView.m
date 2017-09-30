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

    UIBarButtonItem *space18 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space18.width = 18.0;
    UIBarButtonItem *space16 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space16.width = 16.0;
    UIBarButtonItem *space20 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space20.width = 20.0;
    UIBarButtonItem *space22 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space22.width = 22.0;
    UIBarButtonItem *space24 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space24.width = 24.0;
    UIBarButtonItem *space30 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space30.width = 30.0;

    [self.keyboardChooser setContentOffset:CGSizeMake(0.0, 1.0) forSegmentAtIndex:0];
    [self.keyboardChooser setContentOffset:CGSizeMake(0.0, 1.0) forSegmentAtIndex:1];

    UIBarButtonItem *upArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_up"] style:UIBarButtonItemStylePlain target:self action:@selector(arrowUp:)];
    UIBarButtonItem *downArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_down"] style:UIBarButtonItemStylePlain target:self action:@selector(arrowDown:)];
    UIBarButtonItem *leftArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left"] style:UIBarButtonItemStylePlain target:self action:@selector(arrowLeft:)];
    UIBarButtonItem *rightArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_right"] style:UIBarButtonItemStylePlain target:self action:@selector(arrowRight:)];
    UIBarButtonItem *cutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cut"] style:UIBarButtonItemStylePlain target:self action:@selector(cut:)];
    UIBarButtonItem *copyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"copy"] style:UIBarButtonItemStylePlain target:self action:@selector(copy:)];
    UIBarButtonItem *pasteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paste"] style:UIBarButtonItemStylePlain target:self action:@selector(paste:)];

    NSArray *items = @[space22, upArrowButton, space16, downArrowButton, space24, leftArrowButton, space30, rightArrowButton, space22, cutButton, space20, copyButton, space22, pasteButton];
    
    NSMutableArray *existingItems = self.toolbar.items.mutableCopy;
    [existingItems insertObjects:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, items.count)]];
    self.toolbar.items = existingItems;
}

- (UIButton *)customButtonWithImage:(UIImage *)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.showsTouchWhenHighlighted = YES;
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    
    CGRect frame = button.frame;
    frame.size.width = 44.0;
    button.frame = frame;
    
    return button;
}

#pragma mark -

- (IBAction)selectionChanged:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if ([self.delegate respondsToSelector:@selector(accessoryView:keyboardTypeDidChange:)]) {
        [self.delegate accessoryView:self keyboardTypeDidChange:segmentedControl.selectedSegmentIndex];
    }
}

#pragma mark -

- (IBAction)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryViewDidComplete:)]) {
        [self.delegate accessoryViewDidComplete:self];
    }
}

#pragma mark -

- (IBAction)arrowUp:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryViewArrowUp:)]) {
        [self.delegate accessoryViewArrowUp:self];
    }
}

- (IBAction)arrowDown:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryViewArrowDown:)]) {
        [self.delegate accessoryViewArrowDown:self];
    }
}

- (IBAction)arrowLeft:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryViewArrowLeft:)]) {
        [self.delegate accessoryViewArrowLeft:self];
    }
}

- (IBAction)arrowRight:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryViewArrowRight:)]) {
        [self.delegate accessoryViewArrowRight:self];
    }
}

#pragma mark -

- (IBAction)cut:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryViewCut:)]) {
        [self.delegate accessoryViewCut:self];
    }
}

- (IBAction)copy:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryViewCopy:)]) {
        [self.delegate accessoryViewCopy:self];
    }
}

- (IBAction)paste:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryViewPaste:)]) {
        [self.delegate accessoryViewPaste:self];
    }
}

@end
