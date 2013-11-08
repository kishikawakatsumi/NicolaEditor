//
//  NCLKeyboardManager.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/11/09.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCLPhysicalKeyboardManager : NSObject

@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, readonly, getter = isPhysicalKeyboardAttached) BOOL physicalKeyboardAttached;

+ (instancetype)sharedManager;
- (BOOL)isPhysicalKeyboardAttached;

@end
