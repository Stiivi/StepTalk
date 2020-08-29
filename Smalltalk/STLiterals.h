/**
    STLiterals.h
    Literal objects
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
  */

#import <Foundation/NSObject.h>

@interface STLiteral:NSObject 
@end

@interface STObjectReferenceLiteral:STLiteral
{
    NSString *poolName; 
    NSString *objectName;
}
- initWithObjectName:(NSString *)anObject poolName:(NSString *)aPool;
- (NSString *)poolName;
- (NSString *)objectName;
@end

@interface STBlockLiteral:STLiteral
{
    NSUInteger  argCount;
    NSUInteger  stackSize;
}
- initWithArgumentCount:(NSUInteger)count;
- (void)setStackSize:(NSUInteger)size;
- (NSUInteger)argumentCount;
- (NSUInteger)stackSize;
@end
