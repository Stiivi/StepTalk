/* 2003 Aug 5 */

#import <Foundation/NSObject.h>

#import "STMethod.h"

@class NSMutableDictionary;
@class NSDictionary;
@class NSArray;
@class STEnvironment;

@protocol STScriptObject
- (NSArray *)instanceVariableNames;
@end

@interface STScriptObject:NSObject<NSCoding, STScriptObject>
{
    NSMutableDictionary *ivars;
    NSMutableDictionary *methodDictionary;
    
    STEnvironment       *environment;
}
+ scriptObject;
- initWithInstanceVariableNames:(NSString *)names;

- (void)setEnvironment:(STEnvironment *)env;
- (STEnvironment *)environment;

- (void)setObject:(id)anObject forVariable:(NSString *)aName;
- (id)objectForVariable:(NSString *)aName;

- (NSArray *)instanceVariableNames;

- (void)addMethod:(id <STMethod>)aMethod;
- (id <STMethod>)methodWithName:(NSString *)aName;
- (void)removeMethod:(id <STMethod>)aMethod;
- (void)removeMethodWithName:(NSString *)aName;
- (NSArray *)methodNames;
- (NSDictionary *)methodDictionary;
@end
