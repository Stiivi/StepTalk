/**
    STObjCRuntime.m
    Objective C runtime additions 
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 
 */

#import <Foundation/NSObject.h>

@class NSMutableDictionary;
@class NSString;
@class NSValue;
@class NSMethodSignature;
@class NSDictionary;
@class NSArray;

extern NSMutableDictionary *STAllObjectiveCClasses(void);
extern NSMutableDictionary *STGetFoundationConstants(void);
extern NSDictionary        *STClassDictionaryWithNames(NSArray *classNames);
extern NSArray             *STAllObjectiveCSelectors(void);

extern NSValue           *STValueFromSelector(SEL sel);
extern SEL                STSelectorFromValue(NSValue *val);
extern SEL                STSelectorFromString(NSString *aString);
extern NSMethodSignature *STConstructMethodSignatureForSelector(SEL sel);

/* Deprecated - remove */
extern NSMethodSignature *STMethodSignatureForSelector(SEL sel);

