/**
    STStack.m
    Temporaries and stack storage.
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 
 */

// TODO: This used to be id poiter stack for some reason
// API not touched since then

#import "STStack.h"

#import <StepTalk/STExterns.h>

#import <Foundation/NSException.h>
#import <Foundation/NSDebug.h>

@implementation STStack
// FIXME: Pointless, remove
+ stackWithSize:(unsigned)newSize
{
    return [[self alloc] initWithSize:newSize];
}

// FIXME: Remove size
- initWithSize:(unsigned)newSize
{
    size = newSize;
    pointer = 0;
    stack = [[NSMutableArray alloc] initWithCapacity:newSize];

    return self;
}

- (void)invalidPointer:(unsigned)ptr
{
    [NSException raise:STInternalInconsistencyException
                format:@"%@: invalid pointer %i (sp=%i size=%i)",
                        self,
                        ptr,
                        pointer,
                        size];
}

#define INDEX_IS_VALID(index) \
            ((index >= 0) && (index < size))
            
#define CHECK_POINTER(value) \
            do {\
                if(!INDEX_IS_VALID(value)) \
                {\
                    [self invalidPointer:value];\
                } \
            }\
            while(0) 

- (int)pointer
{
    return pointer;
}

- (void)push:(id)value
{
    CHECK_POINTER(pointer);

    NSLog(@"stack:%p %02i push '%@'",self,pointer,value);
    
    [stack addObject: value];
    pointer += 1;
}

- (void)duplicateTop
{
    [self push:[self valueAtTop]];
}
#define CONVERT_NIL(obj) ((obj == STNil) ? nil : (obj))
- (id)valueAtTop
{
    CHECK_POINTER(pointer-1);

    return [stack lastObject];

    return CONVERT_NIL(stack[pointer-1]);
}
- (id)valueFromTop:(unsigned)index
{
    id value;

    CHECK_POINTER(pointer-index-1);
    value = stack[pointer - index - 1];
    return CONVERT_NIL(value);
}

- (id)pop
{
    CHECK_POINTER(pointer-1);
    pointer --;
    return CONVERT_NIL(stack[pointer]);
}

- (void)popCount:(unsigned)count
{
    CHECK_POINTER(pointer-count);
    pointer -= count;
}
- (void)empty
{
    pointer = 0;
}

@end
