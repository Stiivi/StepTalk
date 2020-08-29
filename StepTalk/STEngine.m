/**
    STEngine.m
    Scripting engine
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
 */

#import "NSObject+additions.h"

#import "STEngine.h"

#import "STEnvironment.h"
#import "STExterns.h"
#import "STFunctions.h"
#import "STLanguageManager.h"
#import "STMethod.h"
#import "STUndefinedObject.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <Foundation/NSZone.h>

NSZone *STMallocZone = (NSZone *)nil;

@implementation STEngine
+ (void)initialize
{
    if(!STNil)
    {
        STNil = [[STUndefinedObject alloc] init];
    }
}

/**
    Return a scripting engine for language with specified name. The engine
    is get from default language manager.
*/
+ (STEngine *) engineForLanguage:(NSString *)name
{
    STLanguageManager *manager = [STLanguageManager defaultManager];
    
    if(!name)
    {
        [NSException raise:@"STConversationException"
                     format:@"Unspecified language for a new engine."];
        return nil;
    }
    
    return [manager createEngineForLanguage:name];
}

/** Interpret source code <var>code</var> in a context <var>context</var>.
    This is the method, that has to be implemented by those who are writing 
    a language engine. 
    <override-subclass /> 
*/
- (id)interpretScript:(NSString *)script
            inContext:(STContext *)context
{
    [self subclassResponsibility:_cmd];

    return nil;
}

- (BOOL)understandsCode:(NSString *)code 
{
    [self subclassResponsibility:_cmd];

    return NO;
}

- (id <STMethod>)methodFromSource:(NSString *)sourceString
                   forReceiver:(id)receiver
        inContext:(STContext *)env;
{
    [self subclassResponsibility:_cmd];
    return nil;
}
- (id)  executeMethod:(id <STMethod>)aMethod
          forReceiver:(id)anObject
        withArguments:(NSArray *)args
        inContext:(STContext *)env;
{
    [self subclassResponsibility:_cmd];
    return nil;
}
@end
