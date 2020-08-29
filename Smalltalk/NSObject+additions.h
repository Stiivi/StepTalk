/**
    NSObject+additions.h
    Smalltalk methods for NSObject
 
    Date: 2005 Aug 17
    Author: Stefan Urbanek
 
    This file is part of the StepTalk project.
 */

#import <Foundation/NSObject.h>

@class STBlock;

@interface NSObject (SmalltalkBlock)
- ifNil:(STBlock *)block;
@end
