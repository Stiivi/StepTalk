/**
    STBlockContext.h
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
  */

#import "STExecutionContext.h"

@class STBytecodeInterpreter;
@class STMethodContext;

@interface STBlockContext:STExecutionContext
{
    STBytecodeInterpreter *interpreter; 
    STMethodContext       *homeContext; /* owner of this block context */

    unsigned               initialIP;
}
- initWithInterpreter:(STBytecodeInterpreter *)anInterpreter
  initialIP:(unsigned)pointer
  stackSize:(unsigned)size;
- (void)setHomeContext:(STMethodContext *)context;
- (unsigned)initialIP;
- (void)resetInstructionPointer;
@end
