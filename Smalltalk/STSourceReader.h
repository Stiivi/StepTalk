/**
    STSourceReader.h
    Source reader class.
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
  */

#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

#include "STTokenTypes.h"


@class NSString;

@interface STSourceReader:NSObject
{
    NSString    *source;              // Source
    NSRange      srcRange;            // range of source in string
    NSUInteger   srcOffset;           // Scan offset
    NSRange      tokenRange;          // Tokenn range
    STTokenType  tokenType;           // Token type
}
- initWithString:(NSString *)aString;
- initWithString:(NSString *)aString range:(NSRange)range;
- (STTokenType)nextToken;
- (STTokenType)tokenType;
- (NSString *)tokenString;
- (NSRange)tokenRange;
- (NSUInteger)currentLine;

@end
