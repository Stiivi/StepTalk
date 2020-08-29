/**
    STMethod
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2003 Aug 6
 
    This file is part of the StepTalk project.
 
 */

#import <Foundation/NSObject.h>

@protocol STMethod
- (NSString *)source;
- (NSString *)methodName;
- (NSString *)languageName;
@end
