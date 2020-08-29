/**
    STScripting.h
    Scripting protocol
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 */

#import <Foundation/NSObject.h>

@class STEnvironment;

@protocol STScripting
- (BOOL)isClass;
+ (BOOL)isClass;
- (NSString *)className;
+ (NSString *)className;
- (Class) classForScripting;
+ (Class) classForScripting;
@end


@interface NSObject (STScripting) <STScripting>
@end
