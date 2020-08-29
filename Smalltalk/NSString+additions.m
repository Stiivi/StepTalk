/**
    NSString-additions.h
    Various methods for NSString
  
    Date: 2003 May 9
    Author: Stefan Urbanek <stefan.urbanek@gmail.com>
 
    This file is part of the StepTalk project.
 
 */

#import "NSString+additions.h"

@implementation NSString (STSmalltalkAdditions)
- (BOOL)containsString:(NSString *)aString
{
    NSRange range;
    
    range = [self rangeOfString:aString];
    
    return (range.location != NSNotFound);
}
@end
