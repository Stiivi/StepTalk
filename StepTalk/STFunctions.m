/**
    STFunctions.m
    Misc. functions
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 
 */

#import "STFunctions.h"

#import "STExterns.h"
#import "STContext.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSString.h>

@class STContext;

NSArray<NSURL *> *NSStandardLibraryPaths() {
    return [[NSFileManager defaultManager]
                URLsForDirectory:NSLibraryDirectory
                       inDomains:NSAllDomainsMask];
}

NSString *STFindResource(NSString *name,
                         NSString *resourceDir,
                         NSString *extension)
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray       *paths;
    NSEnumerator  *enumerator;
    NSString      *path;
    NSString      *file;

    paths = NSStandardLibraryPaths();

    enumerator = [paths objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
    
        file = [path stringByAppendingPathComponent:STLibraryDirectory];
        file = [file stringByAppendingPathComponent:resourceDir];
        file = [file stringByAppendingPathComponent:name];

        if( [manager fileExistsAtPath:file] )
        {
            return file;
        }

        file = [file stringByAppendingPathExtension:extension];

        if( [manager fileExistsAtPath:file] )
        {
            return file;
        }
    }

    return [[NSBundle bundleForClass:[STContext class]]
                        pathForResource:name
                                ofType:extension
                                inDirectory:resourceDir];
}

NSArray *STFindAllResources(NSString *resourceDir, NSString *extension)
{
    NSFileManager         *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirs;
    
    NSArray       *paths;
    NSEnumerator  *enumerator;
    NSString      *path;
    NSString      *file;
    NSMutableArray *resources = [NSMutableArray array];

    paths = NSStandardLibraryPaths();

    enumerator = [paths objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
        path = [path stringByAppendingPathComponent:STLibraryDirectory];
        path = [path stringByAppendingPathComponent:resourceDir];
        
        if( ![manager fileExistsAtPath:path] )
        {
            continue;
        }

        dirs = [manager enumeratorAtPath:path];
        
        while( (file = [dirs nextObject]) )
        {
            if( [[[dirs directoryAttributes] fileType] 
                            isEqualToString:NSFileTypeDirectory]
                && [[file pathExtension] isEqualToString:extension])
            {
                file = [path stringByAppendingPathComponent:file];
                [resources addObject:file];
            }
        }
    }

    return [NSArray arrayWithArray:resources];
}

NSString *STUserConfigPath(void)
{
    NSString *path = nil;
    NSArray  *paths;    

    paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                NSUserDomainMask, YES);
    path = [paths objectAtIndex: 0];

    path = [path stringByAppendingPathComponent:STLibraryDirectory];
    path = [path stringByAppendingPathComponent:@"Configuration"];

    return path;  
}
