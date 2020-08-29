/**
    STMethodContext.h
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 */

#import "STExecutionContext.h"

@class STCompiledMethod;
@class STEnvironment;
@class NSMutableArray;

@interface STMethodContext:STExecutionContext
{
    STCompiledMethod *method;
    NSMutableArray   *temporaries;
    id                receiver;
}

+ methodContextWithMethod:(STCompiledMethod *)newMethod 
              environment:(STEnvironment *)env;

- initWithMethod:(STCompiledMethod *)newMethod
     environment:(STEnvironment *)env;

- (STCompiledMethod*)method;

- (void)setReceiver:anObject;
- (id)receiver;

- (void)setArgumentsFromArray:(NSArray *)args;

- (id)temporaryAtIndex:(unsigned)index;
- (void)setTemporary:anObject atIndex:(unsigned)index;

- (STBytecodes *)bytecodes;
@end
