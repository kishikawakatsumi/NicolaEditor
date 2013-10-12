//
//  NCLKeyboardButton.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/07.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLKeyboardButton.h"

@interface NCLKeyboardButton ()

@end

@implementation NCLKeyboardButton

- (id)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _index = index;
    }
    
    return self;
}

@end
