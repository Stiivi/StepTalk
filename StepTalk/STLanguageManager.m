#import "STLanguageManager.h"

#import "STExterns.h"

#import <Foundation/NSDebug.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSUserDefaults.h>

#import <objc/runtime.h>

static STLanguageManager *defaultManager = nil;
@interface STLanguageManager(StepTalkPrivate)
- (void) _registerKnownLanguages;
- (void) _registerLanguagesFromPath:(NSString *)path;
- (void) _updateFileTypes;
@end


@implementation STLanguageManager
+ (STLanguageManager *)defaultManager
{
    if(!defaultManager)
    {
        defaultManager = [[STLanguageManager alloc] init];
    }
    return defaultManager;
}
- init
{
    self = [super init];
    
    languages = [[NSMutableArray alloc] init];
    engineClasses = [[NSMutableDictionary alloc] init];
    languageInfos = [[NSMutableDictionary alloc] init];
    languageBundles = [[NSMutableDictionary alloc] init];
    fileTypes = [[NSMutableDictionary alloc] init];
    
    [self _registerKnownLanguages];

    return self;
}

- (void) _registerKnownLanguages
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator  *enumerator;
    NSBundle      *bundle;
    NSString      *path;
    NSArray       *paths;
    BOOL           isDir;
    
    paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, 
                                                    NSAllDomainsMask, YES);

    enumerator = [paths objectEnumerator];
    
    /* find languages at knowl loactions */
    while( (path = [enumerator nextObject]) )
    {
        path = [path stringByAppendingPathComponent:@"StepTalk"];
        path = [path stringByAppendingPathComponent:STLanguageBundlesDirectory];

        if([manager fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            [self _registerLanguagesFromPath:path];
        }
    }

    /* find languages at known loactions */
    enumerator = [[NSBundle allBundles] objectEnumerator];
    while( (bundle = [enumerator nextObject]) )
    {
        [self registerLanguagesFromBundle:bundle];
    }

}
- (void)_registerLanguagesFromPath:(NSString *)path
{
    NSDirectoryEnumerator  *enumerator;
    NSString               *file;
    NSBundle               *bundle;
    
    NSLog(@"Looking in path %@", path);

    enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    while( (file = [enumerator nextObject]) )
    {
        if([[file pathExtension] isEqualToString:STLanguageBundleExtension])
        {
            file = [path stringByAppendingPathComponent:file];
            bundle = [NSBundle bundleWithPath:file];
            [self registerLanguagesFromBundle:bundle];
        }
    }
}

- (void)registerLanguage:(NSString *)language 
             engineClass:(Class)class
                    info:(NSDictionary *)info
{
    if([languages containsObject:language])
    {
        [NSException raise:@"StepTalkException"
                     format:@"Language '%@' already registered",
                        language];
        return;
    }
    if(!language || [language isEqualToString:@""])
    {
        [NSException raise:@"StepTalkException"
                     format:@"No language specified for registration of class '%s'",
                        class_getName(class)];
        return;
    }
    if(!class)
    {
        [NSException raise:@"StepTalkException"
            format:@"Unable to regirster language %@. No class specified.",
                        language];
        return;
    }
    
    [languages addObject:language];
    [engineClasses setObject:class forKey:language];
    [languageBundles setObject:[NSBundle bundleForClass:class] forKey:language];
    [languageInfos setObject:info forKey:language];

    [self _updateFileTypes];
}

- (void)registerLanguagesFromBundle:(NSBundle *)bundle
{
    NSDictionary *info;
    NSDictionary *langDict;
    NSEnumerator *enumerator;
    NSString     *language;
    int           foundLanguages = 0;

    /*
    StepTalkLanguages = { Smalltalk = { EngineClass = SmalltalkEngine}  };
    */

    NSLog(@"Registering languages from bundle %@", [bundle bundlePath]);

    info = [bundle infoDictionary];
    langDict = [info objectForKey:@"StepTalkLanguages"];
    enumerator = [langDict keyEnumerator];

    while( (language = [enumerator nextObject]) )
    {
        info = [langDict objectForKey:language];

        if([languages containsObject:language])
        {
            /* FIXME: issue this warning
            NSLog(@"Warning: Language %@ already registered in bundle at path %@",
                language, [[languageBundles objectForKey:language] bundlePath]);
            */
            continue;
        }
        
        NSLog(@"Found language %@", language);

        [languages addObject:language];
        [languageInfos setObject:info forKey:language];
        [languageBundles setObject:bundle forKey:language];
        foundLanguages = foundLanguages + 1;
    }
    
    if(foundLanguages == 0)
    {
        NSLog(@"No languages found in bundle %@", [bundle bundlePath]);
    }
    
    [self _updateFileTypes];
}

- (void)_updateFileTypes
{
    NSEnumerator *languageEnumerator;
    NSEnumerator *fileEnumerator;
    NSDictionary *info;
    NSString     *language;
    NSString     *type;
    
    [fileTypes removeAllObjects];

    languageEnumerator = [languages objectEnumerator];

    while( (language = [languageEnumerator nextObject]) )
    {
        info = [languageInfos objectForKey:language];
        fileEnumerator = [[info objectForKey:@"FileTypes"] objectEnumerator];

        while( (type = [fileEnumerator nextObject]) )
        {
            [fileTypes setObject:language forKey:type];
        }
    }
}

- (NSArray *)availableLanguages
{
    return [NSArray arrayWithArray:languages];
}

/** Returns the name of default scripting language specified by the
    STDefaultLanguage default. If there is no such default in user's
    defaults database, then Smalltalk is used. */

- (NSString *)defaultLanguage
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString       *name= [defs objectForKey:@"STDefaultLanguage"];
    
    if(!name)
    {
        return @"Smalltalk";
    }
    else
    {
        return name;
    }
}


- (NSArray *)knownFileTypes
{
    return [fileTypes allKeys];
}

- (void)removeLanguage:(NSString *)language
{
    [engineClasses removeObjectForKey:language];
    [languageInfos removeObjectForKey:language];
    [languageBundles removeObjectForKey:language];
    [languages removeObject:language];
    [self _updateFileTypes];
}

/** Return an engine class for specified language. The class lookup is as follows:
<ul>
<li> internal class dictionary by language name
<li> all loaded classes by class name in the language info dictionary
<li> in the language bundle
<li> in the language bundle as <i>language_nameEngine</i>
</ul>
*/
- (Class)engineClassForLanguage:(NSString *)language
{
    NSString *className;
    NSBundle *bundle;
    Class     class;
    
    NSLog(@"Engine class for language %@ requested", language);
    
    class = [engineClasses objectForKey:language];

    /* If there is no class, load bundle first and try again */
    if(!class)
    {
        className = [(NSDictionary *)[languageInfos objectForKey:language] 
                                            objectForKey:@"EngineClass"];

        NSLog(@"No known class, looking for class named %@", className);

        class = NSClassFromString(className);
        if(class)
        {
            return class;
        }

        /* there is no such class, so try to load class the containing bundle */

        bundle = [languageBundles objectForKey:language];

        NSLog(@"Looking in bundle %@", [bundle bundlePath]);

        if(!bundle)
        {
            [NSException raise:@"StepTalkException"
                format:@"Unable to find engine class for language '%@': No bundle.",
                    language];
            return nil;
        }
        
        class = [bundle classNamed:className];

        if(!class)
        {
        
            className = [language stringByAppendingString:@"Engine"];
            class = [bundle classNamed:className];
            
            if(!class)
            {
                [NSException raise:@"StepTalkException"
                    format:@"Unable to find engine class '%@' for language '%@' in bundle %@.",
                        className, [bundle bundlePath], language];
                return nil;
            }
            
        }
    }
    
    NSLog(@"Got engine class %s'", class_getName(class));
    
    return class;
}

- (STEngine *)createEngineForLanguage:(NSString *)language
{
    Class engineClass;

    engineClass = [self engineClassForLanguage:language];

    return [[engineClass alloc] init];
}

- (NSDictionary *)infoForLanguage:(NSString *)language
{
    return [languageInfos objectForKey:language];
}
- (NSBundle *)bundleForLanguage:(NSString *)language
{
    return [languageBundles objectForKey:language];
}
- (NSString *)languageForFileType:(NSString *)type
{
    return [fileTypes objectForKey:type];
}
@end
