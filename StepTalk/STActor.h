/**
    STActor
    StepTalk actor
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2005 June 30
*/

#import <Foundation/NSObject.h>

#import "STMethod.h"
#import "NSObject+additions.h"

@class NSMutableDictionary;
@class NSDictionary;
@class NSArray;
@class STEnvironment;

@interface STActor:NSObject<NSCoding>
{
    NSMutableDictionary *ivars;
    NSMutableDictionary *methodDictionary;
    
    STEnvironment       *environment;
}
+ actorInEnvironment:(STEnvironment *)env;
- initWithEnvironment:(STEnvironment *)env;
- (void)setEnvironment:(STEnvironment *)env;
- (STEnvironment *)environment;

- (void)addMethod:(id <STMethod>)aMethod;
- (id <STMethod>)methodWithName:(NSString *)aName;
- (void)removeMethod:(id <STMethod>)aMethod;
- (void)removeMethodWithName:(NSString *)aName;
- (NSArray *)methodNames;
- (NSDictionary *)methodDictionary;
@end
