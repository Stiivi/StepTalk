/**
    STContext
    Scripting context
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2004
     
    This file is part of the StepTalk project.
 
 */

#import <Foundation/NSObject.h>

@class NSBundle;
@class NSDictionary;
@class NSMutableDictionary;
@class NSMutableArray;
@class NSMutableSet;

@class STObjectReference;
@class STEnvironmentDescription;

@interface STContext:NSObject
{
    NSMutableDictionary      *objectDictionary;
    STContext                *parentContext;
    BOOL                      fullScripting;
    BOOL                      createsUnknownObjects;
}

- (void)setParentContext:(STContext *)context;
- (STContext *)parentContext;

/** Full scripting */
- (void)setFullScriptingEnabled:(BOOL)flag;
- (BOOL)fullScriptingEnabled;

-(void)setCreatesUnknownObjects:(BOOL)flag;
-(BOOL)createsUnknownObjects;

- (NSMutableDictionary *)objectDictionary;
- (void)setObject:(id)anObject
          forName:(NSString *)objName;
- (void)removeObjectWithName:(NSString *)objName;
- (void)addNamedObjectsFromDictionary:(NSDictionary *)dict;
- (id)objectWithName:(NSString *)objName;

- (STObjectReference *)objectReferenceForObjectWithName:(NSString *)name;

- (NSArray *)knownObjectNames;
@end
