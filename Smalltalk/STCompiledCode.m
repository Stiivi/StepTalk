/**
    STCompiledCode.m
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
 
    This file is part of the StepTalk project.
 
 */

#import "STCompiledCode.h"
#import "STBytecodes.h"

#import <Foundation/NSObject.h>
#import <Foundation/NSData.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>

@implementation STCompiledCode
- initWithBytecodesData:(NSData *)data
               literals:(NSArray *)anArray
       temporariesCount:(unsigned)count
              stackSize:(unsigned)size
        namedReferences:(NSMutableArray *)refs
{
    self = [super init];

    [self setBytecodes: [[STBytecodes alloc] initWithData:data]];
    literals = [[NSArray alloc] initWithArray:anArray];
    tempCount = count;
    stackSize = size;
    namedRefs = [[NSArray alloc] initWithArray:refs];
    return self;
}

- (NSUInteger)temporariesCount
{
    return tempCount;
}
- (NSUInteger)stackSize
{
    return stackSize;
}
- (NSArray *)literals
{
    return literals;
}
- (id)literalObjectAtIndex:(unsigned)index
{
    return [literals objectAtIndex:index];
}

- (NSArray *)namedReferences
{
    return namedRefs;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:[self bytecodes]];
    [coder encodeObject:literals];
    [coder encodeObject:namedRefs];
    [coder encodeValueOfObjCType: @encode(NSUInteger) at: &tempCount];
    [coder encodeValueOfObjCType: @encode(NSUInteger) at: &stackSize];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; // [super initWithCoder: decoder];
    
    
    
    [self setBytecodes: [decoder decodeObject]];
    literals = [decoder decodeObject];
    namedRefs = [decoder decodeObject];
    [decoder decodeValueOfObjCType: @encode(NSUInteger) at: &tempCount];
    [decoder decodeValueOfObjCType: @encode(NSUInteger) at: &stackSize];

    return self;
}

@end
