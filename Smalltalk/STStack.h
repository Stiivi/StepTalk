/**
    STStack.h
    Stack object
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
  */

#import <Foundation/NSArray.h>

// TODO: This used to be id poiter stack for some reason
// API not touched since then

@interface STStack:NSObject
{
    unsigned  size;
    unsigned  pointer;
    NSMutableArray   *stack;
}
+ stackWithSize:(unsigned)newSize;
- initWithSize:(unsigned)newSize;

- (void)push:anObject;
- (id)  pop;
- (void)popCount:(unsigned)count;
- (id)  valueAtTop;
- (id)  valueFromTop:(unsigned)offset;

- (void)duplicateTop;

- (void)empty;
@end
