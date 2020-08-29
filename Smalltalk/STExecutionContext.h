/**
    STExecutionContext.h
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 */

#import <Foundation/NSObject.h>

@class STStack;
@class STBytecodes;
@class STMethodContext;

@interface STExecutionContext:NSObject
{
    unsigned            contextId;       /* for debugging */
    
    STStack            *stack;
    
    unsigned            instructionPointer;
}
- initWithStackSize:(unsigned)stackSize;

- (void)invalidate;
- (BOOL)isValid;

- (STMethodContext *)homeContext;
- (void)setHomeContext:(STMethodContext *)context;

- (BOOL)isBlockContext;

- (unsigned)instructionPointer;
- (void)setInstructionPointer:(unsigned)value;

- (STBytecodes *)bytecodes;

- (STStack *)stack;

- (id)temporaryAtIndex:(unsigned)index;
- (void)setTemporary:anObject atIndex:(unsigned)index;
- (NSString *)referenceNameAtIndex:(unsigned)index;
- (id)literalObjectAtIndex:(unsigned)index;

- (id)receiver;
@end
