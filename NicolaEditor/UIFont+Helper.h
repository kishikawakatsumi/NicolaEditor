//
//  UIFont+Helper.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/17.
//  Copyright (c) 2013年 kishikawa katsumi. All rights reserved.
//

@import Foundation;

@interface UIFont(Helper)

+ (NSString *)postscriptNameFromFullName:(NSString *)fullName;
+ (UIFont *)fontWithName:(NSString *)name size:(CGFloat)size boldTrait:(BOOL)isBold italicTrait:(BOOL)isItalic;
- (UIFont *)fontWithBoldTrait:(BOOL)bold italicTrait:(BOOL)italic andSize:(CGFloat)size;
- (UIFont *)fontWithBoldTrait:(BOOL)bold andItalicTrait:(BOOL)italic;

@end
