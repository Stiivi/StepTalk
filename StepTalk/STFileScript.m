/**
    STScript
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2002 Mar 10
 
    This file is part of the StepTalk project.
 
   */

#import "STFileScript.h"

#import "STLanguageManager.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>

@interface NSDictionary(LocalizedKey)
- (id)localizedObjectForKey:(NSString *)key;
@end

@implementation NSDictionary(LocalizedKey)
- (id)localizedObjectForKey:(NSString *)key
{
    
// FIXME: [NSUserDefaults userLanguages] does not seem to exist
// Not sure where it was from
#if 0
    NSEnumerator   *enumerator;
    NSDictionary   *dict;
    NSString       *language;
    NSArray        *languages;
    id              obj = nil;
    
    languages = [NSUserDefaults userLanguages];

    enumerator = [languages objectEnumerator];

    while( (language = [enumerator nextObject]) )
    {
        dict = [self objectForKey:language];
        obj = [dict objectForKey:key];

        if(obj)
        {
            return obj;
        }
    }

    return [(NSDictionary *)[self objectForKey:@"Default"] objectForKey:key];
#endif
    return [self objectForKey: key];
}
@end

@implementation STFileScript
+ scriptWithFile:(NSString *)file
{
    STFileScript *script;
    
    script = [[STFileScript alloc] initWithFile:file];

    return script;
}
/**
    Create a new script from file <var>aFile></var>. Script information will
    be read from 'aFile.stinfo' file containing a dictionary property list.
*/

- initWithFile:(NSString *)aFile
{
    STLanguageManager *langManager = [STLanguageManager defaultManager];
    NSFileManager  *manager = [NSFileManager defaultManager];
    NSDictionary   *info = nil;
    NSString       *infoFile;
    NSString       *lang;
    BOOL            isDir;

    // infoFile = [aFile stringByDeletingPathExtension];
    infoFile = [aFile stringByAppendingPathExtension: @"stinfo"];

    if([manager fileExistsAtPath:infoFile isDirectory:&isDir] && !isDir )
    {
        info = [NSDictionary dictionaryWithContentsOfFile:infoFile];
    }

    self = [super init];
    
    fileName = aFile;
    
    localizedName = [info localizedObjectForKey:@"Name"];

    if(!localizedName)
    {
        localizedName = [[fileName lastPathComponent] 
                                        stringByDeletingPathExtension];
    }
    
    menuKey = [info localizedObjectForKey:@"MenuKey"];
    description = [info localizedObjectForKey:@"Description"];
    lang = [info localizedObjectForKey:@"Language"];

    if(!lang)
    {
        lang = [langManager languageForFileType:[fileName pathExtension]];
    }
    if(!lang)
    {
        lang = @"Unknown";
    }
    
    [self setLanguage:lang];
    
    return self;
}

/** Return file name of the receiver. */
- (NSString *)fileName
{
    return fileName;
}

/** Return menu item key equivalent for receiver. */
- (NSString *)menuKey
{
    return menuKey;
}

/** Returns source string of the receiver script.*/
- (NSString *)source
{
    // #FIXME: Handle error
    return [[NSString alloc] initWithContentsOfFile: fileName
                                           encoding: NSUTF8StringEncoding
                                              error: nil];
}

/** Returns a script name by which the script is identified */
- (NSString *)scriptName
{
    return fileName;
}

/** Returns localized name of the receiver script. */
- (NSString *)localizedName
{
    return localizedName;
}

/** Returns localized description of the script. */
- (NSString *)scriptDescription
{
    return description;
}
/** Returns language of the script. */
- (NSString *)language
{
    return language;
}

/** Compare scripts by localized name. */
- (NSComparisonResult)compareByLocalizedName:(STFileScript *)aScript
{
    return [localizedName caseInsensitiveCompare:[aScript localizedName]];
}
@end
