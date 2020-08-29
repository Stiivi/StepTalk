/**
    STCompiledScript.h
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
  */

#import <Foundation/NSObject.h>

@class NSDictionary;
@class NSMutableDictionary;
@class NSString;
@class NSArray;
@class STCompiledMethod;
@class STEnvironment;

@interface STCompiledScript:NSObject
{
    NSMutableDictionary *methodDictionary;
    NSArray             *variableNames;
}
- initWithVariableNames:(NSArray *)array;

- (id)executeInEnvironment:(STEnvironment *)env;

- (STCompiledMethod *)methodWithName:(NSString *)name;
- (void)addMethod:(STCompiledMethod *)method;
- (NSArray *)variableNames;
@end

