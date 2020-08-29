/**
    STBytecodeInterpreter.h
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
  */

#import <Foundation/NSObject.h>

@class STCompiledMethod;
@class STCompiledCode;
@class STBytecodes;
@class STExecutionContext;
@class STStack;
@class STEnvironment;

@class NSArray;
@class NSMutableArray;
@class NSMutableDictionary;

@interface STBytecodeInterpreter:NSObject
{
    STEnvironment      *environment;    /* scripting environment */

    STExecutionContext *activeContext;       /* current execution context */
    STStack            *stack;               /* from context */
    STBytecodes        *bytecodes;           /* from context */
    unsigned            instructionPointer;  /* IP  */
    id                  receiver;

    int                 entry;

    BOOL                stopRequested;
}

+ interpreterWithEnvrionment:(STEnvironment *)env;
- initWithEnvironment:(STEnvironment *)env;

- (void)setEnvironment:(STEnvironment *)env;

- (id)interpretMethod:(STCompiledMethod *)method 
          forReceiver:(id)anObject
            arguments:(NSArray*)args;

- (void)setContext:(STExecutionContext *)context;
- (STExecutionContext *)context;

- (id)interpret;
- (void)halt;
@end
