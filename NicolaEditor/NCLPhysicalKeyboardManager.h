//
//  NCLKeyboardManager.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/11/09.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NCLKeyboardView;

@interface NCLPhysicalKeyboardManager : NSObject

@property (nonatomic, weak) NCLKeyboardView *keyboardView;
@property (nonatomic, readonly, getter = isPhysicalKeyboardAttached) BOOL physicalKeyboardAttached;

@property (nonatomic) NSString *keyboardInputMethod;

+ (instancetype)sharedManager;
- (BOOL)isPhysicalKeyboardAttached;

- (BOOL)downKeyCode:(NSInteger)keyCode;
- (BOOL)upKeyCode:(NSInteger)keyCode;

@end
