/**
    NSNumber-additions.h
    Various methods for NSNumber
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 
 */

#import "NSNumber+additions.h"

#import "STExterns.h"
#import "STStructure.h"

#import <Foundation/NSException.h>

#include <math.h>

@implementation NSNumber (STAdditions)
- add:(NSNumber *)number
{
    return [NSNumber numberWithDouble:([self doubleValue] 
                                        + [number doubleValue])];
}
- subtract:(NSNumber *)number
{
    return [NSNumber numberWithDouble:([self doubleValue] 
                                        - [number doubleValue])];
}
- multiply:(NSNumber *)number
{
    return [NSNumber numberWithDouble:([self doubleValue] 
                                        * [number doubleValue])];
}
- divide:(NSNumber *)number
{
    if([number doubleValue] == 0.0)
    {
        [NSException raise:STGenericException
                     format:@"Division by zero"];
        return self;
    }
    

    return [NSNumber numberWithDouble:([self doubleValue] 
                                        / [number doubleValue])];
}

- modulo:(NSNumber *)number
{
    if([number doubleValue] == 0.0)
    {
        [NSException raise:STGenericException
                     format:@"Division by zero"];
        return self;
    }
    

    return [NSNumber numberWithDouble:(fmod([self doubleValue],
                                         [number doubleValue]))];
}
- (unsigned int)isLessThan:(NSNumber *)number
{
    return ([self doubleValue] < [number doubleValue]);
}

- (BOOL)isGreatherThan:(NSNumber *)number
{
    return ([self doubleValue] > [number doubleValue]);
}

- (BOOL)isLessOrEqualThan:(NSNumber *)number
{
    return ([self doubleValue] <= [number doubleValue]);
}
- (BOOL)isGreatherOrEqualThan:(NSNumber *)number
{
    return ([self doubleValue] >= [number doubleValue]);
}
@end


@implementation NSNumber (STLogicOperations)
- (unsigned int)or:(NSNumber *)number
{
    return ([self intValue] | [number intValue]);
}

- (unsigned int)and:(NSNumber *)number
{
    return ([self intValue] & [number intValue]);
}

- (unsigned int)not
{
    /* FIXME */
    return ![self intValue];
}

@end

@implementation NSNumber (STStructure)
- rangeWith:(int)length
{
    return [STStructure structureWithRange:NSMakeRange([self intValue], length)];
}
- pointWith:(float)y
{
    return [STStructure structureWithPoint:NSMakePoint([self floatValue], y)];
}
- sizeWith:(float)h
{
    return [STStructure structureWithSize:NSMakeSize([self floatValue], h)];
}
@end
