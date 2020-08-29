/**
    STMethodContext.m
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 */

#import "STMethodContext.h"

#import "STBytecodes.h"
#import "STCompiledMethod.h"
#import "STLiterals.h"
#import "STStack.h"

#import <StepTalk/STEnvironment.h>
#import <StepTalk/STExterns.h>
#import <StepTalk/STObjectReference.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>

@interface STMethodContext(STPrivateMethods)
- (void)_resolveExternReferences:(NSArray *)array
                     environment:(STEnvironment *)env;
@end

@implementation STMethodContext
+ methodContextWithMethod:(STCompiledMethod *)newMethod 
              environment:(STEnvironment *)env
{
    return [[self alloc] initWithMethod:newMethod environment:env];
}

- initWithMethod:(STCompiledMethod *)newMethod 
     environment:(STEnvironment *)env
{
    unsigned int tempCount;
    unsigned int i;

    method = newMethod;

    tempCount = [method temporariesCount];
    temporaries = [[NSMutableArray alloc] initWithCapacity:tempCount];

    for(i=0;i<tempCount;i++)
    {
        [temporaries insertObject:STNil atIndex:i];
    }
    
    return [super initWithStackSize:[method stackSize]];
}

- (BOOL)isBlockContext
{
    return NO;
}
- (STMethodContext *)homeContext
{
    return self;
}
- (void)setHomeContext:(STMethodContext *)context
{
    [NSException raise:STInternalInconsistencyException
                format:@"Should not set home context of method context"];
}

- (void)invalidate
{
    method = nil;
}
- (BOOL)isValid
{
    return (method != nil);
}

- (STCompiledMethod*)method
{
    return method;
}
- (void)setReceiver:anObject
{
    receiver = anObject;
}
- (id)receiver
{
    return receiver;
}

- (id)temporaryAtIndex:(unsigned)index
{
    return [temporaries objectAtIndex:index];
}

- (void)setTemporary:anObject atIndex:(unsigned)index
{
    if(!anObject)
    {
        anObject = STNil;
    }
    [temporaries replaceObjectAtIndex:index withObject:anObject];
}

- (NSString *)referenceNameAtIndex:(unsigned)index
{
    return [[method namedReferences] objectAtIndex:index];
}

- (STBytecodes *)bytecodes
{
    return [method bytecodes];
}
- (id)literalObjectAtIndex:(unsigned)index
{
    return [method literalObjectAtIndex:index];
}

- (void)setArgumentsFromArray:(NSArray *)args
{
    int i;
    NSUInteger count;
    
    count = [args count];

    for(i=0;i<count;i++)
    {
        [self setTemporary:[args objectAtIndex:i] atIndex:i];
    }
}
@end
