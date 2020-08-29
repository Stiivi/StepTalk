/**
    STCompiledScript.m
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
  */

#import "STCompiledScript.h"

#import "STSmalltalkScriptObject.h"
#import "STCompiledMethod.h"

#import <StepTalk/STObjCRuntime.h>
#import <StepTalk/STExterns.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSEnumerator.h>

@class STEnvironment;
static SEL mainSelector;
static SEL initializeSelector;
static SEL finalizeSelector;

@implementation STCompiledScript:NSObject
+ (void)initialize
{
    mainSelector = STSelectorFromString(@"main");
    initializeSelector = STSelectorFromString(@"startUp");
    finalizeSelector = STSelectorFromString(@"finalize");
}

- initWithVariableNames:(NSArray *)array;
{
    variableNames = array;

    return self;
}

- (void)addMethod:(STCompiledMethod *)method
{
    if(!methodDictionary)
    {
        methodDictionary = [[NSMutableDictionary alloc] init];
    }

    if( ! [method isKindOfClass:[STCompiledMethod class]] )
    {
        [NSException raise:STGenericException
                    format:@"Invalid compiled method class '%@'",
                           [method class]];
    }

    [methodDictionary setObject:method forKey:[method selector]];
}

- (STCompiledMethod *)methodWithName:(NSString *)name
{
    return [methodDictionary objectForKey:name];
}

- (NSArray*)variableNames
{
    return variableNames;
}
- (id)executeInEnvironment:(STEnvironment *)env
{
    STSmalltalkScriptObject *object;
    NSUInteger             methodCount;
    id              retval = nil;
    

    object = [[STSmalltalkScriptObject alloc] initWithEnvironment:env
                                     compiledScript:self];

    methodCount = [methodDictionary count];
    
    if(methodCount == 0)
    {
        NSLog(@"Empty script executed");
        return nil;
    }
    else if(methodCount == 1)
    {
        NSString *selName = [[methodDictionary allKeys] objectAtIndex:0];
        SEL       sel = STSelectorFromString(selName);

        NSLog(@"Executing single-method script. (%@)", selName);

        retval = [object performSelector:sel];
    }
    else if(![object respondsToSelector:mainSelector])
    {
        NSLog(@"No 'main' method found");
        return nil;
    }
    else
    {

        if( [object respondsToSelector:initializeSelector] )
        {
            NSLog(@"Sending 'startUp' to script object");
            [object performSelector:initializeSelector];
        }

        if( [object respondsToSelector:mainSelector] )
        {
            retval = [object performSelector:mainSelector];
        }
        else
        {
            NSLog(@"No 'main' found in script");
        }

        if( [object respondsToSelector:finalizeSelector] )
        {
            NSLog(@"Sending 'finalize' to script object");
            [object performSelector:finalizeSelector];
        }
    }
    
    return retval;
}

@end
