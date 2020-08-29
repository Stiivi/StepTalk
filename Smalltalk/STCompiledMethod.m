/**
    STCompiledMethod.m
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
 
    This file is part of the StepTalk project.
  */

#import "STCompiledMethod.h"

#import "STMessage.h"
#import "STBytecodes.h"

#import <StepTalk/STMethod.h>
#import <StepTalk/STScripting.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSString.h>

@implementation STCompiledMethod
+ methodWithCode:(STCompiledCode *)code
  messagePattern:(STMessage *)pattern
{
    STCompiledMethod *method;
    
    method = [[STCompiledMethod alloc]
              initWithSelector:[pattern selector]
              argumentCount:[[pattern arguments] count]
              bytecodesData:[[code bytecodes] data]
              literals:[code literals]
              temporariesCount:[code temporariesCount]
              stackSize:[code stackSize]
              namedReferences:[code namedReferences]];
               

    return method;
}

-   initWithSelector:(NSString *)sel
       argumentCount:(unsigned)aCount
       bytecodesData:(NSData *)data
            literals:(NSArray *)anArray
    temporariesCount:(unsigned)tCount
           stackSize:(unsigned)size
     namedReferences:(NSMutableArray *)refs;
{
    self = [super initWithBytecodesData:data
                               literals:anArray
                       temporariesCount:tCount
                              stackSize:size
                        namedReferences:refs];

    selector = sel;
    argCount = aCount;
    
    return self;
}

- (NSString *)selector
{
    return selector;
}

- (unsigned)argumentCount
{
    return argCount;
}

- (NSString*)description
{
    NSMutableString *desc = [NSMutableString string];

    [desc appendFormat:@"%@:\n"
     @"Selector = %@\n"
     @"Literals Count = %lu\n"
     @"Literals = %@\n"
     @"External References = %@\n"
     @"Temporaries Count = %i\n"
     @"Stack Size = %i\n",
     [self className],
     selector,
     (unsigned long)[literals count],
     [literals description],
     [namedRefs description],
     tempCount,
     stackSize];

    return desc;
}

/* Script object method info */
- (NSString *)methodName
{
    return selector;
}
- (NSString *)languageName
{
    return @"Smalltalk";
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder: coder];

    [coder encodeObject:selector];
    [coder encodeValueOfObjCType: @encode(short) at: &argCount];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &selector];
    [decoder decodeValueOfObjCType: @encode(short) at: &argCount];

    return self;
}
- (NSString *)source
{
    return nil;
}
@end
