/**
    STUndefinedObject.h
    Wrapper for nil object
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 */

#import <StepTalk/STUndefinedObject.h>

@class STBlock;

@interface STUndefinedObject(SmalltalkAdditions)
- ifFalse:(STBlock *)block ifTrue:(STBlock *)anotherBlock;
- ifTrue:(STBlock *)block ifFalse:(STBlock *)anotherBlock;
- ifTrue:(STBlock *)block;
- ifFalse:(STBlock *)block;
- ifNil:(STBlock *)block;
- notNil:(STBlock *)block;
- (BOOL)isNil;
@end
