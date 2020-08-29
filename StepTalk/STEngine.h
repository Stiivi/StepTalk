/**
    STEngine.h
    Scripting engine
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
 */

#import <Foundation/NSObject.h>

@protocol STMethod;

@class STContext;
@class STEnvironment;
@class STLanguageEngine;

/** STEngine is abstract class for language engines used to intepret scripts.*/
@interface STEngine:NSObject
{
}

/** Instance creation */
+ (STEngine *) engineForLanguage:(NSString *)name;
// - (BOOL)canInterpret:(NSString *)sourceCode;

- (id)interpretScript:(NSString *)script
            inContext:(STContext *)context;
            
/* Methods */
- (id <STMethod>)methodFromSource:(NSString *)sourceString
                   forReceiver:(id)receiver
                     inContext:(STContext *)context;
- (id)  executeMethod:(id <STMethod>)aMethod
          forReceiver:(id)anObject
        withArguments:(NSArray *)args
            inContext:(STContext *)context;

- (BOOL)understandsCode:(NSString *)code;
@end
