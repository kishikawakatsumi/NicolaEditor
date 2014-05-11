//
//  NCLFontSettingsViewController.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/12.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLFontSettingsViewController.h"
#import "NCLSettingsViewController.h"
#import "NCLFontManager.h"
#import "NCLConstants.h"
#import "UIFont+Helper.h"
#import <FFCircularProgressView/FFCircularProgressView.h>

@import CoreText;

@interface NCLFontDownloadProgressView : UIView

@property (nonatomic) UIButton *button;
@property (nonatomic) FFCircularProgressView *progressView;
@property (nonatomic, weak) UITableViewCell *cell;
@property (nonatomic) CGFloat progress;
@property (nonatomic, weak) id delegate;

@end

@protocol NCLFontDownloadProgressViewDelegate <NSObject>

- (void)fontDownloadProgressViewStartDownload:(NCLFontDownloadProgressView *)progressView;

@end

@implementation NCLFontDownloadProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            self.progressView = [[FFCircularProgressView alloc] initWithFrame:CGRectMake(10.0, 10.0, 24.0, 24.0)];
        } else {
            self.progressView = [[FFCircularProgressView alloc] initWithFrame:CGRectMake(20.0, 10.0, 24.0, 24.0)];
        }
        
        [self addSubview:self.progressView];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = self.bounds;
        self.button.exclusiveTouch = YES;
        [self.button addTarget:self action:@selector(downloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    
    return self;
}

- (void)downloadButtonTapped:(id)sender
{
    self.button.enabled = NO;
    
    if ([self.delegate respondsToSelector:@selector(fontDownloadProgressViewStartDownload:)]) {
        [self.delegate fontDownloadProgressViewStartDownload:self];
    }
}

- (void)setProgress:(CGFloat)progress
{
    self.button.enabled = NO;
    self.progressView.progress = progress;
}

- (CGFloat)progress
{
    return self.progressView.progress;
}

- (void) startSpinProgressBackgroundLayer
{
    self.button.enabled = NO;
    [self.progressView startSpinProgressBackgroundLayer];
}

- (void) stopSpinProgressBackgroundLayer
{
    self.button.enabled = NO;
    [self.progressView stopSpinProgressBackgroundLayer];
}

@end

@interface NCLFontSettingsViewController ()

@property (nonatomic) NSArray *fontNames;
@property (nonatomic) NSArray *boldFontNames;

@end

@implementation NCLFontSettingsViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Font", nil);
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
        self.fontNames = @[@"HiraMinProN-W3", @"HiraKakuProN-W3"];
        self.boldFontNames = @[@"HiraMinProN-W6", @"HiraKakuProN-W6"];
    } else if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.fontNames = @[@"HiraMinProN-W3", @"HiraKakuProN-W3", @"HiraMaruProN-W4", @"YuMin-Medium", @"YuGo-Medium"];
        self.boldFontNames = @[@"HiraMinProN-W6", @"HiraKakuProN-W6", @"HiraMaruProN-W4", @"YuMin-Demibold", @"YuGo-Bold"];
    } else {
        self.fontNames = @[@"HiraMinProN-W3", @"HiraKakuProN-W3", @"HiraMaruProN-W4", @"YuMin-Medium", @"YuGo-Medium", @"Osaka", @"Osaka-Mono"];
        self.boldFontNames = @[@"HiraMinProN-W6", @"HiraKakuProN-W6", @"HiraMaruProN-W4", @"YuMin-Demibold", @"YuGo-Bold", @"Osaka", @"Osaka-Mono"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontManagerMatchingDidFinish:) name:NCLFontManagerMatchingDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontManagerMatchingDidFail:) name:NCLFontManagerMatchingDidFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontManagerMatchingDownloading:) name:NCLFontManagerMatchingDownloadingNotification object:nil];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fontNames.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedFontName = [userDefaults stringForKey:NCLSettingsFontNameKey];
    
    NSInteger row = indexPath.row;
    if (row < self.fontNames.count) {
        NSString *fontName = self.fontNames[row];
        
        NSInteger index = [self.fontNames indexOfObject:fontName];
        NSString *boldFontName = self.boldFontNames[index];
        
        NCLFontManager *fontManager = [NCLFontManager sharedManager];
        if ([fontManager isAvailableFontNamed:fontName] && [fontManager isAvailableFontNamed:boldFontName]) {
            if ([selectedFontName isEqualToString:fontName]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            cell.textLabel.textColor = [UIColor lightGrayColor];
            
            NCLFontDownloadProgressView *progressView = [self progressViewForFontName:fontName];
            if (!progressView) {
                progressView = [[NCLFontDownloadProgressView alloc] init];
                progressView.delegate = self;
                progressView.cell = cell;
            }
            
            if ([fontManager downloadStatusForFontNamed:fontName] == NCLFontManagerDownloadStatusDownloading) {
                CGFloat progress = [fontManager downloadProgressForFontNamed:fontName];
                if (progress > 0.0) {
                    [progressView stopSpinProgressBackgroundLayer];
                    progressView.progress = progress;
                } else {
                    [progressView startSpinProgressBackgroundLayer];
                }
            }
            
            cell.accessoryView = progressView;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSObject cancelPreviousPerformRequestsWithTarget:tableView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = NCLSettingsFontNameKey;
    
    NSInteger row = indexPath.row;
    NSString *fontName = self.fontNames[row];
    
    NSInteger index = [self.fontNames indexOfObject:fontName];
    NSString *boldFontName = self.boldFontNames[index];
    
    if ([[NCLFontManager sharedManager] isAvailableFontNamed:fontName] && [[NCLFontManager sharedManager] isAvailableFontNamed:boldFontName]) {
        [userDefaults setObject:fontName forKey:key];
        [userDefaults synchronize];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NCLSettingsFontDidChangeNodification object:nil];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)startDownloadFontNamed:(NSString *)fontName
{
    NSInteger index = [self.fontNames indexOfObject:fontName];
    if (index != NSNotFound) {
        NSString *boldFontName = self.boldFontNames[index];
        
        NCLFontManager *fontManager = [NCLFontManager sharedManager];
        if (![boldFontName isEqualToString:fontName]) {
            [fontManager enqueueDownloadWithFontNames:@[fontName, boldFontName]];
        } else {
            [fontManager enqueueDownloadWithFontName:fontName];
        }
    }
}

- (NCLFontDownloadProgressView *)progressViewForFontName:(NSString *)fontName
{
    NSInteger index = [self.fontNames indexOfObject:fontName];
    if (index != NSNotFound) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        return (NCLFontDownloadProgressView *)cell.accessoryView;
    }
    
    return nil;
}

- (void)fontDownloadProgressViewStartDownload:(NCLFontDownloadProgressView *)progressView
{
    [progressView startSpinProgressBackgroundLayer];
    
    UITableViewCell *cell = progressView.cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSInteger row = indexPath.row;
    NSString *fontName = self.fontNames[row];
    
    [self startDownloadFontNamed:fontName];
}

- (void)fontManagerMatchingDidFinish:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *name = userInfo[@"name"];
    
    NCLFontDownloadProgressView *progressView = [self progressViewForFontName:name];
    [progressView stopSpinProgressBackgroundLayer];
    progressView.progress = 1.0;
    
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:1.0];
}

- (void)fontManagerMatchingDidFail:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)fontManagerMatchingDownloading:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *name = userInfo[@"name"];
    
    NCLFontDownloadProgressView *progressView = [self progressViewForFontName:name];
    progressView.progress = [userInfo[@"progress"] doubleValue];
    if (progressView.progress > 0.0) {
        [progressView stopSpinProgressBackgroundLayer];
    }
}

@end
