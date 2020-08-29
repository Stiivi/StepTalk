/**
    STExecutor.h
    Common class for stalk and stexec tools
 
    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2001
   
    This file is part of the StepTalk project.
  */

#import <Foundation/NSObject.h>

extern NSString *STExecutorException;
extern const char *STExecutorCommonOptions;

extern void STPrintCassStats(void);

enum
{
    STListNone,
    STListObjects,
    STListClasses,
    STListAll
};


@class STConversation;
@class STEnvironment;
@class NSString;
@class NSArray;

@interface STExecutor:NSObject
{
    STConversation *conversation;

    NSString      *langName;
    
    NSArray       *arguments;
    unsigned int   currentArg;
    
    BOOL           contFlag;
    int            listObjects;
}
- (void)createConversation;
- (void)printHelp;
- (int)processOption:(NSString *)option;
- (void)executeScript:(NSString *)fileName withArguments:(NSArray *)args;
- (void)executeScriptFromStandardInputArguments:(NSArray *)args;
- (int)parseOptions;
- (void)executeScripts;
- (NSString *)nextArgument;
- (void)reuseArgument;
- (void)runWithArguments:(NSArray *)argsArray;
@end
