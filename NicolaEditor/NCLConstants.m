//
//  NCLConstants.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/10/17.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLConstants.h"

NSString * const NCLInstallationIdentifierKey = @"installation-identifier";

NSString * const NCLSettingsFontNameKey = @"font-name";
NSString * const NCLSettingsFontSizeKey = @"font-size";
NSString * const NCLSettingsDownloadedFontsKey = @"downloaded-fonts";

NSString * const NCLSettingsShiftKeyBehaviorKey = @"shift-key-behavior";
NSString * const NCLSettingsTimeShiftDurationKey = @"time-shift-duration";

NSString * const NCLSettingsLeftShiftFunctionKey = @"shift-key-function-left";
NSString * const NCLSettingsRightShiftFunctionKey = @"shift-key-function-right";

NSString * const NCLSettingsSwapBackspaceReturnEnabledKey = @"swap-backspase-return-enabled";

NSString * const NCLSettingsFontDidChangeNodification = @"NCLSettingsFontDidChangeNodification";

NSString * const NCLShiftKeyBehaviorTimeShift = @"Time-Shift";
NSString * const NCLShiftKeyBehaviorContinuityShift = @"Continuity-Shift";
NSString * const NCLShiftKeyBehaviorPrefixShift = @"Prefix-Shift";

NSString * const NCLShiftKeyFunctionNextCandidate = @"Next-Candidate";
NSString * const NCLShiftKeyFunctionAcceptCandidate = @"Accept-Candidate";
NSString * const NCLShiftKeyFunctionNone = @"None";

NSString * const NCLFontManagerMatchingDidBeginNotification = @"NCLFontManagerMatchingDidBeginNotification";
NSString * const NCLFontManagerMatchingDidFinishNotification = @"NCLFontManagerMatchingDidFinishNotification";
NSString * const NCLFontManagerMatchingDidFailNotification = @"NCLFontManagerMatchingDidFailNotification";
NSString * const NCLFontManagerMatchingWillBeginDownloadingNotification = @"NCLFontManagerMatchingWillBeginDownloadingNotification";
NSString * const NCLFontManagerMatchingDownloadingNotification = @"NCLFontManagerMatchingDownloadingNotification";
NSString * const NCLFontManagerMatchingDidFinishDownloadingNotification = @"NCLFontManagerMatchingDidFinishDownloadingNotification";

NSString * const NCLKeyboardInputMethodKana = @"Kana";
NSString * const NCLKeyboardInputMethodAlphabet = @"Alphabet";
NSString * const NCLKeyboardInputMethodNumberPunctuation = @"NumberPunctuation";

NSString * const NCLSettingsExternalKeyboardKey = @"external-keyboard";
NSString * const NCLSettingsExternalKeyboardLayoutKey = @"external-keyboard-layout";

NSString * const NCLKeyboardAppleWirelessKeyboardJIS = @"AppleWirelessKeyboardJIS";
NSString * const NCLKeyboardAppleWirelessKeyboardUS = @"AppleWirelessKeyboardUS";
NSString * const NCLKeyboardUserDefined = @"UserDefined";

NSString * const NCLPhysicalKeyboardAvailabilityChangedNotification = @"NCLPhysicalKeyboardAvailabilityChangedNotification";
NSString * const NCLPhysicalKeyboardAvailabilityKey = @"NCLPhysicalKeyboardAvailabilityKey";

NSString * const NCLVNCServerWillConnectNodification = @"NCLVNCServerWillConnectNodification";
NSString * const NCLVNCServerProfileKey = @"NCLVNCServerProfileKey";
