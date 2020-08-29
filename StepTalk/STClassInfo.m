/**
    STClassInfo.m
    Objective-C class wrapper
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
  */

#import "STClassInfo.h"

#import "STFunctions.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@implementation STClassInfo
- initWithName:(NSString *)aString

{
    self = [super initWithName:aString];
    
    selectorCache = [[NSMutableDictionary alloc] init];
    
    return self;
}


- (void)setSuperclassInfo:(STClassInfo *)classInfo
{
    superclass = classInfo;
}

- (STClassInfo *)superclassInfo
{
    return superclass;
}
- (void) setSuperclassName:(NSString *)aString
{
    superclassName = aString;
}
- (NSString *)superclassName
{
    return superclassName;
}

- (NSString *)translationForSelector:(NSString *)aString
{

    NSString *sel;
    
    NSLog(@"Translate '%@' in %@:%@. (%i)",
                aString, [self behaviourName],superclassName, allowAll);
    
    sel = [selectorCache objectForKey:aString];

    if(sel)
    {
        return sel;
    }

    sel = [selectorMap objectForKey:aString];

    if(!sel)
    {
        /* Lookup for super selector maping */
        if(superclass)
        {
            sel = [superclass translationForSelector:aString];

            if(sel && 
                ([denyMethods containsObject:sel] ||
                (!allowAll && ![allowMethods containsObject:sel])))
            {
                sel = nil;
            }
            else if([allowMethods containsObject:aString])
            {
                sel = aString;
            }
        }
        else if(allowAll || [allowMethods containsObject:aString])
        {
            sel = aString;
        }

        NSLog(@"   translated '%@' deny %i allow %i all %i",
                   sel, [denyMethods containsObject:sel],
                   [allowMethods containsObject:sel],
                   allowAll);

    }
    
    NSLog(@"    Return '%@' (%@)", 
                sel, [self behaviourName]);
    if(sel)
    {
        [selectorCache setObject:sel forKey:aString];
    }
    
    return sel;
}

- (void)setAllowAllMethods:(BOOL)flag
{
    allowAll = flag;
}

- (BOOL)allowAllMethods
{
    return allowAll;
}
@end

