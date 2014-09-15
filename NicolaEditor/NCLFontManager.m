//
//  NCLFontManager.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/26.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLFontManager.h"
#import "NCLConstants.h"

@import CoreText;

@interface NCLFontDownload : NSObject

@property (nonatomic, readonly) NSString *fontName;
@property (nonatomic, readonly) NSURL *fontURL;
@property (nonatomic, getter = isDownloading) BOOL downloading;
@property (nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, readonly) CGFloat progress;
@property (nonatomic, weak) id delegate;

@end

@interface NCLFontDownloadGroup : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic, readonly) NSMutableArray *downloads;
@property (nonatomic, readonly) NCLFontDownload *currentDownload;
@property (nonatomic, getter = isDownloading) BOOL downloading;
@property (nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, readonly) CGFloat progress;
@property (nonatomic, weak) id delegate;

@end

@protocol NCLFontDownloadDelegate <NSObject>

- (void)downloadMatchingDidBegin:(NCLFontDownload *)download;
- (void)downloadMatchingDidFinish:(NCLFontDownload *)download;
- (void)download:(NCLFontDownload *)download matchingDidFailWithError:(NSError *)error;

- (void)downloadMatchingWillBeginDownloading:(NCLFontDownload *)download;
- (void)downloadMatchingDownloading:(NCLFontDownload *)download progress:(CGFloat)progress;
- (void)downloadMatchingDidFinishDownloading:(NCLFontDownload *)download;

@end

@protocol NCLFontDownloadGroupDelegate <NSObject>

- (void)downloadGroupMatchingDidBegin:(NCLFontDownloadGroup *)group;
- (void)downloadGroupMatchingDidFinish:(NCLFontDownloadGroup *)group;
- (void)downloadGroup:(NCLFontDownloadGroup *)group matchingDidFailWithError:(NSError *)error;

- (void)downloadGroupMatchingWillBeginDownloading:(NCLFontDownloadGroup *)group;
- (void)downloadGroupMatchingDownloading:(NCLFontDownloadGroup *)group progress:(CGFloat)progress;
- (void)downloadGroupMatchingDidFinishDownloading:(NCLFontDownloadGroup *)group;

@end

@implementation NCLFontDownload

- (id)initWithFontName:(NSString *)fontName
{
    self = [super init];
    if (self) {
        _fontName = fontName;
    }
    
    return self;
}

- (void)startDownload
{
    NSString *fontName = self.fontName;
    NSDictionary *attributes = @{(id)kCTFontNameAttribute: fontName};
    
	CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attributes);
    NSArray *fontDescriptors = @[(__bridge id)fontDescriptor];
    CFRelease(fontDescriptor);
    
	__block BOOL errorDuringDownload = NO;
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef)fontDescriptors, NULL, ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        NSDictionary *parameter = (__bridge NSDictionary *)progressParameter;
		double progressValue = [parameter[(id)kCTFontDescriptorMatchingPercentage] doubleValue];
		
		if (state == kCTFontDescriptorMatchingDidBegin) {
			dispatch_async( dispatch_get_main_queue(), ^ {
                if ([self.delegate respondsToSelector:@selector(downloadMatchingDidBegin:)]) {
                    [self.delegate downloadMatchingDidBegin:self];
                }
			});
		} else if (state == kCTFontDescriptorMatchingDidFinish) {
            _downloading = NO;
            _finished = YES;
            
            if (errorDuringDownload) {
                if ([self.delegate respondsToSelector:@selector(download:matchingDidFailWithError:)]) {
                    [self.delegate download:self matchingDidFailWithError:nil];
                }
                return (bool)NO;
            }
            
            UIFont *font = [UIFont fontWithName:fontName size:1.0];
            if (!font) {
                if ([self.delegate respondsToSelector:@selector(download:matchingDidFailWithError:)]) {
                    [self.delegate download:self matchingDidFailWithError:nil];
                }
                return (bool)NO;
            }
            
            CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, 0.0, NULL);
            CFURLRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *dowloadedFonts = [[userDefaults objectForKey:NCLSettingsDownloadedFontsKey] mutableCopy];
            if (!dowloadedFonts) {
                dowloadedFonts = [[NSMutableDictionary alloc] init];
            }
            dowloadedFonts[fontName] = ((__bridge NSURL *)fontURL).absoluteString;
            [userDefaults setObject:dowloadedFonts forKey:NCLSettingsDownloadedFontsKey];
            [userDefaults synchronize];
            
            CFRelease(fontURL);
            CFRelease(fontRef);
            
			dispatch_async( dispatch_get_main_queue(), ^ {
                if ([self.delegate respondsToSelector:@selector(downloadMatchingDidFinish:)]) {
                    [self.delegate downloadMatchingDidFinish:self];
                }
			});
		} else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            _downloading = YES;
            
			dispatch_async( dispatch_get_main_queue(), ^ {
                if ([self.delegate respondsToSelector:@selector(downloadMatchingWillBeginDownloading:)]) {
                    [self.delegate downloadMatchingWillBeginDownloading:self];
                }
			});
		} else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
			dispatch_async( dispatch_get_main_queue(), ^ {
                if ([self.delegate respondsToSelector:@selector(downloadMatchingDidFinishDownloading:)]) {
                    [self.delegate downloadMatchingDidFinishDownloading:self];
                }
			});
		} else if (state == kCTFontDescriptorMatchingDownloading) {
			dispatch_async( dispatch_get_main_queue(), ^ {
                _progress = progressValue;
                if ([self.delegate respondsToSelector:@selector(downloadMatchingDownloading:progress:)]) {
                    [self.delegate downloadMatchingDownloading:self progress:progressValue];
                }
			});
		} else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            errorDuringDownload = YES;
            NSError *error = [(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingError];
            
            dispatch_async( dispatch_get_main_queue(), ^ {
                if ([self.delegate respondsToSelector:@selector(download:matchingDidFailWithError:)]) {
                    [self.delegate download:self matchingDidFailWithError:error];
                }
			});
		}
        
		return (bool)YES;
	});
}

@end

@implementation NCLFontDownloadGroup

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
        _downloads = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (CGFloat)progress
{
    CGFloat progress = 0.0;
    
    if (self.downloads.count == 0) {
        return progress;
    }
    
    for (NCLFontDownload *download in self.downloads) {
        progress += download.progress;
    }
    
    return progress / self.downloads.count;
}

- (void)addDownload:(NCLFontDownload *)download
{
    [self.downloads addObject:download];
}

- (void)startDownload
{
    NCLFontDownload *download = [self nextDownload];
    if (download) {
        _downloading = YES;
        
        download.delegate = self;
        [download startDownload];
        
        _currentDownload = download;
    }
}

- (NCLFontDownload *)nextDownload
{
    for (NCLFontDownload *download in self.downloads) {
        if (!download.isDownloading && !download.isFinished) {
            return download;
        }
    }
    
    return nil;
}

- (void)downloadMatchingDidBegin:(NCLFontDownload *)download
{
    if ([self.delegate respondsToSelector:@selector(downloadGroupMatchingDidBegin:)]) {
        [self.delegate downloadGroupMatchingDidBegin:self];
    }
}

- (void)downloadMatchingDidFinish:(NCLFontDownload *)download
{
    NCLFontDownload *nextDownload = [self nextDownload];
    
    if (nextDownload) {
        nextDownload.delegate = self;
        [nextDownload startDownload];
        
        _currentDownload = nextDownload;
    } else {
        _downloading = NO;
        _finished = YES;
        
        if ([self.delegate respondsToSelector:@selector(downloadGroupMatchingDidFinish:)]) {
            [self.delegate downloadGroupMatchingDidFinish:self];
        }
    }
}

- (void)download:(NCLFontDownload *)download matchingDidFailWithError:(NSError *)error
{
    _downloading = NO;
    _finished = NO;
    
    if ([self.delegate respondsToSelector:@selector(downloadGroup:matchingDidFailWithError:)]) {
        [self.delegate downloadGroup:self matchingDidFailWithError:error];
    }
}

- (void)downloadMatchingWillBeginDownloading:(NCLFontDownload *)download
{
    if ([self.delegate respondsToSelector:@selector(downloadGroupMatchingWillBeginDownloading:)]) {
        [self.delegate downloadGroupMatchingWillBeginDownloading:self];
    }
}

- (void)downloadMatchingDownloading:(NCLFontDownload *)download progress:(CGFloat)progress
{
    if ([self.delegate respondsToSelector:@selector(downloadGroupMatchingDownloading:progress:)]) {
        [self.delegate downloadGroupMatchingDownloading:self progress:self.progress];
    }
}

- (void)downloadMatchingDidFinishDownloading:(NCLFontDownload *)download
{
    if ([self.delegate respondsToSelector:@selector(downloadGroupMatchingDidFinishDownloading:)]) {
        [self.delegate downloadGroupMatchingDidFinishDownloading:self];
    }
}

@end

@interface NCLFontManager ()

@property (nonatomic) NSMutableArray *downloadQueue;
@property (nonatomic) NCLFontDownloadGroup *currentDownload;

@end

@implementation NCLFontManager

+ (instancetype)sharedManager
{
    static NCLFontManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[NCLFontManager alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.downloadQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)isAvailableFontNamed:(NSString *)fontName
{
    UIFont *font = [UIFont fontWithName:fontName size:1.0];
    return font && ([font.fontName compare:fontName] == NSOrderedSame || [font.familyName compare:fontName] == NSOrderedSame);
}

- (NCLFontManagerDownloadStatus)downloadStatusForFontNamed:(NSString *)fontName
{
    NCLFontDownloadGroup *group = [self downloadGroupWithFontName:fontName];
    if (!group) {
        return NCLFontManagerDownloadStatusNone;
    }
    if (!group.isDownloading && group.isFinished) {
        return NCLFontManagerDownloadStatusFinished;
    }
    
    return NCLFontManagerDownloadStatusDownloading;
}

- (CGFloat)downloadProgressForFontNamed:(NSString *)fontName
{
    NCLFontDownloadGroup *group = [self downloadGroupWithFontName:fontName];
    return group.progress / 100.0;
}

- (void)enqueueDownloadWithFontName:(NSString *)fontName
{
    [self enqueueDownloadWithFontNames:@[fontName]];
}

- (void)enqueueDownloadWithFontNames:(NSArray *)fontNames
{
    NCLFontDownloadGroup *group = [self downloadGroupWithFontName:fontNames.firstObject];
    if (!group) {
        group = [[NCLFontDownloadGroup alloc] initWithName:fontNames.firstObject];
        for (NSString *fontName in fontNames) {
            [group addDownload:[[NCLFontDownload alloc] initWithFontName:fontName]];
        }
        
        [self.downloadQueue addObject:group];
    }
    
    [self startNextDownload];
}

- (void)loadDownloadedFontNamed:(NSString *)fontName
{
    NSDictionary *attributes = @{(id)kCTFontNameAttribute: fontName};
    
	CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attributes);
    NSArray *fontDescriptors = @[(__bridge id)fontDescriptor];
    CFRelease(fontDescriptor);
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef)fontDescriptors, NULL, ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        if (state == kCTFontDescriptorMatchingDidFinish) {
			dispatch_async( dispatch_get_main_queue(), ^ {
                UIFont *font = [UIFont fontWithName:fontName size:1.0];
                if (font) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NCLFontManagerMatchingDidFinishNotification object:self userInfo:@{@"name": fontName}];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NCLSettingsFontDidChangeNodification object:self userInfo:nil];
                }
			});
		} else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            return (bool)NO;
		}
        
		return (bool)YES;
    });
}

- (NCLFontDownloadGroup *)downloadGroupWithFontName:(NSString *)fontName
{
    for (NCLFontDownloadGroup *group in self.downloadQueue) {
        if ([group.name isEqualToString:fontName]) {
            return group;
        }
    }
    
    return nil;
}

- (void)startNextDownload
{
    if (!self.currentDownload) {
        self.currentDownload = self.downloadQueue.firstObject;
    }
    
    if (!self.currentDownload.isDownloading && !self.currentDownload.isFinished) {
        self.currentDownload.delegate = self;
        [self.currentDownload startDownload];
    }
}

- (void)downloadGroupMatchingDidBegin:(NCLFontDownloadGroup *)group
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLFontManagerMatchingDidBeginNotification object:self userInfo:@{@"name": group.name}];
}

- (void)downloadGroupMatchingDidFinish:(NCLFontDownloadGroup *)group
{
    [self.downloadQueue removeObject:group];
    self.currentDownload = nil;
    
    [self startNextDownload];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLFontManagerMatchingDidFinishNotification object:self userInfo:@{@"name": group.name}];
}

- (void)downloadGroup:(NCLFontDownloadGroup *)group matchingDidFailWithError:(NSError *)error
{
    [self.downloadQueue removeObject:group];
    self.currentDownload = nil;
    
    [self startNextDownload];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLFontManagerMatchingDidFailNotification object:self userInfo:@{@"name": group.name}];
}

- (void)downloadGroupMatchingWillBeginDownloading:(NCLFontDownloadGroup *)group
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLFontManagerMatchingWillBeginDownloadingNotification object:self userInfo:@{@"name": group.name}];
}

- (void)downloadGroupMatchingDownloading:(NCLFontDownloadGroup *)group progress:(CGFloat)progress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLFontManagerMatchingDownloadingNotification object:self userInfo:@{@"name": group.name, @"progress": @(progress / 100.0)}];
}

- (void)downloadGroupMatchingDidFinishDownloading:(NCLFontDownloadGroup *)group
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NCLFontManagerMatchingDidFinishDownloadingNotification object:self userInfo:@{@"name": group.name}];
}

@end
