/**
    STBundleInfo.h
    Bundle scripting information
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2003 Jan 22 
 
    This file is part of the StepTalk project.
 
 */

#import <Foundation/NSBundle.h>

@class NSArray;

@interface STBundleInfo:NSObject
{
    NSBundle     *bundle;
    BOOL          useAllClasses;
    NSArray      *publicClasses;
    NSArray      *allClasses;
    NSDictionary *objectReferenceDictionary;
    NSString     *scriptingInfoClassName;
    Class         scriptingInfoClass;
}
+ infoForBundle:(NSBundle *)aBundle;
- initWithBundle:(NSBundle *)aBundle;

- (NSDictionary *)objectReferenceDictionary;

- (NSDictionary *)namedObjects;

- (NSArray *)publicClassNames;
- (NSArray *)allClassNames;
@end

@interface NSBundle(STAdditions)
+ (NSArray *)stepTalkBundleNames;
+ stepTalkBundleWithName:(NSString *)moduleName;
- (NSDictionary *)scriptingInfoDictionary;

+ (NSArray *)allFrameworkNames;
+ (NSString *)pathForFrameworkWithName:(NSString *)aName;
+ (NSBundle *)bundleForFrameworkWithName:(NSString *)aName;
@end
