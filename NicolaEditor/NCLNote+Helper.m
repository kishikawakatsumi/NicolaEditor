//
//  NCLNote+Helper.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLNote+Helper.h"
#import "NSString+Helper.h"

@implementation NCLNote (Helper)

- (void)awakeFromInsert
{
    self.identifier = [NSString UUIDString];
    self.createdAt = [NSDate date];
    self.updatedAt = self.createdAt;
    [super awakeFromInsert];
}

- (void)willSave
{
    if (self.isUpdated) {
         [self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
    }
    [super willSave];
}

@end
