/**
    STScript
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2002 Mar 10
 
    This file is part of the StepTalk project.
   */

#import "STScript.h"

#import <Foundation/NSString.h>

@implementation STScript
+ scriptWithSource:(NSString *)aString language:(NSString *)lang
{
    return [[self alloc] initWithSource:aString language:lang];
}
- initWithSource:(NSString *)aString language:(NSString *)lang
{
    self = [super init];
    language = lang;
    source = aString;
    return self;
}
- (NSString *)source
{
    return source;
}
- (void)setSource:(NSString *)aString
{
    source = aString;
}

/** Returns language of the script. */
- (NSString *)language
{
    return language;
}

/** Set language of the script. */
- (void)setLanguage:(NSString *)name
{
    language = name;
}
@end
