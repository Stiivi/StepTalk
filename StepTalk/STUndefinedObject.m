/**
    STUndefinedObject.m
    Wrapper for nil object
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 
 */
#import "STUndefinedObject.h"

#import "STExterns.h"
#import "STObjCRuntime.h"

#import <Foundation/NSString.h>

STUndefinedObject *STNil = nil;

@implementation STUndefinedObject
+ (id) alloc
{
    return STNil;
}

+ (id) allocWithZone: (NSZone*)z
{
    return STNil;
}

+ (id) autorelease
{
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature = nil;
    
    signature = [super methodSignatureForSelector:sel];

    if(!signature)
    {
        signature = STConstructMethodSignatureForSelector(sel);
    }

    return signature;
}

- (void) forwardInvocation: (NSInvocation*)anInvocation
{
    /* this object is deaf */
}

- (BOOL) isEqual: (id)anObject
{
    return ( (self == anObject) || (anObject == nil) );
}

- (BOOL)isNil
{
    return YES;
}

- (BOOL)notNil
{
    return NO;
}
@end

