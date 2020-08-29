/**
    STFunctions.h
    Misc. functions
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 
 */


#import <Foundation/NSObject.h>

@class NSString;
@class NSArray;
@class NSURL;

NSArray<NSURL *> *NSStandardLibraryPaths(void);
NSArray  *STFindAllResources(NSString *resourceDir, NSString *extension);
NSString *STFindResource(NSString *name,
                         NSString *resourceDir,
                         NSString *extension);
NSString *STUserConfigPath(void);

