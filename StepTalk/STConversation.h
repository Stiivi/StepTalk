/**
    STConversation
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2003 Sep 21
   
    This file is part of the StepTalk project.
 
 */

#import <Foundation/NSObject.h>

@class STEngine;
@class STContext;

@protocol STConversation
/** Set language for the receiver. */
- (void)setLanguage:(NSString *)newLanguage;
- (NSString *)language;
- (NSArray *)knownLanguages;

/** Interpret given string as a script in the receiver environment. */
- (void)interpretScript:(NSString *)aString;
// - (void)interpretScript:(bycopy NSString *)aString inLanguage:(NSString *)lang;

- (id)result;
- (id)resultByCopy;
@end

@interface STConversation:NSObject<STConversation>
{
    STEngine      *engine;
    NSString      *languageName;
    STContext     *context;
    id             returnValue;
}
- initWithContext:(STContext *)aContext 
         language:(NSString *)aLanguage;

- (void)setLanguage:(NSString *)newLanguage;
- (NSString *)language;

- (STContext *)context;

/* Depreciated */
- (id)runScriptFromString:(NSString *)aString;
@end
