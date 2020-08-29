/**
    STBlock.m
    Wrapper for STBlockContext to make it invisible from the user  

    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 */


#import "STBlock.h"
#import "STLiterals.h"
#import "STBlockContext.h"
#import "STBytecodeInterpreter.h"
#import "STStack.h"

#import <StepTalk/STExterns.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>

Class STBlockContextClass = nil;

@implementation STBlock
+ (void)initialize
{
    STBlockContextClass = [STBlockContext class];
}
- initWithInterpreter:(STBytecodeInterpreter *)anInterpreter
          homeContext:(STMethodContext *)context
            initialIP:(unsigned)ptr
        argumentCount:(int)count
            stackSize:(int)size
{
    homeContext = context;
    argCount  = count; 
    stackSize = size;
    initialIP = ptr;
    interpreter = anInterpreter;
    
    return [super init];
}

- (unsigned)argumentCount
{
    return argCount;
}

- value
{
    return [self valueWithArgs:@[]];
}

- valueWith:arg
{
    NSArray<id> *args = @[arg];
    id  retval;

    retval = [self valueWithArgs:args];
    return retval;
}

- valueWith:arg1 with:arg2
{
    NSArray<id> *args = @[arg1,arg2];
    id  retval;

    retval = [self valueWithArgs:args];
    return retval;
}

- valueWith:arg1 with:arg2 with:arg3
{
    NSArray<id> *args = @[arg1,arg2,arg3];
    id  retval;

    retval = [self valueWithArgs:args];
    return retval;
}

- valueWith:arg1 with:arg2 with:arg3 with:arg4
{
    NSArray<id> *args = @[arg1,arg2,arg3,arg4];
    id  retval;

    retval = [self valueWithArgs:args];
    return retval;
}

- valueWithArgs:(NSArray<id> *)args
{
    STExecutionContext *parentContext;
    STBlockContext     *context;
    STStack            *stack;
    unsigned int        i;
    id                  retval;

    if(argCount != [args count])
    {
        [NSException raise:STScriptingException
                    format:@"Invalid block argument count %lu, "
                           @"wants to be %lu", [args count], argCount];
        return nil;
    }

    if(!usingCachedContext)
    {
        /* In case of recursive block nesting */
        usingCachedContext = YES;

        if(!cachedContext)
        {
            cachedContext = [[STBlockContextClass alloc] 
                                    initWithInterpreter:interpreter
                                              initialIP:initialIP
                                              stackSize:stackSize];
        }

        /* Avoid allocation */
        context = cachedContext;
        [[context stack] empty];
        [context resetInstructionPointer];
    }
    else
    {
        /* Create new context */
        context = [[STBlockContextClass alloc] initWithInterpreter:interpreter
                                                         initialIP:initialIP
                                                         stackSize:stackSize];
    }

    /* push block arguments to the stack */
    
    stack = [context stack];
    for(i = 0; i<[args count]; i+=1)
    {
        [stack push:args[i]];
    }

    [context setHomeContext:homeContext];

    parentContext = [interpreter context];

    [interpreter setContext:context];
    retval = [interpreter interpret];
    [interpreter setContext:parentContext];

    /* Release cached context */
    if(usingCachedContext)
    {
        usingCachedContext = NO;
    }

    return retval;
}

- handler:(STBlock *)handlerBlock
{
    STExecutionContext *context;
    id                  retval;

    /* save the execution context for the case of exception */
    context = [interpreter context];

    NS_DURING
        retval = [self value];
    NS_HANDLER
        retval = [handlerBlock valueWith:localException];
        /* restore the execution context */
        [interpreter setContext:context];
    NS_ENDHANDLER

    return retval;
}

- whileTrue:(STBlock *)doBlock
{
    id retval = nil;
    
    while([[self value] boolValue])
    {
        retval = [doBlock value];
    }
    return retval;
}

- whileFalse:(STBlock *)doBlock
{
    id retval = nil;
    
    while(! [[self value] boolValue])
    {
        retval = [doBlock value];
    }
    return retval;
}
@end
