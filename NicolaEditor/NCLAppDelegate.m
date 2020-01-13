//
//  NCLAppDelegate.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLAppDelegate.h"
#import "NCLFontManager.h"
#import "NCLConstants.h"
#import "NCLNote+Helper.h"
#import "NSString+Helper.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <JLRoutes/JLRoutes.h>
#import <NLCoreData/NLCoreData.h>
#import <EvernoteSDK/EvernoteSDK.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import <uservoice-iphone-sdk/UserVoice.h>

@import CoreText;

static NSString * const EvernoteConsumerKey = @"kishikawakatsumi";
static NSString * const EvernoteConsumerSecret = @"a54f2575488374bd";

static NSString * const DropboxAppKey = @"jnt8gm2oa7oa1no";
static NSString * const DropboxAppSecret = @"ki02ksylrv77a7y";

@implementation NCLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];

    UVConfig *config = [UVConfig configWithSite:@"kishikawakatsumi.uservoice.com"];
    config.forumId = 251764;
    [UserVoice initialize:config];

    [ENSession setSharedSessionConsumerKey:EvernoteConsumerKey consumerSecret:EvernoteConsumerSecret optionalHost:nil];

    [DBClientsManager setupWithAppKey:DropboxAppKey];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{NCLSettingsFontNameKey: @"HiraMinProN-W3",
                                     NCLSettingsFontSizeKey: @(14.0),
                                     NCLSettingsShiftKeyBehaviorKey: NCLShiftKeyBehaviorTimeShift,
                                     NCLSettingsTimeShiftDurationKey: @(0.15),
                                     NCLSettingsLeftShiftFunctionKey: NCLShiftKeyFunctionAcceptCandidate,
                                     NCLSettingsRightShiftFunctionKey: NCLShiftKeyFunctionNextCandidate,
                                     NCLSettingsSwapBackspaceReturnEnabledKey: @NO,
                                     NCLSettingsExternalKeyboardKey: NCLKeyboardAppleWirelessKeyboardJIS,
                                     NCLSettingsExternalKeyboardLayoutKey: @"NICOLA"}];
    
    NSDictionary *downloadedFonts = [userDefaults valueForKey:NCLSettingsDownloadedFontsKey];
    for (NSString *downloadedFontName in downloadedFonts.allKeys) {
        [[NCLFontManager sharedManager] loadDownloadedFontNamed:downloadedFontName];
    }
    
    if (![userDefaults stringForKey:NCLInstallationIdentifierKey]) {
        [userDefaults setObject:[NSString UUIDString] forKey:NCLInstallationIdentifierKey];
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSData *data = [NSData dataWithContentsOfURL:[mainBundle URLForResource:@"SampleText" withExtension:@"json"]];
        NSArray *samples = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        for (NSString *sample in samples) {
            [NCLNote insertNewNoteWithContent:sample];
        }
    }
    [userDefaults synchronize];
    
    [self exportUserDefinedKayboardLayout];
    [self prepareForiCloud];

    [[JLRoutes globalRoutes] addRoute:@"/:object/:action" handler:^BOOL(NSDictionary *parameters) {
        NSString *object = parameters[@"object"];
        NSString *action = parameters[@"action"];
        
        if ([object isEqualToString:@"note"] && [action isEqualToString:@"new"]) {
            NSString *content = parameters[@"content"];
            [NCLNote insertNewNoteWithContent:content];
            
            return YES;
        }
        return NO;
    }];
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = splitViewController.viewControllers.lastObject;
    splitViewController.delegate = (id)navigationController.topViewController;
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
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

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    BOOL canHandle = NO;

    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult) {
        if ([authResult isSuccess]) {
            canHandle = YES;
        } else if ([authResult isCancel]) {
            canHandle = NO;
        } else if ([authResult isError]) {
            canHandle = NO;
        }
    } else {
        canHandle = NO;
    }

    if (url.isFileURL) {
        NSError *error = nil;
        NSString *text = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (text.length > 0 &&!error) {
            [NCLNote insertNewNoteWithContent:text];
        }
    }

    canHandle = [JLRoutes routeURL:url];

    return canHandle;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL canHandle = NO;

    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult) {
        if ([authResult isSuccess]) {
            canHandle = YES;
        } else if ([authResult isCancel]) {
            canHandle = NO;
        } else if ([authResult isError]) {
            canHandle = NO;
        }
    } else {
        canHandle = NO;
    }
    
    if (url.isFileURL) {
        NSError *error = nil;
        NSString *text = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (text.length > 0 &&!error) {
            [NCLNote insertNewNoteWithContent:text];
        }
    }
    
    canHandle = [JLRoutes routeURL:url];
    
    return canHandle;
}

#pragma mark -

- (void)exportUserDefinedKayboardLayout
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths.lastObject;
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"UserDefined.json"];
    
    if (![self filesExistsAtPath:path]) {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"AppleWirelessKeyboardJIS" ofType:@"json"] toPath:path error:nil];
    }
}

- (BOOL)filesExistsAtPath:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (!isDirectory) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -

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
