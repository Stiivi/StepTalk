/**
    NSArray-additions.h
    Various methods for NSArray
  
    This file is part of the StepTalk project.
 */

#import <Foundation/NSArray.h>

@class STBlock;

@interface NSArray (STCollecting)
- do:(STBlock *)block;
- select:(STBlock *)block;
- reject:(STBlock *)block;
- collect:(STBlock *)block;
- detect:(STBlock *)block;
@end
