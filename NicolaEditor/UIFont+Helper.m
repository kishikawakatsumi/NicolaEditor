//
//  UIFont+Helper.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/17.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "UIFont+Helper.h"

@import CoreText;

@implementation UIFont (Helper)

+ (NSString *)postscriptNameFromFullName:(NSString *)fullName
{
	UIFont *font = [UIFont fontWithName:fullName size:1];
	return (__bridge NSString *)(CTFontCopyPostScriptName((__bridge CTFontRef)(font)));
}

+ (UIFont *)fontWithName:(NSString *)name size:(CGFloat)size boldTrait:(BOOL)isBold italicTrait:(BOOL)isItalic
{
	NSString *postScriptName = [UIFont postscriptNameFromFullName:name];
	
	CTFontSymbolicTraits traits = 0;
	CTFontRef newFontRef;
	CTFontRef fontWithoutTrait = CTFontCreateWithName((__bridge CFStringRef)(postScriptName), size, NULL);
	
	if (isItalic)
		traits |= kCTFontItalicTrait;
	
	if (isBold)
		traits |= kCTFontBoldTrait;
	
	if (traits == 0) {
		newFontRef= CTFontCreateCopyWithAttributes(fontWithoutTrait, 0.0, NULL, NULL);
	} else {
		newFontRef = CTFontCreateCopyWithSymbolicTraits(fontWithoutTrait, 0.0, NULL, traits, traits);
	}
	
	if (newFontRef) {
		NSString *fontNameKey = (__bridge NSString *)(CTFontCopyName(newFontRef, kCTFontPostScriptNameKey));
		return [UIFont fontWithName:fontNameKey size:CTFontGetSize(newFontRef)];
	}
	
	return nil;
}

- (UIFont *)fontWithBoldTrait:(BOOL)bold italicTrait:(BOOL)italic andSize:(CGFloat)size
{
	CTFontRef fontRef = (__bridge CTFontRef)self;
	NSString *familyName = (__bridge NSString *)(CTFontCopyName(fontRef, kCTFontFamilyNameKey));
	NSString *postScriptName = [UIFont postscriptNameFromFullName:familyName];
	return [[self class] fontWithName:postScriptName size:size boldTrait:bold italicTrait:italic];
}

- (UIFont *)fontWithBoldTrait:(BOOL)bold andItalicTrait:(BOOL)italic
{
	return [self fontWithBoldTrait:bold italicTrait:italic andSize:self.pointSize];
}

@end
