/**
    NSNumber-additions.h
    Various methods for NSNumber
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 
 */

#import <Foundation/NSValue.h>

@interface NSNumber (STAdditions)
- add:(NSNumber *)number;
- subtract:(NSNumber *)number;
- multiply:(NSNumber *)number;
- divide:(NSNumber *)number;
- (unsigned int)isLessThan:(NSNumber *)number;
- (BOOL)isGreatherThan:(NSNumber *)number;
- (BOOL)isLessOrEqualThan:(NSNumber *)number;
- (BOOL)isGreatherOrEqualThan:(NSNumber *)number;
@end


@interface NSNumber (STLogicOperations)
- (unsigned int)or:(NSNumber *)number;
- (unsigned int)and:(NSNumber *)number;
- (unsigned int)not;
@end

@interface NSNumber (STStructure)
- rangeWith:(int)length;
- pointWith:(float)y;
- sizeWith:(float)h;
@end
