/**
    STExecutor.m
    Common class for stalk and stexec tools
 
    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2001
   
    This file is part of the StepTalk project.
 */

#import "STExecutor.h"

#import <StepTalk/StepTalk.h>
#import <StepTalk/STFileScript.h>

#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSString.h>


NSString *STExecutorException = @"STExecutorException";

const char *STExecutorCommonOptions = 
"   -help               print this message\n"
"   -list-all-objects   list all available objects\n"
"   -list-classes       list available classes\n"
"   -list-objects       list named instances\n\n"
"   -language lang      force use of language lang\n"
"   -list-languages     list available languages\n"
"   -continue           do not stop when one of scripts failed to execute\n\n";
//"   -set obj=value    define named object 'obj' with string value 'value'\n"

@implementation STExecutor
- (void)createEnvironment
{
    [self subclassResponsibility:_cmd];
}

- (void)executeScripts
{
#ifndef DEBUG
    NSString       *logFmt = @"'%@': execution failed, reason: %@";
#endif
    NSMutableArray *scriptArgs;
    NSString       *scriptFileName;
    NSString       *arg;
    
    scriptFileName = [self nextArgument];

    if(!scriptFileName)
    {
        [self executeScriptFromStandardInputArguments:nil];
        return;
    }

    scriptArgs = [NSMutableArray array];

    do
    {
        [scriptArgs removeAllObjects];
        arg = [self nextArgument];
        while(![arg isEqualToString:@","] && arg != nil)
        {
            [scriptArgs addObject:arg];
            arg = [self nextArgument];
        }

#ifndef DEBUG
        NS_DURING
#endif
            if([scriptFileName isEqualToString:@"-"])
            {
                [self executeScriptFromStandardInputArguments:scriptArgs];
            }
            else
            {
                [self executeScript:scriptFileName withArguments:scriptArgs];
            }

#ifndef DEBUG
        NS_HANDLER
            if(contFlag)
            {
                NSLog(logFmt,scriptFileName,[localException reason]);
            }
            else
            {
                [localException raise];
            }
        NS_ENDHANDLER
#endif

    } while( (scriptFileName = [self nextArgument]) );
}
- (void)executeScriptFromStandardInputArguments:(NSArray *)args
{
    NSFileHandle *handle;
    STContext    *env;
    NSString     *source;
    NSData       *data;

    handle = [NSFileHandle fileHandleWithStandardInput];
    data = [handle readDataToEndOfFile];
    
    source  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if(langName)
    {
        [conversation setLanguage:langName];
    }
    else
    {
        STLanguageManager *langManager = [STLanguageManager defaultManager];
        [conversation setLanguage:[langManager defaultLanguage]];
    }

    if(conversation)
    {
        if([args count] > 0)
        {
            env = [conversation context];
            [env setObject:args forName:@"Args"];
        }
        
        [conversation interpretScript:source];
    }
}

- (void)executeScript:(NSString *)file withArguments:(NSArray *)args;
{
    NSFileManager *manager = [NSFileManager defaultManager];
    STEnvironment *env;
    NSString      *useLanguage;
    NSString      *source;
    BOOL           isDir;
    
    /* Get proper language name */
    if( [manager fileExistsAtPath:file isDirectory:&isDir] && isDir )
    {
        // #FIXME: Handle Error
        source = [NSString stringWithContentsOfFile:file
                                           encoding:NSUTF8StringEncoding
                                              error:NULL];

        if(langName)
        {
            NSLog(@"Using language %@", langName);

            useLanguage = langName;
        }
        else
        {
            STLanguageManager *langManager = [STLanguageManager defaultManager];
            NSLog(@"Using language for file extension %@",
                       [file pathExtension]);
            useLanguage = [langManager languageForFileType:[file pathExtension]];
        }
    }
    else
    {
        STScriptsManager *sm;
        STFileScript     *script;

        /* Try to find it in standard script locations */
        sm  = [[STScriptsManager alloc] initWithDomainName:@"Shell"];
        
        script = [sm scriptWithName:file];
        source = [script source];
        if(!source)
        {
            [NSException  raise:STExecutorException
                         format:@"Could not find script '%@'", file];
            return;
        }
        else
        {
            useLanguage = [script language];
        }
    }

    [conversation setLanguage:useLanguage];

    if(conversation)
    {
        if([args count] > 0)
        {
            /* FIXME: do not cast */
            env = (STEnvironment *)[conversation context];
            [env setObject:args forName:@"Args"];
        }

        [conversation interpretScript:source];
    }
    else
    {
        [NSException  raise:STExecutorException
             format:@"Unable to create a StepTalk conversation."];

    }
}

- (void)listLanguages
{
    NSArray      *languages;    
    NSEnumerator *enumerator;
    NSString     *name;
    
    languages = [[STLanguageManager defaultManager] availableLanguages];

    enumerator = [languages objectEnumerator];    
    
    while( (name = [enumerator nextObject]) )
    {
        printf("%s\n", [name cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

- (NSString *)nextArgument
{
    if(currentArg < [arguments count])
    {
        return [arguments objectAtIndex:currentArg++];
    }
    
    return nil;
}

- (void)reuseArgument
{
    currentArg--;
}

- (void)listObjects
{
    NSEnumerator *enumerator;
    NSDictionary *dict;
    NSString     *name;
    NSArray      *objects;    

    dict = [[conversation context] objectDictionary];
    
    objects = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    enumerator = [objects objectEnumerator];    
    
    if(listObjects == STListAll)
    {
        while( (name = [enumerator nextObject]) )
        {
            printf("%s\n", [name cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }
    else if (listObjects == STListClasses)
    {
        while( (name = [enumerator nextObject]) )
        {
            if([[dict objectForKey:name] isClass])
            {
                printf("%s\n", [name cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }
    }
    else /* (listObjects == STListInstances) */
    {
        while( (name = [enumerator nextObject]) )
        {
            if(! [[dict objectForKey:name] isClass])
            {
                printf("%s\n", [name cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }
    }
    
}

- (int)parseOptions
{
    BOOL      isOption = NO;
    NSString *arg;

    listObjects = STListNone;

    while( (arg = [self nextArgument]) )
    {
        isOption = NO;
        if( [arg isEqualToString:@"-"] )
        {
            isOption = NO;
        }
        else if( [arg hasPrefix:@"--"] )
        {
            arg = [arg substringFromIndex:2];
            isOption = YES;
        }
        else if( [arg hasPrefix:@"-"] )
        {
            arg = [arg substringFromIndex:1];
            isOption = YES;
        }
        
        if ([@"help" hasPrefix:arg])
        {
            [self printHelp];
            return 1;
        }
        else if ([@"list-languages" hasPrefix:arg])
        {
            [self listLanguages];
            return 1;
        }
/*
        else if ([@"list-engines" hasPrefix:arg])
        {
            [self listEngines];
            return 1;
        }
        */
        
        else if ([@"list-objects" hasPrefix:arg])
        {
            listObjects = STListObjects;
        }
        else if ([@"list-classes" hasPrefix:arg])
        {
            listObjects = STListClasses;
        }
        else if ([@"list-all-objects" hasPrefix:arg])
        {
            listObjects = STListAll;
        }
        else if ([@"continue" hasPrefix:arg])
        {
            contFlag = YES;
        }
        else if ([@"language" hasPrefix:arg])
        {
            langName = [self nextArgument];
            if(!langName)
            {
                [NSException raise:STExecutorException
                            format:@"Language name expected"];
            }
        }
        else
        {
            if(!isOption)
            {
                break;
            }
            else
            {
                if( [self processOption:arg] )
                {
                    return 1;
                }
            }
        }
	}
    
    if(arg)
    {
        [self reuseArgument];
    }
    
    return 0;
}

- (void)beforeExecuting
{
}

- (void)afterExecuting
{
}

- (void)runWithArguments:(NSArray *)args
{
    arguments = args;
    currentArg = 1;
    
    if([self parseOptions])
    {
        return;
    }

    [self beforeExecuting];

    [self createConversation];
    [self executeScripts];
    
    [self afterExecuting];

    if(listObjects != STListNone)
    {
        [self listObjects];
    }
}

- (void)printHelp
{
    [self subclassResponsibility:_cmd];
}

- (int)processOption:(NSString *)option
{
    [self subclassResponsibility:_cmd];
    
    return 0;
}
- (void)createConversation
{
    [self subclassResponsibility:_cmd];
}
@end
