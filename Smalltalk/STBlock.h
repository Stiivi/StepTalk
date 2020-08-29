/**
    STBlock.h
    Wrapper for STBlockContext to make it invisible  
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 */

#import <Foundation/NSObject.h>

@class STBlockLiteral;
@class STBytecodeInterpreter;
@class STMethodContext;
@class STBlockContext;

@interface STBlock:NSObject
{
    STBytecodeInterpreter *interpreter;
    STMethodContext       *homeContext;
    
    unsigned               initialIP;
    unsigned               argCount;
    unsigned               stackSize;

    STBlockContext        *cachedContext;
    BOOL                   usingCachedContext; 
}

- initWithInterpreter:(STBytecodeInterpreter *)anInterpreter
          homeContext:(STMethodContext *)context
            initialIP:(unsigned)ptr
        argumentCount:(int)count
            stackSize:(int)size;
                 
- (unsigned)argumentCount;

- value;
- valueWith:arg;
- valueWith:arg1 with:arg2;
- valueWith:arg1 with:arg2 with:arg3;
- valueWith:arg1 with:arg2 with:arg3 with:arg4;
- valueWithArgs:(NSArray<id> *)args;

- whileTrue:(STBlock *)doBlock;
- whileFalse:(STBlock *)doBlock;

- handler:(STBlock *)handlerBlock;
@end
