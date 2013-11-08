//
//  NCLApplication.m
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/11/08.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "NCLApplication.h"
#import "NCLPhysicalKeyboardManager.h"

#define GSMODIFIER_FLAG_LSHIFT 562949953552384
#define GSMODIFIER_FLAG_RSHIFT 2097152
#define GSMODIFIER_FLAG_LCTRL 1125899907891200
#define GSMODIFIER_FLAG_RCTRL 8388608
#define GSMODIFIER_FLAG_LALT 2251799814209536
#define GSMODIFIER_FLAG_RALT 4194304
#define GSMODIFIER_FLAG_LCMD 4503599627436032
#define GSMODIFIER_FLAG_RCMD 4503599627436032
#define GSMODIFIER_FLAG_CAPS 281474976972800

@interface PhysicalKeyboardEvent : UIEvent {//UIPhysicalButtonsEvent
    int _inputFlags;
    NSString *_modifiedInput;
    NSString *_unmodifiedInput;
    NSString *_shiftModifiedInput;
    NSString *_commandModifiedInput;
    NSString *_markedInput;
    long long _modifierFlags;
    NSString *_privateInput;
}
+ (id)_eventWithInput:(id)arg1 inputFlags:(int)arg2;
@property(retain, nonatomic) NSString *_privateInput; // @synthesize _privateInput;
@property(nonatomic) int _inputFlags; // @synthesize _inputFlags;
@property(nonatomic) long long _modifierFlags; // @synthesize _modifierFlags;
@property(retain, nonatomic) NSString *_markedInput; // @synthesize _markedInput;
@property(retain, nonatomic) NSString *_commandModifiedInput; // @synthesize _commandModifiedInput;
@property(retain, nonatomic) NSString *_shiftModifiedInput; // @synthesize _shiftModifiedInput;
@property(retain, nonatomic) NSString *_unmodifiedInput; // @synthesize _unmodifiedInput;
@property(retain, nonatomic) NSString *_modifiedInput; // @synthesize _modifiedInput;
@property(readonly, nonatomic) long long _gsModifierFlags;
- (void)_privatizeInput;
- (void)dealloc;
- (id)_cloneEvent;
- (_Bool)isEqual:(id)arg1;
- (_Bool)_matchesKeyCommand:(id)arg1;
//- (void)_setHIDEvent:(struct __IOHIDEvent *)arg1 keyboard:(struct __GSKeyboard *)arg2;
@property(readonly, nonatomic) long long _keyCode;
@property(readonly, nonatomic) _Bool _isKeyDown;
- (long long)type;
@end

@interface UIApplication (Private)

- (void)handleKeyUIEvent:(UIEvent *)event;
- (id)_keyCommandForEvent:(PhysicalKeyboardEvent *)event;
- (int *)_gsEvent;

@end

@interface UIEvent (Private)

- (int *)_gsEvent;

@end

@import ObjectiveC;

@implementation NCLApplication

- (void)handleKeyUIEvent:(UIEvent *)event
{
    [super handleKeyUIEvent:event];
    NSLog(@"%s", __func__);
    NSLog(@"%@", event);
    if ([[NCLPhysicalKeyboardManager sharedManager] isPhysicalKeyboardAttached]) {
        [self processEvent:event];
    }
}

- (void)processEvent:(PhysicalKeyboardEvent *)event
{
    NSLog(@"%s", __func__);
    NSLog(@"_privateInput: %@", [event _privateInput]);
    NSLog(@"_markedInput: %@", [event _markedInput]);
    NSLog(@"_modifiedInput: %@", [event _modifiedInput]);
    NSLog(@"_unmodifiedInput: %@", [event _unmodifiedInput]);
    NSLog(@"_shiftModifiedInput: %@", [event _shiftModifiedInput]);
    NSLog(@"_isKeyDown: %d", [event _isKeyDown]);
    NSLog(@"_modifierFlags: %lld", [event _modifierFlags]);
    NSLog(@"_inputFlags: %d", [event _inputFlags]);
    NSLog(@"_gsModifierFlags: %lld", [event _gsModifierFlags]);
//    NSLog(@"_keyCode: %lld", [event _keyCode]);
    long long _keyCode = [event _keyCode];
    UniChar *keycode = (UniChar *)&_keyCode;
    UniChar key = keycode[0];
    NSLog(@"_keyCode: %d", key);
    
//    NSLog(@"type: %lld", [event type]);
}

#define GSEVENT_TYPE 2
//#define GSEVENT_SUBTYPE 3
//#define GSEVENT_LOCATION 4
//#define GSEVENT_WINLOCATION 6
//#define GSEVENT_WINCONTEXTID 8
//#define GSEVENT_TIMESTAMP 9
//#define GSEVENT_WINREF 11
#define GSEVENT_FLAGS 12
//#define GSEVENT_SENDERPID 13
//#define GSEVENT_INFOSIZE 14

#define GSEVENTKEY_KEYCODE_CHARIGNORINGMOD 15
//#define GSEVENTKEY_CHARSET_CHARSET 16
//#define GSEVENTKEY_ISKEYREPEATING 17 // ??

#define GSEVENT_TYPE_KEYDOWN 10
#define GSEVENT_TYPE_KEYUP 11

#define GSEVENT_TYPE 2
#define GSEVENT_FLAGS 12
#define GSEVENTKEY_KEYCODE 15
#define GSEVENT_TYPE_KEYUP 11
#define GSEVENT_TYPE_KEYDOWN 10
#define GSEVENT_FLAG_LSHIFT 131072
#define GSEVENT_FLAG_RSHIFT 2097152
#define GSEVENT_FLAG_LCTRL 1048576
#define GSEVENT_FLAG_RCTRL 8388608
#define GSEVENT_FLAG_LALT 524288
#define GSEVENT_FLAG_RALT 4194304
#define GSEVENT_FLAG_LCMD 65536

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    NSLog(@"%@", NSStringFromClass(event.class));
    
    if ([event isKindOfClass:NSClassFromString(@"UITouchesEvent")]) {
        return;
    }
    
    if ([event respondsToSelector:@selector(_gsEvent)]) {
        int *eventMem;
        eventMem = [event _gsEvent];
        if (eventMem) {
            int eventType = eventMem[GSEVENT_TYPE];
            int eventFlags = eventMem[GSEVENT_FLAGS];
            NSLog(@"event flags: %i", eventFlags);
            
            if ((eventFlags & GSEVENT_FLAG_LSHIFT) == GSEVENT_FLAG_LSHIFT) {
                NSLog(@"%@ %@", @"PRESSED", @"LSHIFT");
            } else {
                NSLog(@"%@ %@", @"RELEASED", @"LSHIFT");
            }
            
            if ((eventFlags & GSEVENT_FLAG_RSHIFT) == GSEVENT_FLAG_RSHIFT) {
                NSLog(@"%@ %@", @"PRESSED", @"RSHIFT");
            } else {
                NSLog(@"%@ %@", @"RELEASED", @"RSHIFT");
            }
            
            if ((eventFlags & GSEVENT_FLAG_LCTRL) == GSEVENT_FLAG_LCTRL) {
                NSLog(@"%@ %@", @"PRESSED", @"LCTRL");
            } else {
                NSLog(@"%@ %@", @"RELEASED", @"LCTRL");
            }
            
            if ((eventFlags & GSEVENT_FLAG_RCTRL) == GSEVENT_FLAG_RCTRL) {
                NSLog(@"%@ %@", @"PRESSED", @"RCTRL");
            } else {
                NSLog(@"%@ %@", @"RELEASED", @"RCTRL");
            }
            
            if ((eventFlags & GSEVENT_FLAG_LALT) == GSEVENT_FLAG_LALT) {
                NSLog(@"%@ %@", @"PRESSED", @"LALT");
            } else {
                NSLog(@"%@ %@", @"RELEASED", @"LALT");
            }
            
            if ((eventFlags & GSEVENT_FLAG_RALT) == GSEVENT_FLAG_RALT) {
                NSLog(@"%@ %@", @"PRESSED", @"RALT");
            } else {
                NSLog(@"%@ %@", @"RELEASED", @"RALT");
            }
            
            if ((eventFlags & GSEVENT_FLAG_LCMD) == GSEVENT_FLAG_LCMD) {
                NSLog(@"%@ %@", @"PRESSED", @"LCMD");
            } else {
                NSLog(@"%@ %@", @"RELEASED", @"LCMD");
            }
            
            if (eventType == GSEVENT_TYPE_KEYUP) {
                int scancode = eventMem[GSEVENTKEY_KEYCODE];
                NSLog(@"%@ %d", @"RELEASED", scancode);
            }
            
            if (eventType == GSEVENT_TYPE_KEYDOWN) {
                int scancode = eventMem[GSEVENTKEY_KEYCODE];
                NSLog(@"%@ %d", @"PRESSED", scancode);
            }
        }
    }
}

//- (void)sendEvent:(UIEvent *)event
//{
//    [super sendEvent:event];
//    
//    if ([event respondsToSelector:@selector(_gsEvent)]) {
//        // Hardware Key events are of kind UIInternalEvent which are a wrapper of GSEventRef which is wrapper of GSEventRecord
//        int *eventMemory = (int *)[event _gsEvent];
//        if (eventMemory) {
//            int eventType = eventMemory[GSEVENT_TYPE];
//            NSLog(@"event type = %d", eventType);
//            if (eventType == GSEVENT_TYPE_KEYUP) {
//                // Since the event type is key up we can assume is a GSEventKey struct
//                // Get flags from GSEvent
//                int eventFlags = eventMemory[GSEVENT_FLAGS];
//                if (eventFlags) {
//                    NSLog(@"flags %8X", eventFlags);
//                    // Only post notifications when Shift, Ctrl, Cmd or Alt key were pressed.
//                    
//                    // Get keycode from GSEventKey
//                    int tmp = eventMemory[15];
//                    UniChar *keycode = (UniChar *)&tmp; // Cast to silent warning
//                    //tmp = (tmp & 0xFF00);
//                    //tmp = tmp >> 16;
//                    //UniChar keycode = tmp;
//                    //tmp = eventMemory[16];
//                    //tmp = (tmp & 0x00FF);
//                    //tmp = tmp << 16;
//                    //UniChar keycode = tmp;
//                    NSLog(@"keycode %d", keycode[0]);
//                    printf("Shift Ctrl Alt Cmd %d %d %d %d\n ", (eventFlags&(1<<17))?1:0, (eventFlags&(1<<18))?1:0, (eventFlags&(1<<19))?1:0, (eventFlags&(1<<20))?1:0 );
//                    
//                    /*
//                     Some Keycodes found
//                     ===================
//                     
//                     Alphabet
//                     a = 4
//                     b = 5
//                     c = ...
//                     z = 29
//                     
//                     Numbers
//                     1 = 30
//                     2 = 31
//                     3 = ...
//                     9 = 38
//                     
//                     Arrows
//                     Right = 79
//                     Left = 80
//                     Down = 81
//                     Up = 82
//                     
//                     Flags found (Differ from Kenny's header)
//                     ========================================
//                     
//                     Cmd = 1 << 17
//                     Shift = 1 << 18
//                     Ctrl = 1 << 19
//                     Alt = 1 << 20
//                     
//                     */
//                }
//            }
//        }
//    }
//}

//- (void)handleKeyUIEvent:(UIEvent *)event
//{
//    size_t s = malloc_size((__bridge const void *)(event));
//    NSLog(@"%s enter... %ld", __func__, s);
//    
//    unsigned long *ptr = (unsigned long *)(__bridge void *)event;
//
//#define OFF_KEY_MASK 12
//#define OFF_KEY_SCANCODE 15
//#define OFF_KEY_CHAR 17
//
//    NSLog(@"type: %lx off: %d", *(ptr + 2), 2);
//    NSLog(@"MASK: %lx off: %d", *(ptr + OFF_KEY_MASK), OFF_KEY_MASK);
//    NSLog(@"SCAN: %lx off: %d", *(ptr + OFF_KEY_SCANCODE), OFF_KEY_SCANCODE);
//    NSLog(@"CHAR: %lx off: %d", *(ptr + OFF_KEY_CHAR), OFF_KEY_CHAR);
//    
////    NSLog(@"sizeof unsigned long: %lx", sizeof(unsigned long));
////    
////    for (int i = 0; i < s / 4; ++i) {
////        //        NSLog(@"... [%d] = %x", i, *(unsigned char *)(ptr + i));
////        NSLog(@"... [%d] = %lx", i, *(unsigned long *)(ptr + i));
////    }
//    
//#define OFF_DUMP 8
//    
////    unsigned long *dump = (unsigned long *) *(ptr + OFF_DUMP);
////    s = malloc_size((const void *)*(ptr + OFF_DUMP));
////    
////    NSLog(@"... *[%d] size: %ld", OFF_DUMP, malloc_size((const void *)*(ptr + OFF_DUMP)));
////    
////    for (int i = 0; i < s / 4; ++i) {
////        NSLog(@"..... [%d] = %lx", i, *(unsigned long *)(dump + i));
////    }
////    
////    struct objc_super super_data = { self, [UIApplication class] };
////    objc_msgSendSuper(&super_data, @selector(handleKeyUIEvent:), event);
//    
//    [super handleKeyUIEvent:event];
//}

@end
