/**
    STBlockContext.m
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
  */

#import "STBlockContext.h"

#import "STStack.h"
#import "STBytecodeInterpreter.h"
#import "STBytecodes.h"
#import "STMethodContext.h"

#import <StepTalk/STExterns.h>

#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

@implementation STBlockContext
- initWithInterpreter:(STBytecodeInterpreter *)anInterpreter
  initialIP:(unsigned)pointer
  stackSize:(unsigned)size
{
    self = [super initWithStackSize:size];
    
    interpreter = anInterpreter;
    initialIP = pointer;

    instructionPointer = initialIP;
    
    return self; 
}

- (BOOL)isBlockContext
{
    return YES;
}
- (void)setHomeContext:(STMethodContext *)context
{
    homeContext = context;
}
- (STMethodContext *)homeContext
{
    return homeContext;
}
- (void)invalidate
{
    [self setHomeContext:nil];
}
- (BOOL)isValid
{
    return [homeContext isValid];
}

- (unsigned)initialIP
{
    return initialIP;
}

- temporaryAtIndex:(unsigned)index;
{
    return [homeContext temporaryAtIndex:index];
}
- (void)setTemporary:anObject atIndex:(unsigned)index;
{
    [homeContext setTemporary:anObject atIndex:index];
}

- (NSString *)referenceNameAtIndex:(unsigned)index
{
    return [homeContext referenceNameAtIndex:index];
}
- (STBytecodes *)bytecodes
{
    return [homeContext bytecodes];
}
- (id)literalObjectAtIndex:(unsigned)index
{
    return [homeContext literalObjectAtIndex:index];
}
- (id)receiver
{
    return [homeContext receiver];
}

- (void)resetInstructionPointer
{
    instructionPointer = initialIP;
}
@end
