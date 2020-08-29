/**
    STLiterals.h
    Literal objects
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 */

#import "STLiterals.h"

#import <Foundation/NSString.h>

@implementation STLiteral
@end

@implementation STObjectReferenceLiteral
- initWithObjectName:(NSString *)anObject poolName:(NSString *)aPool
{
    objectName = anObject;
    poolName = aPool;
    return [super init];
}
#if 0
- copyWithZone:(NSZone *)zone
{
    STObjectReferenceLiteral *copy = [super copyWithZone:zone];
    return copy;
}
#endif

- (NSString *)poolName
{
    return poolName;
}
- (NSString *)objectName
{
    return objectName;
}
- (NSString *)description
{
    return [NSMutableString stringWithFormat:
                @"STObjectReferenceLiteral { object '%@', pool '%@' }",
                objectName,poolName];
}
@end

@implementation STBlockLiteral
- initWithArgumentCount:(NSUInteger)count
{
    argCount = count;
    return [super init];
}
- (void)setStackSize:(NSUInteger)size
{
    stackSize = size;
}
- (NSUInteger)argumentCount
{
    return argCount;
}
- (NSUInteger)stackSize
{
    return stackSize;
}
@end

