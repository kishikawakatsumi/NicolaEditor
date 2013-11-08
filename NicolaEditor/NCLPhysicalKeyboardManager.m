//
//  NCLKeyboardManager.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/11/09.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLPhysicalKeyboardManager.h"
#import "NCLConstants.h"

@interface NCLPhysicalKeyboardManager ()

@end

@implementation NCLPhysicalKeyboardManager

+ (instancetype)sharedManager
{
    static NCLPhysicalKeyboardManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[NCLPhysicalKeyboardManager alloc] init];
    });
    
    return sharedManager;
}

- (void)setTextView:(UITextView *)textView
{
    _textView = textView;
    
    id internalKeyboard = self.textView.inputDelegate;
    [internalKeyboard addObserver:self forKeyPath:@"inHardwareKeyboardMode" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
}

- (BOOL)isPhysicalKeyboardAttached
{
    id internalKeyboard = self.textView.inputDelegate;
    return [[internalKeyboard valueForKey:@"inHardwareKeyboardMode"] boolValue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL isInHardwareKeyboardMode = self.isPhysicalKeyboardAttached;
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLPhysicalKeyboardAvailabilityChangedNotification
                                                        object:self
                                                      userInfo:@{NCLPhysicalKeyboardAvailabilityKey: @(isInHardwareKeyboardMode)}];
}

@end
