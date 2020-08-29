/**
    STCompiler.h
    Bytecode compiler. Generates STExecutableCode from source code.
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
 
    This file is part of the StepTalk project.
 
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSRange.h>

@class STCompiledScript;
@class STCompiledCode;
@class STCompiledMethod;
@class STSourceReader;

@class STCExpression;
@class STCMethod;
@class STCPrimary;
@class STCStatements;

@class STCompiler;

@class NSMutableData;
@class NSMutableArray;
@protocol STScriptObject;
/*" Parser context information "*/
typedef struct _STParserContext
{
    STCompiler     *compiler;
    STSourceReader *reader;
} STParserContext;


/*" Get compiler from parser context "*/
#define STParserContextGetCompiler(context)\
            (((STParserContext *)context)->compiler)
/*" Get source reader from parser context "*/
#define STParserContextGetReader(context)\
            (((STParserContext *)context)->reader)

/*" Initialize parser context "*/
#define STParserContextInit(context,aCompiler,aReader) \
           do { \
                ((STParserContext *)context)->compiler = aCompiler; \
                ((STParserContext *)context)->reader = aReader; \
           } while(0) 

@interface STCompiler:NSObject
{
    STSourceReader   *reader;
    STParserContext   context;

    STCompiledScript *resultScript;
    STCompiledMethod *resultMethod;
    
    NSMutableData    *byteCodes;
    NSMutableArray   *tempVars;
    NSMutableArray   *externVars;
    NSMutableArray   *receiverVars;
    NSMutableArray   *namedReferences;
    NSMutableArray   *literals;
    
    id                receiver;

    BOOL              isSingleMethod;
    
    NSUInteger        stackSize;    /* Required stack size */
    NSUInteger        stackPos;     /* Current stack pointer */
    NSUInteger        tempsSize;    /* Required temp space */
    NSUInteger        tempsCount;   /* Actual temp space */
    NSUInteger        bcpos;        /* Bytecode position */

    Class           stringLiteralClass; /* default: NSMutableString */
    Class           arrayLiteralClass;  /* default: NSMutableArray */
    Class           characterLiteralClass;  /* default: NSString */
    Class           intNumberLiteralClass; /* default: NSNumber */
    Class           realNumberLiteralClass; /* default: NSNumber */
    Class           symbolLiteralClass; /* default: NSString */
}
- (STSourceReader *)sourceReader;

/*" Compilation "*/

- (STCompiledScript *)compileString:(NSString *)aString;
- (STCompiledMethod *)compileMethodFromSource:(NSString *)aString
                                  forReceiver:(id <STScriptObject>)receiver;

/*
- (NSMutableArray *)compileString:(NSString *)string;
- (NSMutableArray *)compileString:(NSString *)string range:(NSRange) range;
*/


/*" Literals "*/
- (Class)intNumberLiteralClass;
- (Class)realNumberLiteralClass;
- (Class)stringLiteralClass;
- (Class)arrayLiteralClass;
- (Class)symbolLiteralClass;
- (void)setStringLiteralClass:(Class)aClass;
- (void)setArrayLiteralClass:(Class)aClass;
- (void)setSymbolLiteralClass:(Class)aClass;
- (void)setIntNumberLiteralClass:(Class)aClass;
- (void)setRealNumberLiteralClass:(Class)aClass;

- (void)setReceiverVariables:(NSArray *)vars;

- (void)addTempVariable:(NSString *)varName;
- (BOOL)beginScript;
@end
