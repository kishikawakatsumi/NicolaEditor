//
//  NCLKeyboardInputDisplayView.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/11.
//  Copyright (c) 2013年 kishikawa katsumi. All rights reserved.
//

#import "NCLKeyboardInputDisplayView.h"
#import <QuartzCore/QuartzCore.h>

@interface NCLKeyboardInputDisplayView ()

@property (nonatomic) UILabel *label;

@end


@implementation NCLKeyboardInputDisplayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.alpha = 0.0;
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        self.layer.borderWidth = 1.0 / scale;
        self.layer.borderColor = [[UIColor colorWithWhite:0.0 alpha:0.2] CGColor];
        self.layer.cornerRadius = 7.0;
        self.layer.masksToBounds = YES;
        
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:23.0];
        [self addSubview:self.label];
    }
    
    return self;
}

- (void)setInput:(NSString *)input
{
    _input = input;
    self.label.text = input;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.alpha = 0.0;
}

- (void)show
{
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

@end
