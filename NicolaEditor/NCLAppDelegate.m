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
#import "NCLConstants.h"
#import <NLCoreData/NLCoreData.h>
#import <Evernote-SDK-iOS/EvernoteSDK.h>
#import <DropboxSDK/DropboxSDK.h>
#import <Helpshift/Helpshift.h>
#import <TestFlightSDK/TestFlight.h>
#import <BugSense-iOS/BugSenseController.h>

static NSString * const EvernoteConsumerKey = @"kishikawakatsumi";
static NSString * const EvernoteConsumerSecret = @"a54f2575488374bd";

static NSString * const DropboxAppKey = @"jnt8gm2oa7oa1no";
static NSString * const DropboxAppSecret = @"ki02ksylrv77a7y";

@implementation NCLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Helpshift installForAppID:@"kishikawakatsumi_platform_20131012163756079-96d13f062d21544" domainName:@"kishikawakatsumi.helpshift.com" apiKey:@"6a56e092c74a8d0f5e08eef8441a61b3"];
    [TestFlight takeOff:@"7a1ada1b-6b67-4907-af62-ee07d5387caa"];
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"93a70013"];
    
    [EvernoteSession setSharedSessionHost:BootstrapServerBaseURLStringSandbox consumerKey:EvernoteConsumerKey consumerSecret:EvernoteConsumerSecret];
    
    DBSession* session = [[DBSession alloc] initWithAppKey:DropboxAppKey appSecret:DropboxAppSecret root:kDBRootAppFolder];
    [DBSession setSharedSession:session];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{NCLSettingsFontNameKey: @"HiraMinProN-W3",
                                                              NCLSettingsFontSizeKey: @(14.0),
                                                              NCLSettingsShiftKeyBehaviorKey: NCLShiftKeyBehaviorTimeShift,
                                                              NCLSettingsTimeShiftDurationKey: @(0.1),
                                                              NCLSettingsLeftShiftFunctionKey: NCLShiftKeyFunctionNextCandidate,
                                                              NCLSettingsRightShiftFunctionKey: NCLShiftKeyFunctionAcceptCandidate,
                                                              NCLSettingsSwapBackspaceReturnEnabledKey: @NO}];
    
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
    
    [self prepareForiCloud];
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = splitViewController.viewControllers.lastObject;
    splitViewController.delegate = (id)navigationController.topViewController;
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[EvernoteSession sharedSession] handleDidBecomeActive];
    [[NSManagedObjectContext mainContext] saveNested];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSManagedObjectContext mainContext] saveNested];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSManagedObjectContext mainContext] saveNested];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSManagedObjectContext mainContext] saveNested];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSManagedObjectContext mainContext] saveNested];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL canHandle = NO;
    
    EvernoteSession *session = [EvernoteSession sharedSession];
    if ([[NSString stringWithFormat:@"en-%@", session.consumerKey] isEqualToString:url.scheme]) {
        canHandle = [session canHandleOpenURL:url];
    }
    
    DBSession *sharedSession = [DBSession sharedSession];
    if ([sharedSession.appScheme isEqualToString:url.scheme]) {
        canHandle = [sharedSession handleOpenURL:url];
    }
    
    return canHandle;
}

- (void)prepareForiCloud
{
    NLCoreData *shared = [NLCoreData shared];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChangesFromiCloud:)
                                                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object:shared.storeCoordinator];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        NSDictionary *persistentStoreOptions = nil;
        
        NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:@"27AEDK3C9F.com.kishikawakatsumi.NicolaEditor"];
        NSString *contentPath = [cloudURL.path stringByAppendingPathComponent:@"data"];
        if (contentPath.length > 0) {
            cloudURL = [NSURL fileURLWithPath:contentPath];
            
            
            persistentStoreOptions = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                       NSInferMappingModelAutomaticallyOption: @YES,
                                       NSPersistentStoreUbiquitousContentNameKey: [NSString stringWithFormat:@"%@.store", shared.modelName],
                                       NSPersistentStoreUbiquitousContentURLKey: cloudURL};
        } else {
            persistentStoreOptions = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                       NSInferMappingModelAutomaticallyOption: @YES};
        }
        
        shared.persistentStoreOptions = persistentStoreOptions;
        
    });
}

- (void)mergeChangesFromiCloud:(NSNotification *)notification
{
	NSManagedObjectContext *mainContext = [NSManagedObjectContext mainContext];
    [mainContext performBlock:^{
        [mainContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

@end
