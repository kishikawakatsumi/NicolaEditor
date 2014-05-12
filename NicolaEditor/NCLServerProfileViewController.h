//
//  NCLServerProfileViewController.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2014/05/12.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerProfile;

@interface NCLServerProfileViewController : UIViewController

@property (nonatomic, weak) id delegate;

@property (nonatomic) NSURL *savedURL;
@property (nonatomic) ServerProfile *serverProfile;

@end

@protocol NCLServerProfileViewControllerDelegate <NSObject>

- (void)serverProfileViewControllerSaveSuccessful:(NCLServerProfileViewController *)controller;

@end
