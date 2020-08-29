/**
    NSObject-additions.h
    Various methods for NSObject
  
    This file is part of the StepTalk project.
 
 */

#import <Foundation/NSObject.h>

@interface NSObject (STAdditions)
- (BOOL)isSame:(id)anObject;
- (BOOL)isNil;
- (BOOL)notNil;
@end

@interface NSObject (Development)
- (void)subclassResponsibility:(SEL)sel;
- (void)notImplemented:(SEL)sel;
@end
