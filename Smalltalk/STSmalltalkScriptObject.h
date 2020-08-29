/**
    STSmalltalkScriptObject.h
    Object that represents script 
 
    This file is part of the StepTalk project.
 */

#import <Foundation/NSObject.h>

@class NSMutableArray;
@class NSMutableDictionary;
@class STBytecodeInterpreter;
@class STCompiledScript;
@class STEnvironment;

@interface STSmalltalkScriptObject:NSObject
{
    NSString              *name;
    STBytecodeInterpreter *interpreter;
    STEnvironment         *environment;
    STCompiledScript      *script;
    NSMutableDictionary   *variables;
}
- initWithEnvironment:(STEnvironment *)env
       compiledScript:(STCompiledScript *)compiledScript;
       
@end
