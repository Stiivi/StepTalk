/**
    STExterns.m
    Misc. variables
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.
 */
#import <Foundation/NSString.h>

NSString *STGenericException = @"STGenericException";
NSString *STInvalidArgumentException = @"STInvalidArgumentException";
NSString *STInternalInconsistencyException = @"STInternalInconsistencyException";
NSString *STRangeException = @"STRangeException";
NSString *STScriptingException = @"STScriptingException";

NSString *STCompilerSyntaxException = @"STCompilerSyntaxException";
NSString *STCompilerGenericException = @"STCompilerGenericException";
NSString *STCompilerInconsistencyException = @"STCompilerInconsistencyException";

NSString *STInterpreterGenericException = @"STInterpreterGenericException";
NSString *STInvalidBytecodeException = @"STInterpreterInvalidBytecodeException";
NSString *STInterpreterInconsistencyException = @"STInterpreterInconsistencyException";


NSString *STLibraryDirectory = @"StepTalk";
NSString *STScriptsDirectory = @"Scripts";

NSString *STModulesDirectory = @"Modules";
NSString *STModuleExtension  = @"bundle";

NSString *STScriptingEnvironmentsDirectory = @"Environments";
NSString *STScriptingEnvironmentExtension  = @"stenv";

NSString *STLanguageBundlesDirectory = @"Languages";
NSString *STLanguageBundleExtension = @"stlanguage";

NSString *STLanguagesConfigFile = @"Languages.plist";
