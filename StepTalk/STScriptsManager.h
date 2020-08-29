/**
    STScriptsManager
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2002 Mar 10
 
    This file is part of the StepTalk project.
 
   */

#import <Foundation/NSObject.h>

@class NSArray;
@class STFileScript;

@interface STScriptsManager:NSObject
{
    NSString *scriptsDomainName;
    NSArray  *scriptSearchPaths;
}
+ defaultManager;

- initWithDomainName:(NSString *)name;

- (NSString *)scriptsDomainName;

- (void)setScriptSearchPathsToDefaults;
- (NSArray *)scriptSearchPaths;
- (void)setScriptSearchPaths:(NSArray *)anArray;

- (NSArray *)validScriptSearchPaths;
- (STFileScript *)scriptWithName:(NSString*)aString;

- (NSArray *)allScripts;
@end
