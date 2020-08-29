/**
    STBehaviourInfo.m
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 */

#import "STBehaviourInfo.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@implementation STBehaviourInfo
- initWithName:(NSString *)aString
{
    self = [super init];
    selectorMap = [[NSMutableDictionary alloc] init];
    allowMethods = [[NSMutableSet alloc] init];
    denyMethods = [[NSMutableSet alloc] init];
    
    name = aString;
    
    return self;
}

- (NSString*)behaviourName
{
    return name;
}

- (void)adopt:(STBehaviourInfo *)info
{
    [self addTranslationsFromDictionary:[info selectorMap]];
    [self allowMethods:[info allowedMethods]];
    [self denyMethods:[info deniedMethods]];
}

- (NSDictionary *)selectorMap
{
    return selectorMap;
}

- (void)removeTranslationForSelector:(NSString *)aString
{
    [selectorMap removeObjectForKey:aString];
}

- (void)setTranslation:(NSString *)translation
           forSelector:(NSString *)selector
{
    [selectorMap setObject:translation forKey:selector];
}

- (void)addMethodsFromArray:(NSArray *)methods
{
    NSEnumerator *enumerator;
    NSString     *sel;
    
    enumerator = [methods objectEnumerator];
    while( (sel = [enumerator nextObject]) )
    {
        [self setTranslation:sel forSelector:sel];
    }
}

- (void)addTranslationsFromDictionary:(NSDictionary *)map
{
    [selectorMap addEntriesFromDictionary:map];
}
- (void)allowMethods:(NSSet *)set
{
    [allowMethods unionSet:set];
    [denyMethods minusSet:allowMethods];
}

- (void)denyMethods:(NSSet *)set;
{
    [denyMethods unionSet:set];
    [allowMethods minusSet:denyMethods];
}

- (void)allowMethod:(NSString *)methodName;
{
    [allowMethods addObject:methodName];
    [denyMethods removeObject:methodName];
}

- (void)denyMethod:(NSString *)methodName;
{
    [denyMethods addObject:methodName];
    [allowMethods removeObject:methodName];
}

- (NSSet *)allowedMethods
{
    return [allowMethods copy];
}

- (NSSet *)deniedMethods
{
    return [denyMethods copy];
}
@end
