/**
    SmalltalkEngine
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2001 Oct 24
 
    This file is part of the StepTalk project.
 
 */

#import "SmalltalkEngine.h"

#import "STCompiler.h"
#import "STCompiledCode.h"
#import "STCompiledMethod.h"
#import "STCompiledScript.h"
#import "STBytecodeInterpreter.h"

#import <StepTalk/STContext.h>
#import <StepTalk/STEnvironment.h>
#import <StepTalk/STMethod.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>

@implementation SmalltalkEngine
- (BOOL)canInterpret:(NSString *)sourceCode
{
    STCompiler            *compiler;
    STCompiledScript      *script = nil;
    BOOL                   retval = NO;

    compiler = [[STCompiler alloc] init];

    @try {
        script = [compiler compileString:sourceCode];
    }
    @catch (NSException *exception) {
        NSLog(@"Smalltalk: Ignoring: %@", [exception reason]);
    }

    if(script)
    {
        retval = YES;
    }
    
    return retval;
}

- (id) executeCode:(NSString *)sourceCode 
       inEnvironment:(STEnvironment *)env
{
    NSLog(@"%@ is depreciated, use interpretScript:inContext: instead",
                NSStringFromSelector(_cmd));
    return [self interpretScript:sourceCode inContext:env];
}

- (id)interpretScript:(NSString *)script
            inContext:(STEnvironment *)context
{
    STCompiler            *compiler;
    STCompiledScript      *compiledScript;
    id                     retval = nil;

    compiler = [[STCompiler alloc] init];

    compiledScript = [compiler compileString:script];
    retval = [compiledScript executeInEnvironment:context];

    return retval;
}

- (id <STMethod>)methodFromSource:(NSString *)sourceString
                      forReceiver:(id)receiver
                    inEnvironment:(STEnvironment *)env
{
    NSLog(@"%@ is depreciated, use methodFromSource:forReceiver:inContext: instead",
                NSStringFromSelector(_cmd));
    return [self methodFromSource:sourceString
                        forReceiver:receiver
                            inContext:env];
}

- (id <STMethod>)methodFromSource:(NSString *)sourceString
                      forReceiver:(id)receiver
                        inContext:(STContext *)context
{
    STCompiler   *compiler;
    id <STMethod> method;
    
    compiler = [[STCompiler alloc] init];
    
    method = [compiler compileMethodFromSource:sourceString
                                   forReceiver:receiver];

    return method;
}
- (id)  executeMethod:(id <STMethod>)aMethod
          forReceiver:(id)anObject
        withArguments:(NSArray *)args
        inEnvironment:(STEnvironment *)env
{
    NSLog(@"%@ is depreciated, use ...inContext: instead",
                NSStringFromSelector(_cmd));
    return [self executeMethod:aMethod
                    forReceiver:anObject
                    withArguments:args
                    inContext:env];
}
// #FIXME: This says context but it is Environment
- (id)  executeMethod:(id <STMethod>)aMethod
          forReceiver:(id)anObject
        withArguments:(NSArray *)args
            inContext:(STEnvironment *)context
{
    STBytecodeInterpreter *interpreter;
    id                     result;
    interpreter = [STBytecodeInterpreter interpreterWithEnvrionment:context];

    result = [interpreter interpretMethod:(STCompiledMethod *)aMethod
                              forReceiver:anObject
                                arguments:args];
    return result;
}
@end
