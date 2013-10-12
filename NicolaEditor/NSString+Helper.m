//
//  NSString+Helper.m
//  Ubiregi2
//
//  Created by kishikawa katsumi on 2013/10/09.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

+ (NSString *)UUIDString
{
    CFUUIDRef UUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, UUID);
    CFRelease(UUID);
    return (__bridge_transfer NSString *)string;
}

@end
