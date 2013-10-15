//
//  NCLAppDelegate.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLAppDelegate.h"
#import "NCLNote.h"
#import "NCLKeyboardView.h"
#import "NSString+Helper.h"
#import <NLCoreData/NLCoreData.h>
#import <TestFlightSDK/TestFlight.h>

@implementation NCLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"7a1ada1b-6b67-4907-af62-ee07d5387caa"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"font-name": @"HiraMinProN-W3", @"font-size": @(18.0), @"shift-key-behavior": NCLKeyboardShiftKeyBehaviorTimeShift, @"time-shift-duration": @(0.1), @"shift-key-function-left": NCLKeyboardShiftKeyFunctionNextCandidate, @"shift-key-function-right": NCLKeyboardShiftKeyFunctionAcceptCandidate}];
    
    if (![[NSUserDefaults standardUserDefaults] stringForKey:@"installation-identifier"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString UUIDString] forKey:@"installation-identifier"];
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSData *data = [NSData dataWithContentsOfURL:[mainBundle URLForResource:@"SampleText" withExtension:@"json"]];
        NSArray *samples = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        for (NSString *sample in samples) {
            NCLNote *note = [NCLNote insertInContext:[NSManagedObjectContext mainContext]];
            
            __block NSString *title = nil;
            [sample enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                title = line;
                *stop = YES;
            }];
            
            note.title = title;
            note.content = sample;
            
            [note.managedObjectContext saveNested];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [[UIToolbar appearance] setBackgroundImage:[[UIImage imageNamed:@"toolbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsZero] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        if ([UIToolbar instancesRespondToSelector:@selector(setShadowImage:forToolbarPosition:)]) {
            [[UIToolbar appearance] setShadowImage:[UIImage imageNamed:@"clear"] forToolbarPosition:UIBarPositionAny];
        }
    }
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = splitViewController.viewControllers.lastObject;
    splitViewController.delegate = (id)navigationController.topViewController;
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSManagedObjectContext mainContext] saveNested];
}

@end
