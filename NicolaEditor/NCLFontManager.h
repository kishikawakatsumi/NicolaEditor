//
//  NCLFontManager.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/26.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, NCLFontManagerDownloadStatus) {
    NCLFontManagerDownloadStatusNone,
    NCLFontManagerDownloadStatusDownloading,
    NCLFontManagerDownloadStatusFinished = NCLFontManagerDownloadStatusNone
};

@interface NCLFontManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)isAvailableFontNamed:(NSString *)fontName;
- (NCLFontManagerDownloadStatus)downloadStatusForFontNamed:(NSString *)fontName;
- (CGFloat)downloadProgressForFontNamed:(NSString *)fontName;

- (void)enqueueDownloadWithFontName:(NSString *)fontName;
- (void)enqueueDownloadWithFontNames:(NSArray *)fontNames;

- (void)loadDownloadedFontNamed:(NSString *)fontName;

@end
