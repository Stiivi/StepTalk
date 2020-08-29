/*
    STSelector
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2002 Feb 4
   
    This file is part of the StepTalk project.

 */

#import <Foundation/NSObject.h>

@interface STSelector:NSObject
{
    NSString *selectorName;
    SEL       sel;
}
- initWithName:(NSString *)aString;
- initWithSelector:(SEL)aSel;

- (SEL)selectorValue;
- (NSString *)selectorName;
@end

