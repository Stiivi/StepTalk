/**
    STActor
    StepTalk actor
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2005 June 30
     
    This file is part of the StepTalk project.
*/

#import "STActor.h"

#import "NSInvocation+additions.h"
#import "STEngine.h"
#import "STEnvironment.h"
#import "STExterns.h"
#import "STObjCRuntime.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSString.h>

@implementation STActor
/** Return new instance of script object without any instance variables */
+ actorInEnvironment:(STEnvironment *)env
{
    return [[self alloc] initWithEnvironment:env];
}
+ actor
{
    return [[self alloc] init];
}
- init
{
    self = [super init];    
    methodDictionary = [[NSMutableDictionary alloc] init];
    ivars = [[NSMutableDictionary alloc] init];
    return self;
}
- initWithEnvironment:(STEnvironment *)env;
{
    self = [self init];
    [self setEnvironment:env];

    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    /* FIXME: this is not optimal */
    if([ivars valueForKey:key] != nil)
    {
        [ivars setValue:value forKey:key];
    }
    else
    {
        [super setValue:value forKey:key];
    }
}
- (id)valueForKey:(NSString *)key
{
    id value = nil;
    
    value = [ivars valueForKey:key];
    
    if(value == nil)
    {
        value = [super valueForKey:key];
    }
    return value;
}

- (NSArray *)instanceVariableNames
{
    return [ivars allKeys];
}
- (void)setInstanceVariables:(NSDictionary *)dictionary
{
    [ivars removeAllObjects];
    [ivars addEntriesFromDictionary:dictionary];
}
- (NSDictionary *)instanceVarables
{
    return [NSDictionary dictionaryWithDictionary:ivars];
}
- (void)addMethod:(id <STMethod>)aMethod
{
    [methodDictionary setObject:aMethod forKey:[aMethod methodName]];
}
- (id <STMethod>)methodWithName:(NSString *)aName
{
    return [methodDictionary objectForKey:aName];
}
- (void)removeMethod:(id <STMethod>)aMethod
{
    [self notImplemented:_cmd];
}
- (void)removeMethodWithName:(NSString *)aName
{
    [methodDictionary removeObjectForKey:aName];
}
- (NSArray *)methodNames
{
    return [methodDictionary allKeys];
}
- (NSDictionary *)methodDictionary
{
    return [NSDictionary dictionaryWithDictionary:methodDictionary];
}
/** Set object's environment. Note: This method should be replaced by
some other, more clever mechanism. */
- (void)setEnvironment:(STEnvironment *)env
{
    environment = env;
}
- (STEnvironment *)environment
{
    return environment;
}
- (BOOL)respondsToSelector:(SEL)aSelector
{
    if( [super respondsToSelector:(SEL)aSelector] )
    {
        return YES;
    }
    
    return ([methodDictionary objectForKey:NSStringFromSelector(aSelector)] != nil);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature = nil;
    
    signature = [super methodSignatureForSelector:sel];

    if(!signature)
    {
        signature = STConstructMethodSignatureForSelector(sel);
    }

    return signature;
}

- (void) forwardInvocation:(NSInvocation *)invocation
{
    STEngine       *engine;
    id <STMethod>   method;
    NSString       *methodName = NSStringFromSelector([invocation selector]);
    NSMutableArray *args;
    id              arg;
    int             index;
    NSUInteger      count;
    id              retval = nil;

    method = [methodDictionary objectForKey:methodName];
    
    if(!method)
    {
        [NSException raise:@"STActorException"
                     format:@"No script object method with name '%@'",
                            methodName];
        return;
    }

    engine = [STEngine engineForLanguage:[method languageName]];   

    /* Get arguments as array */
    count = [[invocation methodSignature] numberOfArguments];
    args = [NSMutableArray array];
    
    for(index = 2; index < count; index++)
    {
        arg = [invocation getArgumentAsObjectAtIndex:index];

        if (arg == nil)
        { 
            [args addObject:STNil];
        }
        else 
        { 
            [args addObject:arg];
        } 
    }

    retval = [engine executeMethod:method
                       forReceiver:self
                     withArguments:args
                         inContext:environment];

    [invocation setReturnValue:&retval];
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:methodDictionary];
    [coder encodeObject:ivars];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; //[super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &methodDictionary];
    [decoder decodeValueOfObjCType: @encode(id) at: &ivars];
    return self;
}
@end
