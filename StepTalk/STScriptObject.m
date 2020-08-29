/* 2003 Aug 5 */

#import "STScriptObject.h"

#import "NSObject+additions.h"
#import "NSInvocation+additions.h"
#import "STEnvironment.h"
#import "STEngine.h"
#import "STExterns.h"
#import "STObjCRuntime.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSString.h>

@implementation STScriptObject
/** Return new instance of script object without any instance variables */
+ scriptObject
{
    return [[self alloc] init];
}
- init
{
    self = [super init];
    
    methodDictionary = [[NSMutableDictionary alloc] init];
    
    return self;
}
- initWithInstanceVariableNames:(NSString *)names
{
    return [self init];
}

- (void)setObject:(id)anObject forVariable:(NSString *)aName
{
    [self notImplemented:_cmd];
}
- (id)objectForVariable:(NSString *)aName
{
    [self notImplemented:_cmd];
    return nil;
}

- (NSArray *)instanceVariableNames
{
    return [ivars allKeys];
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
        [NSException raise:@"STScriptObjectException"
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
