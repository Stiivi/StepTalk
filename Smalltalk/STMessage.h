/**
    STMessage.h
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2001 Jun 18
 
    This file is part of StepTalk.
  */


#import <Foundation/NSObject.h>

@class NSString;
@class NSArray;

@interface STMessage:NSObject
{
    NSString *selector;
    NSArray  *args;
}
+ (STMessage *)messageWithSelector:(NSString *)selector 
                         arguments:(NSArray *)args;
- initWithSelector:(NSString *)aString
         arguments:(NSArray *)anArray;
- (NSString *)selector;
- (NSArray*)arguments;
@end
