/**
    NSInvocation+additions.h
    Various NSInvocation additions
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
*/

#import <Foundation/NSInvocation.h>

void STGetValueOfTypeFromObject(void *value, const char *type, id anObject);
id   STObjectFromValueOfType(void *value, const char *type);

@interface NSInvocation(STAdditions)
+ invocationWithTarget:(id)target selectorName:(NSString *)selectorName;
+ invocationWithTarget:(id)target selector:(SEL)selector;

- (void)setArgumentAsObject:(id)anObject atIndex:(int)anIndex;
- (id)getArgumentAsObjectAtIndex:(int)anIndex;
- (id)returnValueAsObject;
@end

