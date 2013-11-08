//
//  NCLConstants.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/17.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

@import Foundation;

extern NSString * const NCLInstallationIdentifierKey;

extern NSString * const NCLSettingsFontNameKey;
extern NSString * const NCLSettingsFontSizeKey;
extern NSString * const NCLSettingsDownloadedFontsKey;

extern NSString * const NCLSettingsShiftKeyBehaviorKey;
extern NSString * const NCLSettingsTimeShiftDurationKey;

extern NSString * const NCLSettingsLeftShiftFunctionKey;
extern NSString * const NCLSettingsRightShiftFunctionKey;

extern NSString * const NCLSettingsSwapBackspaceReturnEnabledKey;

extern NSString * const NCLSettingsFontDidChangeNodification;
extern NSString * const NCLSettingsShiftKeyBehaviorDidChangeNodification;
extern NSString * const NCLSettingsShiftKeyFunctionDidChangeNodification;
extern NSString * const NCLSettingsSwapBackspaceReturnEnabledDidChangeNodification;

extern NSString * const NCLShiftKeyBehaviorTimeShift;
extern NSString * const NCLShiftKeyBehaviorContinuityShift;
extern NSString * const NCLShiftKeyBehaviorPrefixShift;

extern NSString * const NCLShiftKeyFunctionNextCandidate;
extern NSString * const NCLShiftKeyFunctionAcceptCandidate;
extern NSString * const NCLShiftKeyFunctionNone;

extern NSString * const NCLFontManagerMatchingDidBeginNotification;
extern NSString * const NCLFontManagerMatchingDidFinishNotification;
extern NSString * const NCLFontManagerMatchingDidFailNotification;
extern NSString * const NCLFontManagerMatchingWillBeginDownloadingNotification;
extern NSString * const NCLFontManagerMatchingDownloadingNotification;
extern NSString * const NCLFontManagerMatchingDidFinishDownloadingNotification;

extern NSString * const NCLPhysicalKeyboardAvailabilityChangedNotification;
extern NSString * const NCLPhysicalKeyboardAvailabilityKey;
