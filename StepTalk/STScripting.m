/**
    STScripting.m
    Scripting protocol
      
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.  
  */

#import "STScripting.h"

@implementation NSObject (STScripting)
/*
- (id)replacementForScriptingInEnvironment:(STEnvironment *)env
{
    return self;
}
*/
- (BOOL)isClass
{
    return NO;
}
+ (BOOL)isClass
{
    return YES;
}

+ (NSString *)className
{
    return NSStringFromClass(self);
}
- (NSString *)className
{
    return [[self class] className];
}

/*Subclasses should override this method to force use of another class */
- (Class) classForScripting
{
    return [self class];
}
+ (Class) classForScripting
{
    return [self class];
}
@end
