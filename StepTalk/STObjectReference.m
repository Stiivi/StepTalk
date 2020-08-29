/**
    STObjectReference.m
    Reference to object in NSDictionary.
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of StepTalk.
  */

#import "STObjectReference.h"

#import "STExterns.h"

#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

@implementation STObjectReference
- initWithIdentifier:(NSString *)ident
              target:(id)anObject;
{
    self = [super init];
    identifier = [ident copy];
    target = anObject;
    
    return self;
}                
- (NSString *)identifier
{
    return identifier;
}
- (id) target
{
    return target;
}
- (void)setObject:anObject
{
    if(!anObject)
    {
        anObject = STNil;
    }

    [(NSMutableDictionary *)target setObject:anObject forKey:identifier];
}
- object
{
    return [(NSDictionary *)target objectForKey:identifier];
}
@end

