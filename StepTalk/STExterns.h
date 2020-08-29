/**
    STExterns.h
    Misc. variables
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 
 */

@class NSString;
@class STUndefinedObject;

extern STUndefinedObject *STNil;

/* exceptions */

extern NSString *STGenericException;               /* can be ignored */
extern NSString *STInvalidArgumentException;
extern NSString *STInternalInconsistencyException; /* not recoverable */
extern NSString *STScriptingException;

extern NSString *STLibraryDirectory;

extern NSString *STScriptExtension;
extern NSString *STScriptsDirectory;

extern NSString *STScriptingEnvironmentsDirectory;
extern NSString *STScriptingEnvironmentExtension;

extern NSString *STModulesDirectory;
extern NSString *STModuleExtension;

extern NSString *STLanguageBundlesDirectory;
extern NSString *STLanguageBundleExtension;

extern NSString *STLanguagesConfigFile;

/* malloc zone */
extern NSZone   *STMallocZone;

