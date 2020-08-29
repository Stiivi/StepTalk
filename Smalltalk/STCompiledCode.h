/**
    STCompiledCode.h
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk.
  */

#import <Foundation/NSObject.h>

@class NSData;
@class NSArray;
@class NSMutableArray;
@class STBytecodes;

@interface STCompiledCode:NSObject<NSCoding>
{
    NSArray            *literals;
    NSArray            *namedRefs;
    NSUInteger               tempCount;
    NSUInteger               stackSize;
}
@property STBytecodes *bytecodes;

- initWithBytecodesData:(NSData *)data
               literals:(NSArray *)anArray
       temporariesCount:(NSUInteger)count
              stackSize:(NSUInteger)size
        namedReferences:(NSMutableArray *)refs;

- (NSUInteger)temporariesCount;
- (NSUInteger)stackSize;
- (id)literalObjectAtIndex:(unsigned)index;
- (NSArray *)namedReferences;
- (NSArray *)literals;
@end
