//
//  UILabel+Helper.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/22.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "UILabel+Helper.h"

@implementation UILabel (Helper)

- (UIColor *)highlightedTextColor
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return [UIColor whiteColor];
    } else {
        return self.textColor;
    }
}

@end
