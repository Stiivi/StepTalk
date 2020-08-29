/**
    STMessage.m
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2001 Jun 18
 
    This file is part of StepTalk.
  */

#import "STMessage.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>


@implementation STMessage
+ (STMessage *)messageWithSelector:(NSString *)aString
                         arguments:(NSArray *)anArray
{
    STMessage *message;
    
    message = [[STMessage alloc] initWithSelector:aString
                                        arguments:anArray];
    return message;
}
- initWithSelector:(NSString *)aString
         arguments:(NSArray *)anArray
{
    self = [super init];
    selector = aString;
    args = anArray;
    
    return self;
}

- (NSString *)selector
{
    return selector;
}

- (NSArray *)arguments
{
    return args;
}
@end
