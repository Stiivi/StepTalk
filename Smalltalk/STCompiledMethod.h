/**
    STCompiledMethod.h
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk.
 */

#import "STCompiledCode.h"

#import <StepTalk/StepTalk.h>

@protocol STMethod;

@class STMessage;

@interface STCompiledMethod:STCompiledCode<STMethod>
{
    NSString *selector;
    short     argCount;

//  unsigned primitive; 
}
+ methodWithCode:(STCompiledCode *)code messagePattern:(STMessage *)pattern;

-   initWithSelector:(NSString *)sel
       argumentCount:(unsigned)aCount
       bytecodesData:(NSData *)data
            literals:(NSArray *)anArray
    temporariesCount:(unsigned)tCount
           stackSize:(unsigned)size
     namedReferences:(NSMutableArray *)refs;

- (NSString *)selector;
- (unsigned)argumentCount;
@end
