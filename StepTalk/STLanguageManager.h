#import <Foundation/NSObject.h>

@class NSArray;
@class NSBundle;
@class NSDictionary;
@class NSMutableArray;
@class NSMutableDictionary;
@class STEngine;

@interface STLanguageManager:NSObject
{
    NSMutableArray      *languages;
    NSMutableDictionary *engineClasses;
    NSMutableDictionary *languageInfos;
    NSMutableDictionary *languageBundles;
    NSMutableDictionary *fileTypes;

}
+ (STLanguageManager *)defaultManager;
- (NSArray *)availableLanguages;
- (NSString *)defaultLanguage;
- (void)registerLanguagesFromBundle:(NSBundle *)bundle;
- (void)registerLanguage:(NSString *)language 
             engineClass:(Class)class
                    info:(NSDictionary *)info;

- (void)removeLanguage:(NSString *)language;

- (Class)engineClassForLanguage:(NSString *)language;
- (STEngine *)createEngineForLanguage:(NSString *)language;

- (NSDictionary *)infoForLanguage:(NSString *)language;
- (NSString *)languageForFileType:(NSString *)fileType;
- (NSArray *)knownFileTypes;
- (NSBundle *)bundleForLanguage:(NSString *)language;

@end
