/**
    STEnvironmentDescription.h
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000 Jun 16
 
    This file is part of the StepTalk project.
 
 */

#import <Foundation/NSObject.h>

enum
{
    STUndefinedRestriction,
    STAllowAllRestriction,
    STDenyAllRestriction
};

@class NSDictionary;
@class NSMutableArray;
@class NSMutableDictionary;

@interface STEnvironmentDescription:NSObject
{
    NSMutableArray      *usedDefs;
    NSMutableDictionary *classes;
    NSMutableDictionary *behaviours;
    NSMutableDictionary *aliases;
    NSMutableArray      *modules;
    NSMutableArray      *frameworks;
    NSMutableArray      *finders;

    int                  restriction;
}
+ (NSString *)defaultDescriptionName;

+ descriptionWithName:(NSString *)descriptionName;
+ descriptionFromDictionary:(NSDictionary *)dictionary;

- initWithName:(NSString *)defName;
- initFromDictionary:(NSDictionary *)def;

- (void)updateFromDictionary:(NSDictionary *)def;
- (void)updateClassWithName:(NSString *)className description:(NSDictionary *)def;

- (NSMutableDictionary *)classes;
- (NSArray *)modules;
- (NSArray *)frameworks;
- (NSArray *)objectFinders;
@end

