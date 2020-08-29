/*
    STSelector additions
  
    Date: 2002 Feb 4
  
    This file is part of the StepTalk project.
 */

#import "STSelector+additions.h"

#import <StepTalk/STObjCRuntime.h>

@implementation STSelector(SmalltalkCompiler)
+ symbolFromString:(NSString *)aString
{
    STSelector *aSel;
    aSel = [[STSelector alloc] initWithSelector:STSelectorFromString(aString)];
    return aSel;
}
@end
