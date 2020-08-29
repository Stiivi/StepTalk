/**
    STSmalltalkScriptObject.m
    Object that represents script 
 
    This file is part of the StepTalk project.
 
 */

#import <Foundation/Foundation.h>
#import <StepTalk/StepTalk.h>

#import "STSmalltalkScriptObject.h"

#import "STBytecodeInterpreter.h"
#import "STCompiledScript.h"

@implementation STSmalltalkScriptObject
- initWithEnvironment:(STEnvironment *)env
       compiledScript:(STCompiledScript *)compiledScript
{
    NSEnumerator *enumerator;
    NSString     *varName;

    self = [super init];

    NSLog(@"creating script object %p with ivars %@",compiledScript,
                [compiledScript variableNames]);
                
    environment = env;
    script = compiledScript;
    variables = [[NSMutableDictionary alloc] init];

    enumerator = [[compiledScript variableNames] objectEnumerator];

    while( (varName = [enumerator nextObject]) )
    {
        [variables setObject:STNil forKey:varName];
    }
    
    return self;
}

- (STCompiledScript *)script
{
    return script;
}
- (void)setValue:(id)value forKey:(NSString *)key
{
    if(value == nil)
    {
        value = STNil;
    }

    /* FIXME: check this for potential abuse and for speed improvements */    
    if([variables objectForKey:key])
    {
        [variables setObject:value forKey:key];
    }
    else
    {
        [super setValue:value forKey:key];
    }
}
- (id)valueForKey:(NSString *)key
{
    id value = [variables objectForKey:key];

    if(value)
    {
        return value;
    }
    else
    {
        return [super valueForKey:key];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSLog(@"?? script object responds to %@",
                NSStringFromSelector(aSelector));
    
    if( [super respondsToSelector:(SEL)aSelector] )
    {
        return YES;
    }
    
    return ([script methodWithName:NSStringFromSelector(aSelector)] != nil);
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
    STCompiledMethod  *method;
    NSString          *methodName = NSStringFromSelector([invocation selector]);
    NSMutableArray    *args;
    id                arg;
    int               index;
    NSUInteger               count;
    id                retval = nil;

    if(!interpreter)
    {
        NSLog(@"creating new interpreter for script '%@'",
                   name);
        interpreter = [[STBytecodeInterpreter alloc] initWithEnvironment:environment];

    }
    

    if([methodName isEqualToString:@"exit"])
    {
        [interpreter halt];
        return;
    }

    method = [script methodWithName:methodName];
    
    count = [[invocation methodSignature] numberOfArguments];

    NSLog(@"script object perform: %@ with %lu args",
                methodName,count-2);

    args = [[NSMutableArray alloc] init];
    
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

    retval = [interpreter interpretMethod:method
                              forReceiver:self
                                arguments:args];
    
    [invocation setReturnValue:&retval];
}
@end
