//
//  main.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UI7Kit/UI7Kit.h>
#import "NCLAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [UI7Kit patchIfNeeded];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([NCLAppDelegate class]));
    }
}
