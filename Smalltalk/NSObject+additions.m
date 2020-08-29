/**
    NSObject+additions.h
    Smalltalk methods for NSObject
 
    Date: 2005 Aug 17
    Author: Stefan Urbanek
 
    This file is part of the StepTalk project.
 
 */

#import "NSObject+additions.h"

@implementation NSObject (SmalltalkBlock)
- ifNil:(STBlock *)block
{
    /* Do nothing as we are not nil. */
    return self;
}
@end
