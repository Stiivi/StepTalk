/**
    STConversation
 
    Written by: Stefan Urbanek
    Date: 2003 Sep 21
   
    This file is part of the StepTalk project.
 
 */

#import "STConversation.h"

#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>

#import "STEnvironment.h"
#import "STEngine.h"
#import "STLanguageManager.h"

@implementation STConversation
- (id)resultByCopy
{
    return [self result];
}

- (id)runScriptFromString:(NSString *)aString
{
    NSLog(@"Warning: runScriptFromString: in STConversation is deprecated, use -interpretScript: and -returnVale");
    [self interpretScript:aString];
    return [self result];
}

/** Returns all languages that are known in the receiver. Should be used by
    remote calls instead of NSLanguage query which gives local list of
    languages. */
- (NSArray *)knownLanguages
{
    return [[STLanguageManager defaultManager] availableLanguages];
}

- initWithContext:(STContext *)aContext
         language:(NSString *)aLanguage
{
    STLanguageManager  *manager = [STLanguageManager defaultManager];
    self = [super init];

    NSLog(@"Creating conversation %@", self);

    if(!aLanguage || [aLanguage isEqual:@""])
    {
        languageName = [manager defaultLanguage];
    }    
    else
    {
        languageName = aLanguage;
    }
    
    context = aContext;
    return self;
}

- (void)_createEngine
{
    engine = [STEngine engineForLanguage:languageName];
}

- (void)setLanguage:(NSString *)newLanguage
{
    if(![newLanguage isEqual:languageName])
    {
        engine = nil;
        languageName = newLanguage;
    }
}

/** Return name of the language used in the receiver conversation */
- (NSString *)language
{
    return languageName;
}
- (STEnvironment *)environment
{
    NSLog(@"WARNING: -[STConversaion environment] is deprecated, "
          @" use -context instead.");

    return (STEnvironment *)context;
}
- (STContext *)context
{
    return context;
}

- (void)interpretScript:(NSString *)aString
{
    if(!engine)
    {
        [self _createEngine];
    }
    
    returnValue = [engine interpretScript:aString inContext:context];
}
- (id)result
{
    return returnValue;
}
@end
