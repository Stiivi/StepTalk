/**
    STObjectReference.h
    Reference to object in NSDictionary.
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of StepTalk.
 */

#import <Foundation/NSObject.h>

@class NSString;

@interface STObjectReference:NSObject
{
    NSString *identifier;
    id        target;
}

- initWithIdentifier:(NSString *)ident
              target:(id)anObject;
                
- (void)setObject:anObject;
- (id)object;

- (NSString *)identifier;
- (id) target;
@end

