/**
    STScript
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2002 Mar 10
 
    This file is part of the StepTalk project.
   */

#import <Foundation/NSObject.h>

@interface STScript:NSObject
{
    NSString *source;
    NSString *language;
}
+ scriptWithSource:(NSString *)aString language:(NSString *)lang;
- initWithSource:(NSString *)aString language:(NSString *)lang;
- (NSString *)source;
- (void)setSource:(NSString *)aString;
- (NSString *)language;
- (void)setLanguage:(NSString *)name;
@end
