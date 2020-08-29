/*
    STSelector
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2002 Feb 4
  
    This file is part of the StepTalk project.

 */

#import "STSelector.h"
#import "STObjCRuntime.h"

#import <Foundation/NSCoder.h>
#import <Foundation/NSString.h>

@implementation STSelector
- initWithName:(NSString *)aString
{
    self = [super init];
    
    selectorName = aString;
    
    return self;
}

- initWithSelector:(SEL)aSel
{
    self = [super init];
    sel = aSel;
    return self;
}

- (SEL)selectorValue
{
    if(sel == 0)
    {
        sel = STSelectorFromString(selectorName);
    }
    return sel;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"#%@", [self selectorName]];
}

- (NSString *)selectorName
{
    if(!selectorName)
    {
        selectorName = NSStringFromSelector(sel);
    }

    return selectorName;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:selectorName];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; // super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &selectorName];

    return self;
}
@end
