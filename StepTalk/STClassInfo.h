/**
    STClassInfo.h
    Objective-C class wrapper
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
  */

#import "STBehaviourInfo.h"

@class NSString;
@class NSMutableDictionary;

@interface STClassInfo:STBehaviourInfo
{
    STClassInfo  *superclass;
    NSString     *superclassName;
    BOOL          allowAll;

    NSMutableDictionary      *selectorCache;
}
- (NSString *)translationForSelector:(NSString *)aString;
                   
- (void)setSuperclassInfo:(STClassInfo *)classInfo;
- (STClassInfo *)superclassInfo;

- (void)setSuperclassName:(NSString *)aString;
- (NSString *)superclassName;

- (void)setAllowAllMethods:(BOOL)flag;
- (BOOL)allowAllMethods;
@end
