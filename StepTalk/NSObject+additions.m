/**
    NSObject-additions.m
    Various methods for NSObject
  
    This file is part of the StepTalk project.
 
 */

#import "NSObject+additions.h"

#import <Foundation/NSException.h>

@implementation NSObject (STAdditions)
- (BOOL)isSame:(id)anObject
{
    return self == anObject;
}
- (BOOL)isNil
{
    return NO;
}
- (BOOL)notNil
{
    return YES;
}

- (void)notImplemented:(SEL)sel
{
    [NSException raise:@"InitNotImplemented"
                format:@"Method '%s' not implemented", sel_getName(sel)];
}
- (void)subclassResponsibility:(SEL)sel {
    [NSException raise:@"InitNotImplemented"
                format:@"Method '%s' is required", sel_getName(sel)];
}


@end

