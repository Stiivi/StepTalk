/**
    STEnvironment
    Scripting environment
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
     
    This file is part of the StepTalk project.
    */

#import <StepTalk/STContext.h>

@class NSBundle;
@class NSDictionary;
@class NSMutableDictionary;
@class NSMutableArray;
@class NSMutableSet;

@class STObjectReference;
@class STEnvironmentDescription;

@interface STEnvironment:STContext
{
    STEnvironmentDescription *description;
    NSMutableDictionary      *classes;   /* from description */

    NSMutableDictionary      *infoCache;
    
    NSMutableDictionary      *objectFinders;
    
    NSMutableArray           *loadedBundles;
}
/** Creating environment */
+ sharedEnvironment;
+ (STEnvironment *)environmentWithDefaultDescription;

+ environmentWithDescription:(STEnvironmentDescription *)aDescription;

- initWithDefaultDescription;
- initWithDescription:(bycopy STEnvironmentDescription *)aDescription;

/** Modules */

- (void)loadModule:(NSString *)moduleName;

- (BOOL)includeFramework:(NSString *)frameworkName;
- (BOOL)includeBundle:(NSBundle *)aBundle;

- (void)addClassesWithNames:(NSArray *)names;

/** Distributed objects */
- (void)registerObjectFinder:(id)finder name:(NSString*)name;
- (void)registerObjectFinderNamed:(NSString *)name;
- (void)removeObjectFinderWithName:(NSString *)name;

/** Selector translation */

- (NSString  *)translateSelector:(NSString *)aString forReceiver:(id)anObject;
@end
