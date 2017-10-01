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
@property (nonatomic) NCLKeyboardType keyboardType;

@end

@protocol NCLKeyboardAccessoryViewDelegate <NSObject>

- (void)accessoryView:(NCLKeyboardAccessoryView *)accessoryView keyboardTypeDidChange:(NSInteger)keyboardType;
- (void)accessoryViewDidComplete:(NCLKeyboardAccessoryView *)accessoryView;

- (void)accessoryViewArrowUp:(NCLKeyboardAccessoryView *)accessoryView;
- (void)accessoryViewArrowDown:(NCLKeyboardAccessoryView *)accessoryView;
- (void)accessoryViewArrowLeft:(NCLKeyboardAccessoryView *)accessoryView;
- (void)accessoryViewArrowRight:(NCLKeyboardAccessoryView *)accessoryView;

- (void)accessoryViewCut:(NCLKeyboardAccessoryView *)accessoryView;
- (void)accessoryViewCopy:(NCLKeyboardAccessoryView *)accessoryView;
- (void)accessoryViewPaste:(NCLKeyboardAccessoryView *)accessoryView;

@end

