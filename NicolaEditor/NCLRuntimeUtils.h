//
//  NCLRuntimeUtils.h
//  NicolaEditor
//
//  Created by kishikawa katsumi on 2013/11/10.
//  Copyright (c) 2013年 kishikawa katsumi. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

static inline void swizzleClassMethod(NSString *className, NSString *original, NSString *replacement)
{
    Class c = NSClassFromString(className);
    SEL orig = NSSelectorFromString(original);
    SEL rep = NSSelectorFromString(replacement);
    Method originalMethod = class_getClassMethod(c, orig);
    Method replacementMethod = class_getClassMethod(c, rep);
    method_exchangeImplementations(originalMethod, replacementMethod);
}

static inline void swizzleInstanceMethod(NSString *className, NSString *original, NSString *replacement)
{
    Class c = NSClassFromString(className);
    SEL orig = NSSelectorFromString(original);
    SEL rep = NSSelectorFromString(replacement);
    Method originalMethod = class_getInstanceMethod(c, orig);
    Method replacementMethod = class_getInstanceMethod(c, rep);
    method_exchangeImplementations(originalMethod, replacementMethod);
}

static inline void _addMethod(Class c, NSString *selector, id block, NSString *sig)
{
    SEL sel = NSSelectorFromString(selector);
    IMP imp = imp_implementationWithBlock(block);
    class_addMethod(c, sel, imp, sig.UTF8String);
}

static inline void addClassMethod(NSString *className, NSString *selector, id block, NSString *signature)
{
    Class metaClass = objc_getMetaClass([className UTF8String]);
    _addMethod(metaClass, selector, block, signature);
}

static inline void addInstanceMethod(NSString *className, NSString *selector, id block, NSString *signature)
{
    Class clazz = NSClassFromString(className);
    _addMethod(clazz, selector, block, signature);
}
