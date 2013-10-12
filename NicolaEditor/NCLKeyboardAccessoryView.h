//
//  NCLKeyboardAccessoryView.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NCLKeyboardType) {
    NCLKeyboardTypeNICOLA,
    NCLKeyboardTypeQWERTY
};

@interface NCLKeyboardAccessoryView : UIView

@property (nonatomic, weak) id delegate;

@end

@protocol NCLKeyboardAccessoryViewDelegate <NSObject>

- (void)accessoryViewDidComplete:(NCLKeyboardAccessoryView *)accessoryView;
- (void)accessoryView:(NCLKeyboardAccessoryView *)accessoryView keyboardTypeDidChange:(NSInteger)keyboardType;

@end

