/**
    STBehaviourInfo.h
    Scripting definition: behaviour information 
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
*/

#include <Foundation/NSObject.h>

@class NSString;
@class NSDictionary;
@class NSMutableDictionary;
@class NSMutableSet;
@class NSSet;

@interface STBehaviourInfo:NSObject
{
    NSString *name;

    NSMutableDictionary *selectorMap;

    NSMutableSet *allowMethods;
    NSMutableSet *denyMethods;
}
- initWithName:(NSString *)aString;

- (NSString*)behaviourName;

- (void)setTranslation:(NSString *)aSelector 
           forSelector:(NSString *)aString;

- (void)removeTranslationForSelector:(NSString *)aString;
- (NSDictionary *)selectorMap;
- (void)addTranslationsFromDictionary:(NSDictionary *)map;

- (void)allowMethods:(NSSet *)set;
- (void)denyMethods:(NSSet *)set;

- (void)allowMethod:(NSString *)methodName;
- (void)denyMethod:(NSString *)methodName;

- (NSSet *)allowedMethods;
- (NSSet *)deniedMethods;

- (void)adopt:(STBehaviourInfo *)info;
@end
