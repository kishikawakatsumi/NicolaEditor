//
//  NCLApplication.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/11/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLApplication.h"
#import "NCLPhysicalKeyboardManager.h"
#import "NCLConstants.h"
#import "NCLRuntimeUtils.h"

#define GSEVENT_TYPE_KEYDOWN 10
#define GSEVENT_TYPE_KEYUP 11

#define GSEVENT_TYPE 2
#define GSEVENT_SUBTYPE 3
#define GSEVENT_LOCATION 4
#define GSEVENT_WINLOCATION 6
#define GSEVENT_WINCONTEXTID 8
#define GSEVENT_TIMESTAMP 9
#define GSEVENT_WINREF 11
#define GSEVENT_FLAGS 12
#define GSEVENT_SENDERPID 13
#define GSEVENT_INFOSIZE 14

#define GSEVENTKEY_KEYCODE 15
#define GSEVENTKEY_KEYCODE_CHARIGNORINGMOD 15
#define GSEVENTKEY_CHARSET_CHARSET 16
#define GSEVENTKEY_ISKEYREPEATING 17

#define GSEVENT_TYPE_KEYDOWN 10
#define GSEVENT_TYPE_KEYUP 11
#define GSEVENT_TYPE_MODIFIERKEYDOWN 12
// 1 << 16
#define GSEVENT_FLAG_LCMD 65536
// 1 << 17
#define GSEVENT_FLAG_LSHIFT 131072
// 1 << 18
#define GSEVENT_FLAG_CAPS 262144
// 1 << 19
#define GSEVENT_FLAG_LALT 524288
// 1 << 20
#define GSEVENT_FLAG_LCTRL 1048576
// 1 << 21
#define GSEVENT_FLAG_RSHIFT 2097152
// 1 << 22
#define GSEVENT_FLAG_RALT 4194304
// 1 << 23
#define GSEVENT_FLAG_RCTRL 8388608
// 1 << 24
#define GSEVENT_FLAG_RCMD 16777216

#define KEYCODE_LSHIFT 225
#define KEYCODE_RSHIFT 229
#define KEYCODE_LCTRL 224
#define KEYCODE_LALT 226
#define KEYCODE_LCMD 227
#define KEYCODE_RCMD 231

@import ObjectiveC;

// UITouchesEvent
static Class ecdlSGPPRJ8lYtneLexG;
// UIPhysicalKeyboardEvent
static Class XNDPIT6GE263kMwAOUcr;
// handleKeyUIEvent
static NSString *puEGJ3jwuERjzDY5XQkR;
// _isKeyDown
static NSString *Fufcs7WsN2OHwyZhxh6A;
// _keyCode
static NSString *rbVU9OE7QenrQ1lYz8MW;
// - (int *)_gsEvent;
static SEL JwCnruEgQmBG2hHNkjV9;
// - (int)_modifierFlags;
static SEL VZAZO96qAh2Y3i5zjZCS;

static BOOL LSHIFT;
static BOOL RSHIFT;
static BOOL LCTRL;
//static BOOL RCTRL;
static BOOL LALT;
//static BOOL RALT;
static BOOL LCMD;
static BOOL RCMD;

@implementation NCLApplication

+ (void)initialize
{
    ecdlSGPPRJ8lYtneLexG = NSClassFromString([NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"U", @"I", @"T", @"o", @"u", @"c", @"h", @"e", @"s", @"E", @"v", @"e", @"n", @"t"]);
    XNDPIT6GE263kMwAOUcr = NSClassFromString([NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"U", @"I", @"P", @"h", @"y", @"s", @"i", @"c", @"a", @"l", @"K", @"e", @"y", @"b", @"o", @"a", @"r", @"d", @"E", @"v", @"e", @"n", @"t"]);
    puEGJ3jwuERjzDY5XQkR = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"h", @"a", @"n", @"d", @"l", @"e", @"K", @"e", @"y", @"U", @"I", @"E", @"v", @"e", @"n", @"t", @":"];
    Fufcs7WsN2OHwyZhxh6A = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", @"_", @"i", @"s", @"K", @"e", @"y", @"D", @"o", @"w", @"n"];
    rbVU9OE7QenrQ1lYz8MW = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", @"_", @"k", @"e", @"y", @"C", @"o", @"d", @"e"];
    JwCnruEgQmBG2hHNkjV9 = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", @"_", @"g", @"s", @"E", @"v", @"e", @"n", @"t"]);
    VZAZO96qAh2Y3i5zjZCS = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"_", @"m", @"o", @"d", @"i", @"f", @"i", @"e", @"r", @"F", @"l", @"a", @"g", @"s"]);
    
    {
        NSString *className = @"NCLApplication";
        NSString *original = puEGJ3jwuERjzDY5XQkR;
        NSString *replacement = @"__handleKeyEvent:";
        
        swizzleInstanceMethod(className, original, replacement);
    }
}

- (void)__handleKeyEvent:(UIEvent *)event
{
    if ([event isKindOfClass:XNDPIT6GE263kMwAOUcr]) {
        NCLPhysicalKeyboardManager *keyboardManager = [NCLPhysicalKeyboardManager sharedManager];
        if (keyboardManager.isPhysicalKeyboardAttached) {
            BOOL result = [self processEvent:event];
            if (result) {
                return;
            }
        }
    }
    
    [self __handleKeyEvent:event];
}

- (BOOL)processEvent:(UIEvent *)event
{
    BOOL result = NO;
    
    BOOL isKeyDown = [[event valueForKey:Fufcs7WsN2OHwyZhxh6A] boolValue];
    
    long long keyCode = [[event valueForKey:rbVU9OE7QenrQ1lYz8MW] longLongValue];
    UniChar *keycode = (UniChar *)&keyCode;
    UniChar key = keycode[0];
    
    int eventFlags = 0;
    if ([event respondsToSelector:VZAZO96qAh2Y3i5zjZCS]) {
        static NSInvocation *invocation = nil;
        if (!invocation) {
            NSMethodSignature *methodSignature = [event methodSignatureForSelector:VZAZO96qAh2Y3i5zjZCS];
            invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            invocation.selector = VZAZO96qAh2Y3i5zjZCS;
        }
        
        invocation.target = event;
        [invocation invoke];
        [invocation getReturnValue:&eventFlags];
    }
    
    NCLPhysicalKeyboardManager *keyboardManager = [NCLPhysicalKeyboardManager sharedManager];
    if (isKeyDown) {
        if ((eventFlags & GSEVENT_FLAG_LCTRL) != GSEVENT_FLAG_LCTRL &&
            (eventFlags & GSEVENT_FLAG_LALT) != GSEVENT_FLAG_LALT &&
            (eventFlags & GSEVENT_FLAG_LCMD) != GSEVENT_FLAG_LCMD &&
            (eventFlags & GSEVENT_FLAG_RCMD) != GSEVENT_FLAG_RCMD) {
            result = [keyboardManager downKeyCode:key];
        }
    } else {
        result = [keyboardManager upKeyCode:key];
    }
    
    return result;
}

- (void)sendEvent:(UIEvent *)event
{
    if (![event isKindOfClass:ecdlSGPPRJ8lYtneLexG]) {
        NCLPhysicalKeyboardManager *keyboardManager = [NCLPhysicalKeyboardManager sharedManager];
        if (keyboardManager.isPhysicalKeyboardAttached) {
            if ([event respondsToSelector:JwCnruEgQmBG2hHNkjV9]) {
                static NSInvocation *invocation = nil;
                if (!invocation) {
                    NSMethodSignature *methodSignature = [event methodSignatureForSelector:JwCnruEgQmBG2hHNkjV9];
                    invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                    invocation.selector = JwCnruEgQmBG2hHNkjV9;
                }
                
                int *eventMemory;
                
                invocation.target = event;
                [invocation invoke];
                [invocation getReturnValue:&eventMemory];
                
                if (eventMemory) {
                    BOOL result = NO;
                    
                    int eventType = eventMemory[GSEVENT_TYPE];
                    int eventFlags = eventMemory[GSEVENT_FLAGS];
                    
                    if (eventType == GSEVENT_TYPE_KEYDOWN) {
                        if ((eventFlags & GSEVENT_FLAG_LCTRL) != GSEVENT_FLAG_LCTRL &&
                            (eventFlags & GSEVENT_FLAG_LALT) != GSEVENT_FLAG_LALT &&
                            (eventFlags & GSEVENT_FLAG_LCMD) != GSEVENT_FLAG_LCMD &&
                            (eventFlags & GSEVENT_FLAG_RCMD) != GSEVENT_FLAG_RCMD) {
                            int tmp = eventMemory[GSEVENTKEY_KEYCODE];
                            UniChar *keycode = (UniChar *)&tmp;
                            UniChar key = keycode[0];
                            result = [keyboardManager downKeyCode:key];
                        }
                    } else if (eventType == GSEVENT_TYPE_MODIFIERKEYDOWN) {
                        if ((eventFlags & GSEVENT_FLAG_LSHIFT) == GSEVENT_FLAG_LSHIFT) {
                            LSHIFT = YES;
                            result = [keyboardManager downKeyCode:KEYCODE_LSHIFT];
                        }
                        
                        if ((eventFlags & GSEVENT_FLAG_RSHIFT) == GSEVENT_FLAG_RSHIFT) {
                            RSHIFT = YES;
                            result = [keyboardManager downKeyCode:KEYCODE_RSHIFT];
                        }
                        
                        if ((eventFlags & GSEVENT_FLAG_LCTRL) == GSEVENT_FLAG_LCTRL) {
                            LCTRL = YES;
                            result = [keyboardManager downKeyCode:KEYCODE_LCTRL];
                        }
                        
                        if ((eventFlags & GSEVENT_FLAG_LALT) == GSEVENT_FLAG_LALT) {
                            LALT = YES;
                            result = [keyboardManager downKeyCode:KEYCODE_LALT];
                        }
                        
                        if ((eventFlags & GSEVENT_FLAG_LCMD) == GSEVENT_FLAG_LCMD) {
                            LCMD = YES;
                            result = [keyboardManager downKeyCode:KEYCODE_LCMD];
                        }
                        
                        if ((eventFlags & GSEVENT_FLAG_RCMD) == GSEVENT_FLAG_RCMD) {
                            RCMD = YES;
                            result = [keyboardManager downKeyCode:KEYCODE_RCMD];
                        }
                    } else if (eventType == GSEVENT_TYPE_KEYUP) {
                        int key = eventMemory[GSEVENTKEY_KEYCODE];
                        result = [keyboardManager upKeyCode:key];
                        
                        if ((eventFlags & GSEVENT_FLAG_LSHIFT) != GSEVENT_FLAG_LSHIFT) {
                            if (LSHIFT) {
                                result = [keyboardManager upKeyCode:KEYCODE_LSHIFT];
                            }
                            LSHIFT = NO;
                        }
                        
                        if ((eventFlags & GSEVENT_FLAG_RSHIFT) != GSEVENT_FLAG_RSHIFT) {
                            if (RSHIFT) {
                                result = [keyboardManager upKeyCode:KEYCODE_RSHIFT];
                            }
                            RSHIFT = NO;
                        }
                        
                        if ((eventFlags & GSEVENT_FLAG_LCTRL) != GSEVENT_FLAG_LCTRL) {
                            if (LCTRL) {
                                result = [keyboardManager upKeyCode:KEYCODE_LCTRL];
                            }
                            LCTRL = NO;
                        }
                        
                        if ((eventFlags & GSEVENT_FLAG_LALT) != GSEVENT_FLAG_LALT) {
                            if (LALT) {
                                result = [keyboardManager upKeyCode:KEYCODE_LALT];
                            }
                            LALT = NO;
                        }
                        
                        if ((eventFlags & GSEVENT_FLAG_LCMD) != GSEVENT_FLAG_LCMD) {
                            if (LCMD) {
                                result = [keyboardManager upKeyCode:KEYCODE_LCMD];
                            }
                            LCMD = NO;
                        }
                    }
                    
                    if (result) {
                        return;
                    }
                }
            }
        }
    }
    
    [super sendEvent:event];
}

@end
