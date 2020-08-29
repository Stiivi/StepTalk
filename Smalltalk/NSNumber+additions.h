/**
    NSNumber-additions.h
    Various methods for NSNumber
 
    This file is part of the StepTalk project.
  */

#import <Foundation/NSValue.h>

@class STBlock;

@interface NSNumber (STSmalltalkAdditions)
- ifTrue:(STBlock *)block;
- ifFalse:(STBlock *)block;
- ifTrue:(STBlock *)trueBlock ifFalse:(STBlock *)falseBlock;
- ifFalse:(STBlock *)falseBlock ifTrue:(STBlock *)trueBlock;

- (BOOL)isTrue;
- (BOOL)isFalse;

- to:(int)number do:(STBlock *)block;
- to:(int)number step:(int)step do:(STBlock *)block;
@end
