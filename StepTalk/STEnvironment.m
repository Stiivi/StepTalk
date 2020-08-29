/**
    STEnvironment
    Scripting environment
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 
   */

#import "STEnvironment.h"

#import "STScripting.h"
#import "STClassInfo.h"
#import "STEnvironmentDescription.h"
#import "STExterns.h"
#import "STFunctions.h"
#import "STBundleInfo.h"
#import "STObjCRuntime.h"
#import "STObjectReference.h"
#import "STUndefinedObject.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSInvocation.h>

STEnvironment *sharedEnvironment = nil;

@interface STEnvironment(STPrivateMethods)
- (STClassInfo *)findClassInfoForObject:(id)anObject;
@end

@implementation STEnvironment
/** Returns an instance of the scripting environment that is shared in
    the scope of actual application or process. */
+ sharedEnvironment
{
    if(sharedEnvironment == nil)
    {
        sharedEnvironment = [[self alloc] initWithDefaultDescription];
    }
    
    return sharedEnvironment;
}

/**
   Creates and initialises new scripting environment using default description.
 */

+ (STEnvironment *)environmentWithDefaultDescription
{
    return [[self alloc] initWithDefaultDescription];
}

/**
   Creates and initialises scripting environment using environment description 
   <var>description</var>.
 */
+ environmentWithDescription:(STEnvironmentDescription *)aDescription
{
    return [[self alloc] initWithDescription:aDescription];
}

/**
   Initialises scripting environment using default description.
   
   <init />
 */

- initWithDefaultDescription
{
    STEnvironmentDescription *desc;
    NSString *name;
    
    name = [STEnvironmentDescription defaultDescriptionName];
    desc = [STEnvironmentDescription descriptionWithName:name];
    
    return [self initWithDescription:desc];
}

/**
   Initialises scripting environment using scripting description
   <var>aDescription</var>.
 */
- initWithDescription:(bycopy STEnvironmentDescription *)aDescription
{
    NSEnumerator *enumerator;
    NSString     *name;
    
    self = [super init];
    
    infoCache = [[NSMutableDictionary alloc] init];

    description = aDescription;
    classes = [description classes];

    /* Load modules */

    enumerator = [[description modules] objectEnumerator];    
    
    while( (name = [enumerator nextObject]) )
    {
        [self loadModule:name];
    }

    /* Load frameworks */
    enumerator = [[description frameworks] objectEnumerator];
    
    while( (name = [enumerator nextObject]) )
    {
        [self includeFramework:name];
    }

    /* Register finders */
    enumerator = [[description objectFinders] objectEnumerator];    
    
    while( (name = [enumerator nextObject]) )
    {
        [self registerObjectFinderNamed:name];
    }

    return self;
}

/**
    Add classes specified by the names in the <var>names</var> array. 
    This method is used internally to add classes provided by modules.
*/
- (void)addClassesWithNames:(NSArray *)names
{
    [self addNamedObjectsFromDictionary:STClassDictionaryWithNames(names)];
}

/**
   Load StepTalk module with the name <var>moduleName</var>. Modules are stored
   in the Library/StepTalk/Modules directory.
 */

- (void) loadModule:(NSString *)moduleName
{
    NSBundle     *bundle;
    
    bundle = [NSBundle stepTalkBundleWithName:moduleName];

    [self includeBundle:bundle];
}

/**
    Include scripting capabilities advertised by the framework with name 
    <ivar>frameworkName</ivar>. If the framework is already loaded, nothing
    happens.
*/
- (BOOL)includeFramework:(NSString *)frameworkName
{
    NSBundle *bundle;
    
    bundle = [NSBundle bundleForFrameworkWithName:frameworkName];
    
    if(!bundle)
    {
        return NO;  
    }

    return [self includeBundle:bundle];
}

/**
    Include scripting capabilities advertised by the bundle 
    <ivar>aBundle</ivar>. If the bundle is already loaded, nothing
    happens.
*/
- (BOOL)includeBundle:(NSBundle *)aBundle
{
    STBundleInfo *info;
    
    /* Ignore already included bundles. */
    if([loadedBundles containsObject:[aBundle bundlePath]])
    {
        NSLog(@"Bundle '%@' already included.", [aBundle bundlePath]);
        return YES;
    }

    info = [STBundleInfo infoForBundle:aBundle];

    if(!info)
    {
        return NO;
    }

    [self addNamedObjectsFromDictionary:[info namedObjects]];

    [self addClassesWithNames:[info publicClassNames]];

    if(!loadedBundles)
    {
        loadedBundles = [[NSMutableArray alloc] init];
    }

    /* FIXME: is this sufficient? */
    [loadedBundles addObject:[aBundle bundlePath]];
    
    return YES;
}

/* ----------------------------------------------------------------------- 
   Objects
   ----------------------------------------------------------------------- */

/**
    Return object with name <var>objName</var>. If object is not found int the
    object dictionary, then object finders are used to try to find the object.
    If object is found by an object finder, then it is put into the object
    dicitonary. If there is no object with given name, <var>nil</var> is 
    returned.
  */

- (id)objectWithName:(NSString *)objName
{
    NSEnumerator *enumerator;
    id            obj;
    id            finder;
    
    obj = [super objectWithName:objName];

    if(!obj)
    {
        enumerator = [objectFinders objectEnumerator];
        while( (finder = [enumerator nextObject]) )
        {
            obj = [finder objectWithName:objName];
            if(obj)
            {
                [self setObject:obj forName:objName];
                break;
            }
        }
    }
    
    /* FIXME: Warning: possible security problem in the future */
    /* If there is no such object and full scripting is enabled, then
       class namespace is searched */
    if(!obj && fullScripting)
    {
        obj = NSClassFromString(objName);
    }

    return obj;
}

/* FIXME: rewrite, it is too sloooooow */
- (STClassInfo *)findClassInfoForObject:(id)anObject
{
    STClassInfo *info = nil;
    NSString    *className;
    NSString    *origName;
    Class        class;
    
    if(!anObject)
    {
        anObject = STNil;
    }

    /* FIXME: temporary solution */
    if( [anObject isProxy] )
    {
        NSLog(@"FIXME: receiver is a distant object");
        info = [classes objectForKey:@"NSProxy"];

        if(!info)
        {
            return [classes objectForKey:@"All"];
        }
        
        return info;
    }

    if([anObject respondsToSelector:@selector(classForScripting)])
    {
        class = [anObject classForScripting];
    }
    else
    {
        class = [anObject class];
    }
    
    className = [anObject className];
    
    if([anObject isClass])
    {
        origName = className = [className stringByAppendingString:@" class"];

        NSLog(@"Looking for class info '%@'...",
                    className);

        info = [infoCache objectForKey:className];
        
        if(info)
        {
            return info;
        }
        
        while( !(info = [classes objectForKey:className]) )
        {
            class = [class superclass];

            if(!class)
            {
                break;
            }
            
            className = [[class className] stringByAppendingString:@" class"];
            NSLog(@"    ... %@?",className);
        }
    }
    else
    {
        origName = className;

        NSLog(@"Looking for class info '%@' (instance)...",
                    className);

        info = [infoCache objectForKey:className];
        if(info)
        {
            return info;
        }

        while( !(info = [classes objectForKey:className]) )
        {
            class = [class superclass];
            if(!class)
            {
                break;
            }
            className = [class className];
            NSLog(@"    ... %@?",className);
        }
    }
    
    if(!info)
    {
        NSLog(@"No class info '%@'",
                    className);
        return nil;
    }

    NSLog(@"Found class info '%@'", className);
                
    [infoCache setObject:info forKey:origName]; 
    return info;
}

- (NSString  *)translateSelector:(NSString *)aString forReceiver:(id)anObject
{
    STClassInfo *class;
    NSString    *selector;

    class = [self findClassInfoForObject:anObject];

    NSLog(@"Lookup selector '%@' class %@", aString, [class behaviourName]);

    selector = [class translationForSelector:aString];

    NSLog(
                @"Found selector '%@'",selector);

#ifdef DEBUG
    if(! [selector isEqualToString:aString])
    {
       NSLog(@"using selector '%@' instead of '%@'",
                    selector,aString);
    }
#endif
    
    if(!selector && fullScripting )
    {
        NSLog(@"using selector '%@' (full scriptig)",
                    aString);

        selector = [aString copy];
    }

    if(!selector)
    {
        [NSException raise:STScriptingException
                     format:@"Receiver of type %@ denies selector '%@'",
                            [anObject className],aString];

        /* if exception is ignored, then try to use original selector  */
        selector = [aString copy];
    }


    return selector;
}

- (NSArray *)knownObjectNames
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator   *enumerator;
    id              finder;
    
    [array addObjectsFromArray:[super knownObjectNames]];
    
    enumerator = [objectFinders objectEnumerator];
    while( (finder = [enumerator nextObject]) )
    {
        [array addObjectsFromArray:[finder knownObjectNames]];
    }

    return [NSArray arrayWithArray:array];
}

/** Register object finder <var>finder</var> under the name <var>name</var> */
- (void)registerObjectFinder:(id)finder name:(NSString*)name
{
    if(!objectFinders)
    {
        objectFinders = [[NSMutableDictionary alloc] init];
    }
    
    [objectFinders setObject:finder forKey:name];
}

/** Register object finder named <var>name</var>. This method will try to find
    an object finder bundle in Library/StepTalk/Finders directories.
*/
- (void)registerObjectFinderNamed:(NSString *)name
{
    NSBundle *bundle;
    NSString *path;
    id        finder;
        
    if([objectFinders objectForKey:name])
    {
        return;
    }
    
    path = STFindResource(name, @"Finders", @"bundle");
    
    if(!path)
    {
        NSLog(@"Unknown object finder with name '%@'", name);
        return;
    }
    
    NSLog(@"Finder '%@'", path);

    bundle = [NSBundle bundleWithPath:path];
    if(!bundle)
    {
        NSLog(@"Unable to load object finder bundle '%@'", path);
        return;
    }

    finder = [[[bundle principalClass] alloc] init];
    if(!finder)
    {
        NSLog(@"Unable to create object finder from '%@'", path);
        return;
    }

    [self registerObjectFinder:finder name:name];
}

/** Remove object finder with name <var>name</var> */
- (void)removeObjectFinderWithName:(NSString *)name
{
    [objectFinders removeObjectForKey:name];
}

@end
