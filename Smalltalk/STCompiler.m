/**
    STCompiler.m
    Bytecode compiler. Generates STExecutableCode from source code.
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
  */

#import "STCompiler.h"

#import "STMessage.h"
#import "STLiterals.h"
#import "STBytecodes.h"
#import "STCompiledScript.h"
#import "STCompiledCode.h"
#import "STCompiledMethod.h"
#import "STCompilerUtils.h"
#import "STSourceReader.h"
#import "Externs.h"

#import <StepTalk/STExterns.h>
#import <StepTalk/STScriptObject.h>
#import <StepTalk/STSelector.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSKeyValueCoding.h>

extern int STCparse(void *context);

/* FIXME: rewrite parser 

    We need three kinds of grammars:

    1. <source> = <statements> | <temp_variables> <statements>

    2. <source> = '[|' <method_list> ']'
       <method_list> = <method> | <method> '!' <method_list>
       <method> =  <statements> | <temp_variables> <statements>

    3. <source> = <method>
       <method> =  <statements> | <temp_variables> <statements>

    Parser 1. are 2. are for scripts. Parser 3. is for script object
    methods. Because majority of the grammar is reused in all three
    parsers we use only one grammar definition. There is no problem
    in haveng 1. and 2. in one file. To be able to have 3. in the same
    file we do a hack: we add a prefix '!!' for method source. Then
    we diferentiate it in grammar file by changin the rule:

        3. <source> = '!' '!' <method>

    See STGrammar.y
*/

@interface STCompiler(STCompilerPrivate)
- (void)compile;
- (void)initializeContext;
- (void)destroyCompilationContext;
- (NSUInteger)indexOfTemporaryVariable:(NSString *)varName;

- (void) initializeCompilationContext;

- (NSDictionary *)exceptionInfo;

- (NSUInteger)addSelectorLiteral:(NSString*)selector;
- (NSUInteger)addLiteral:literal;

- (void)compileMethod:(STCMethod *)method;
- (STCompiledCode *) compileStatements:(STCStatements *)statements;
- (void)compileStatements:(STCStatements *)statements blockFlag:(BOOL)blockFlag;
- (void)compilePrimary:(STCPrimary *)primary;
- (void)compileExpression:(STCExpression *)expr;

- (void)emitPushReceiverVariable:(NSUInteger)index;
- (void)emitPushSelf;
- (void)emitPopAndStoreReceiverVariable:(NSUInteger)index;
- (void)emitReturn;
- (void)emitReturnFromBlock;
- (void)emitPushTemporary:(NSUInteger)index;
- (void)emitPushLiteral:(NSUInteger)index;
- (void)emitPushVariable:(NSUInteger)index;
- (void)emitPopAndStoreTemporary:(NSUInteger)index;
- (void)emitPopAndStoreVariable:(NSUInteger)index ;
- (void)emitPopStack;
- (void)emitSendSelector:(NSUInteger)index argCount:(NSUInteger)argCount;
- (void)emitBlockCopy;
- (void)emitDuplicateStackTop;
- (void)emitJump:(NSUInteger)offset;
- (void)emitLongJump:(NSUInteger)offset;
- (void)emitPushNil;
- (void)emitPushTrue;
- (void)emitPushFalse;

- (void)fixupLongJumpAt:(NSUInteger)index with:(NSUInteger)offset;
- (NSUInteger)currentBytecode;
@end

@implementation STCompiler
- init
{
    self = [super init];
    
    arrayLiteralClass     = [NSMutableArray class];
    stringLiteralClass    = [NSMutableString class];
    /* bytesLiteralClass  = [NSMutableData class]; */
    intNumberLiteralClass  = [NSNumber class];
    realNumberLiteralClass = [NSNumber class];
    symbolLiteralClass    = [STSelector class];        
    characterLiteralClass = [NSString class];
    
    receiverVars = [[NSMutableArray alloc] init];
    namedReferences = [[NSMutableArray alloc] init];

    return self;
}

- (BOOL)beginScript
{
    if(isSingleMethod)
    {
        [NSException raise:@"STCompilerException"
                    format:@"Script source given for single method"];
        return NO;
    }
    else
    {
        return YES;
    }

}
/* ---------------------------------------------------------------------------
 * Compilation
 * ---------------------------------------------------------------------------
 */

- (STCompiledMethod *)compileMethodFromSource:(NSString *)aString
                                  forReceiver:(id)receiverObject
{
    STCompiledMethod *result;
    NSString         *hackedSource;
    NSString         *exceptionFmt = @"Syntax error at line %i near '%@', "
                                   @"reason: %@.";
    int               parsRetval = 0;


    NSLog(@"Compile method for receiver %@", [receiverObject className]);

    hackedSource = [@"!!" stringByAppendingString:aString];
    reader = [[STSourceReader alloc] initWithString:hackedSource];
    [receiverVars removeAllObjects];

    receiver = receiverObject;

    isSingleMethod = YES;   
    STParserContextInit(&context,self,reader);
    
    NS_DURING
    {
        // extern int STCdebug;
        // STCdebug = 1;
        parsRetval = STCparse(&context);
    }
    NS_HANDLER
    {
        if ([[localException name] isEqualToString: STCompilerSyntaxException])
        {
            NSString *tokenString;
            NSUInteger       line;
            
            tokenString = [reader tokenString];
            line = [reader currentLine];

            reader = nil;
            
            [NSException  raise:STCompilerSyntaxException
                         format:exceptionFmt,
                                line,
                                tokenString,
                                [localException reason]];
                         
        }
        [localException raise];
    }
    NS_ENDHANDLER

    result = resultMethod;
    resultMethod = nil;
    receiver = nil;
    
    return result;
}

- (STCompiledScript *)compileString:(NSString *)aString
{
    STCompiledScript *result;
    NSString         *exceptionFmt = @"Syntax error at line %i near '%@', "
                                   @"reason: %@.";
    int               parsRetval = 0;


    NSLog(@"Compile string: %@", aString);

    isSingleMethod = NO;

    reader = [[STSourceReader alloc] initWithString:aString];
    [receiverVars removeAllObjects];

    STParserContextInit(&context,self,reader);
    
    NS_DURING
    {
        // extern int STCdebug;
        // STCdebug = 1;
        parsRetval = STCparse(&context);
    }
    NS_HANDLER
    {
        reader = nil;

        if ([[localException name] isEqualToString: STCompilerSyntaxException])
        {
            NSString *tokenString;
            NSUInteger       line;
            
            tokenString = [reader tokenString];
            line = [reader currentLine];
            
            [NSException  raise:STCompilerSyntaxException
                         format:exceptionFmt,
                                line,
                                tokenString,
                                [localException reason]];
                         
        }
        [localException raise];
    }
    NS_ENDHANDLER

    result = resultScript;
    resultScript = nil;
    
    return result;
}

- (void)compileMethod:(STCMethod *)method
{
    STCompiledMethod *compiledMethod;
    STCompiledCode   *code;
    STMessage        *messagePattern;
    
    /* FIXME: unite STCMessage and STMessage */
    messagePattern = (STMessage *)[method messagePattern];
    
    if(!messagePattern)
    {
        messagePattern = [STMessage messageWithSelector:@"_unnamed_method"
                                              arguments:nil];
    }
    
    NSLog(@"Compile method %@", [messagePattern selector]);

    tempVars = [NSMutableArray arrayWithArray:[messagePattern arguments]];

    code = [self compileStatements:[method statements]];
   
    compiledMethod = [STCompiledMethod methodWithCode:code
                                       messagePattern:messagePattern];
                                       
    if(!isSingleMethod)
    {

        if(resultMethod)
        {
            [NSException  raise:@"STCompilerException"
                         format:@"Method is present when compiling a script"];
            return;
        }
        if(!resultScript)
        {
            NSLog(@"Creating script with %lu variables",[receiverVars count]);

            resultScript = [[STCompiledScript alloc] initWithVariableNames:
                                                                receiverVars];
        }
        [resultScript addMethod:compiledMethod];
    }
    else
    {
        if(resultMethod)
        {
            [NSException  raise:@"STCompilerException"
                         format:@"More than one method compiled for single method request"];
            return;
        }
        if(resultScript)
        {
            [NSException  raise:@"STCompilerException"
                         format:@"Compiled script is present when compiling single method"];
            return;
        }
        resultMethod = compiledMethod;
    }
}

- (STCompiledCode *)compileStatements:(STCStatements *)statements
{
    STCompiledCode    *compiledCode;
#ifdef DEBUG
    NSUInteger              count;
    NSUInteger              i;
#endif
    
    /* FIXME: create another class */
    [self initializeCompilationContext];
    
    NSLog(@"compiling statements");

    tempsSize = tempsCount = [tempVars count];

    [self compileStatements:statements blockFlag:NO];

    NSLog(@"  temporaries %lu stack %lu",
          (unsigned long)tempsSize,(unsigned long)stackSize);

#ifdef DEBUG
    count = [literals count];

    NSLog(@"  literals count %lu", (unsigned long)count);

    for(i=0;i<count;i++)
    {
        NSLog(@"    %2lu %@", i, [literals objectAtIndex:i]);
    }

    count = [namedReferences count];
    NSLog(@"  named references count %lu",count);
    for(i=0;i<count;i++)
    {
        NSLog(@"    %lu %@",i,[namedReferences objectAtIndex:i]);
    }
#endif
    
    compiledCode = [[STCompiledCode alloc] initWithBytecodesData:byteCodes
                                                         literals:literals
                                                 temporariesCount:tempsSize
                                                        stackSize:stackSize
                                                 namedReferences:namedReferences];

    [self destroyCompilationContext];
    
    return compiledCode;
}

- (STSourceReader *)sourceReader
{
    return reader;
}

/* ---------------------------------------------------------------------------
 * Variables
 * ---------------------------------------------------------------------------
 */

- (NSUInteger)indexOfTemporaryVariable:(NSString *)varName
{
    return [tempVars indexOfObject:varName];
}

- (void)setReceiverVariables:(NSArray *)array
{
    receiverVars = [NSMutableArray arrayFromArray:array];
    [namedReferences addObjectsFromArray:array];
}

- (void)addTempVariable:(NSString *)varName
{
    if([tempVars containsObject:varName])
    {
        [NSException raise:STCompilerGenericException
                    format:@"Multiple definition of temporary variable %@",
                           varName];
    }
    else
    {
        [tempVars addObject:varName];
    }
}

- (NSUInteger)addSelectorLiteral:(NSString*)selector
{
    return [self addLiteral:selector];
}

- (NSUInteger)addLiteral:literal
{
    [literals addObject:literal];
    return [literals count] - 1;
}
- (BOOL)isReceiverVariable:(NSString *)varName
{
    return [receiverVars containsObject:varName];
}
- (NSUInteger)indexOfNamedReference:(NSString *)varName
{
    NSUInteger index;
    id       obj;
    
    /* is it receiver or extern variable? */
    index = [namedReferences indexOfObject:varName];
    if(index != NSNotFound)
    {
        return index;
    }
    
    /* try to find receiver variable */
    if(receiver)
    {
        NS_DURING
            /* test whether variable is an ivar s*/
            obj = [receiver valueForKey:varName];
            NSLog(@"New name: receiver variable %@", varName);
            [receiverVars addObject:varName];
        NS_HANDLER
            if([[localException name] isEqualToString:NSUndefinedKeyException])
            {
            NSLog(@"New name: extern %@", varName);
                /* receiver has no such variable */
                [externVars addObject:varName];
            }
            else
            {
                [localException raise];
            }
        NS_ENDHANDLER
    }
    else
    {
        NSLog(@"New name: extern %@ (nil receiver)", varName);
        [externVars addObject:varName];
    }
        
    [namedReferences addObject:varName];

    return [namedReferences indexOfObject:varName];
}


/* ---------------------------------------------------------------------------
 * Compiler internals (called from parser)
 * ---------------------------------------------------------------------------
 */

- (void) initializeCompilationContext
{
    byteCodes  = [[NSMutableData  alloc] init];
    literals   = [[NSMutableArray alloc] init];
    [externVars removeAllObjects];
    [namedReferences removeAllObjects];
    
    stackSize = stackPos = 0;
    tempsSize = tempsCount = 0;
    bcpos = 0;
}

- (void) destroyCompilationContext
{
    byteCodes  = nil;
    literals   = nil;
    
    stackSize = stackPos = 0;
    tempsSize = tempsCount = 0;
    bcpos = 0;
}

- (void)compileStatements:(STCStatements *)statements blockFlag:(BOOL)blockFlag
{
    NSEnumerator   *enumerator;
    STBlockLiteral *blockInfo = nil;
    STCExpression  *expr;
    NSArray        *array;
    NSUInteger        tempsSave;           /* stored count of temporaries */
    NSUInteger        stackPosSave  = 0;   /* stored previous stack value */
    NSUInteger        stackSizeSave = 0;
    NSUInteger        jumpIP = 0; /* location of jump bytecode for later fixup */
    NSUInteger        index;
    NSUInteger        argCount=0;  /* argument count for block context */
        
    NSLog(@"  compile statements; blockFlag=%i; tempCount=%lu",
                 blockFlag,tempsCount);

    tempsSave = tempsCount; /* store value, so we can cleanup array later */
    
    array = [statements temporaries];

    NSLog(@"  temporaries %@", array);

    if(array)
    {
        argCount = [array count];
        for(index=0;index<argCount;index++)
        {
            [self addTempVariable:[array objectAtIndex:index]];
        }

        tempsCount += argCount;
        tempsSize = MAX(tempsSize,tempsCount);
    }

    if(blockFlag)
    {
        
        blockInfo = [[STBlockLiteral alloc]
                     initWithArgumentCount:argCount];

        index = [self addLiteral:blockInfo];
        [self emitPushLiteral:index];
        [self emitBlockCopy];

        jumpIP = [self currentBytecode];

        /* block has its own stack */
        stackPosSave = stackPos;
        stackSizeSave = stackSize;
        stackSize = argCount;
        stackPos = argCount;

        [self emitLongJump:0];
        
        for(index = argCount; index > 0; index--)
        {
            [self emitPopAndStoreTemporary:tempsSave + index - 1];
        }
    }
    
    array = [statements expressions];
    
    if(array)
    {
        BOOL first = YES;

        enumerator = [array objectEnumerator];
        while((expr = [enumerator nextObject]))
        {
            [self compileExpression:expr];

            /* Mateu Batle: ignore returned value on the stack ? */
            /* FIXME: please check this !!! */

            if (!first)
            {
                [self emitPopStack];
            }
            else 
            {
                first = NO;
            }
        }
    }

    expr = [statements returnExpression];
    if(expr)
    {
        [self compileExpression:expr];
    }

    if(blockFlag)
    {
        [blockInfo setStackSize:stackSize];

        stackSize = stackSizeSave;
        stackPos = stackPosSave;

        [self emitReturnFromBlock];
    }
    else
    {
        [self emitReturn];
    }

    /* fixup jump (if block) */
    if(blockFlag)
    {
        [self fixupLongJumpAt:jumpIP with:[self currentBytecode] - jumpIP];
    }

    /* cleanup unneeded temp variables */
//
//    [tempVars removeObjectsInRange:NSMakeRange(tempsSave,
//                                               [tempVars count]-tempsSave)];
//    tempsCount = tempsSave;
    tempsCount = [tempVars count];

    if(blockFlag)
    {
      NSUInteger i;
      /* Need to keep the block parameters allocated until we exit
         the method context, but we also need to harvest the names*/
      for (i = tempsSave; i < tempsCount; ++i)
        [tempVars  replaceObjectAtIndex: i withObject:@""];
     
    }
    else
    {
      /* cleanup unneeded temp variables */
      [tempVars removeObjectsInRange:NSMakeRange(tempsSave,
                                                 tempsCount-tempsSave)];
      tempsCount = tempsSave;  
    }
}

- (void)compilePrimary:(STCPrimary *)primary
{
    id object = [primary object];
    NSUInteger index;

    NSLog(@"  compile primary");

    switch([primary type])
    {
    case STCVariablePrimaryType:
            if([object isEqualToString:@"YES"]
                || [object isEqualToString:@"true"])
            {
                [self emitPushTrue];
            }
            else if([object isEqualToString:@"NO"]
                || [object isEqualToString:@"false"])
            {
                [self emitPushFalse];
            }
            else if([object isEqualToString:@"nil"])
            {
                [self emitPushNil];
            }
            else
            {
                index = [self indexOfTemporaryVariable:object];
                if(index != NSNotFound)
                {
                    [self emitPushTemporary:index];
                    break;
                }
                else if( [object isEqual:@"self"] )
                {
                    [self emitPushSelf];
                    break;
                }
                else
                {
                    index = [self indexOfNamedReference:object];

                    if([self isReceiverVariable:object])
                    {
                        [self emitPushReceiverVariable:index];
                    }
                    else
                    {
                        [self emitPushVariable:index];
                    }
                }
            }
            break;

    case STCLiteralPrimaryType:

            index = [self addLiteral:object];
            [self emitPushLiteral:index];
            break;

    case STCBlockPrimaryType:

            [self compileStatements:object blockFlag:YES];
            break;

    case STCExpressionPrimaryType:

            [self compileExpression:object];
            break;

    default:

            [NSException raise:STCompilerInconsistencyException
                        format:@"Unknown primary type %i", 
                               [primary type]];
            break;
    }
}

- (void)compileMessage:(STCMessage *)message
{
    NSEnumerator *enumerator;
    NSArray      *args;
    id            obj;
    NSUInteger           index;
    
    args = [message arguments];
    if(args && ([args count]>0))
    {
        enumerator = [args objectEnumerator];
        while((obj = [enumerator nextObject]))
        {
            if([obj isKindOfClass:[STCPrimary class]])
                [self compilePrimary:obj];
            else
                [self compileExpression:obj];
        }
    }

    index = [self addSelectorLiteral:[message selector]];
    [self emitSendSelector:index argCount:[args count]];
}

- (void)compileExpression:(STCExpression *)expr
{
    NSEnumerator  *enumerator;
    NSArray       *cascade;
    NSString      *varName;
    NSArray       *array;
    unsigned       count;
    unsigned       index,i;
    id             obj;
    
    NSLog(@"  compile expression");
    
    if([expr isPrimary])
    {
        [self compilePrimary:[expr object]];
    }
    else /* message expression */
    {
        obj = [expr target];

        /* target */
        if([obj isKindOfClass:[STCPrimary class]])
            [self compilePrimary:obj];
        else
            [self compileExpression:obj];
        
        cascade = [expr cascade];
        if(cascade)
        {
            count = [cascade count];
            for(i=0;i<count;i++)
                [self emitDuplicateStackTop];
        }
        
        [self compileMessage:[expr message]];

        /* cascade expression */
        if(cascade)
        {
            enumerator = [cascade objectEnumerator];
            while( (obj = [enumerator nextObject]) )
            {
                /* ignore previous return value */
                [self emitPopStack];
                [self compileMessage:obj];
            }
        }        
    }

    array = [expr assignments];
    count = [array count];
    if(array && count>0)
    {
        for(i = 0; i<count; i++)
        {
            [self emitDuplicateStackTop];
        }
        
        for(i = 0; i<count; i++)
        {
            varName = [array objectAtIndex:i];

            index = [self indexOfTemporaryVariable:varName];
            if(index != NSNotFound)
            {
                [self emitPopAndStoreTemporary:index];
                continue;
            }
            if( [varName isEqual:@"self"] )
            {
                NSLog(@"Warning: trying to store to self (ignoring)");
                [self emitPopStack];
                continue;
            }
            else
            {
                index = [self indexOfNamedReference:varName];
                if([self isReceiverVariable:varName])
                {
                    [self emitPopAndStoreReceiverVariable:index];
                }
                else
                {
                    [self emitPopAndStoreVariable:index];
                }
            }
        }
    }
}


/* ---------------------------------------------------------------------------
 * Literal classes
 * ---------------------------------------------------------------------------
 */

- (Class)stringLiteralClass
{
    return stringLiteralClass;
}
- (Class)arrayLiteralClass
{
    return arrayLiteralClass;
}
- (Class)intNumberLiteralClass
{
    return intNumberLiteralClass;
}
- (Class)realNumberLiteralClass
{
    return realNumberLiteralClass;
}
- (Class)symbolLiteralClass
{
    return symbolLiteralClass;
}
- (Class)characterLiteralClass
{
    return characterLiteralClass;
}
- (void)setStringLiteralClass:(Class)aClass
{
    stringLiteralClass = aClass;
}
- (void)setArrayLiteralClass:(Class)aClass
{
    arrayLiteralClass = aClass;
}
- (void)setIntNumberLiteralClass:(Class)aClass
{
    intNumberLiteralClass = aClass;
}
- (void)setRealNumberLiteralClass:(Class)aClass
{
    realNumberLiteralClass = aClass;
}
- (void)setSymbolLiteralClass:(Class)aClass
{
    symbolLiteralClass = aClass;
}
- (void)setCharacterLiteralClass:(Class)aClass
{
    characterLiteralClass = aClass;
}

- (id)createIntNumberLiteralFrom:(NSString *)aString
{
    return [intNumberLiteralClass intNumberFromString:aString];
}
- (id)createRealNumberLiteralFrom:(NSString *)aString
{
    return [realNumberLiteralClass realNumberFromString:aString];
}
- (id)createSymbolLiteralFrom:(NSString *)aString
{
    return [symbolLiteralClass symbolFromString:aString];
}
- (id)createStringLiteralFrom:(NSString *)aString
{
    return [stringLiteralClass stringFromString:aString];
}
- (id)createCharacterLiteralFrom:(NSString *)aString
{
    return [characterLiteralClass characterFromString:aString];
}
- (id)createArrayLiteralFrom:(NSArray *)anArray
{
   return [arrayLiteralClass arrayFromArray:anArray];
}

- (NSDictionary *)exceptionInfo
{
    NSDictionary *dict;
    
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithUnsignedInteger:[reader currentLine]], 
                                @"LineNumber", 
                            [reader tokenString], 
                                @"Token",      
                            [NSValue valueWithRange:[reader tokenRange]],
                                @"TokenRange",
                            nil,nil];
    return nil;
}
/* ---------------------------------------------------------------------------
 * Emit bytecodes
 * ---------------------------------------------------------------------------
 */
#define STDebugEmit(bc) \
                NSLog(@"#%04lu %@", \
                            (bc).pointer, \
                            STDissasembleBytecode(bc))

#define STDebugEmitWith(bc,object) \
                NSLog(@"#%04lu %@ (%@)", \
                            (bc).pointer, \
                            STDissasembleBytecode(bc), \
                            (object))

#define EMIT_SINGLE(bytecode) \
            do { \
                char bc = bytecode; \
                [byteCodes appendBytes:&bc length:1];\
                bcpos++;\
            } while(0)

#define EMIT_DOUBLE(bc1,bc2) \
            do { \
                unsigned char bc[3] = {bc1,0,0}; \
		bc[1] = (unsigned char)((((unsigned short)bc2)>>8)&0xff);\
		bc[2] = (unsigned char)(bc2&0xff); \
                [byteCodes appendBytes:bc length:3];\
                bcpos+=3;\
            } while(0)
#define EMIT_TRIPPLE(bc1,bc2,bc3) \
            do { \
                unsigned char bc[5] = {bc1,0,0,0,0}; \
		bc[1] = (unsigned char)((((unsigned short)bc2)>>8)&0xff);\
		bc[2] = (unsigned char)(bc2&0xff); \
		bc[3] = (unsigned char)((((unsigned short)bc3)>>8)&0xff);\
		bc[4] = (unsigned char)(bc3&0xff); \
                [byteCodes appendBytes:bc length:5];\
                bcpos+=5;\
            } while(0)

#define STACK_PUSH \
            do {\
                stackPos++; \
                stackSize = MAX(stackPos,stackSize);\
            } while(0)
#define STACK_PUSH_COUNT(count) \
            do {\
                stackPos+=count; \
                stackSize = MAX(stackPos,stackSize);\
            } while(0)

#define STACK_POP \
            stackPos--;

#define STACK_POP_COUNT(count) \
            stackPos-=count;
            
- (void)emitPushSelf
{
    NSLog(@"#%04lu push self", bcpos);
                
    EMIT_SINGLE(STPushReceiverBytecode);
    STACK_PUSH;
}
- (void)emitPushNil
{
    NSLog(@"#%04lu push nil", bcpos);
                
    EMIT_SINGLE(STPushNilBytecode);
    STACK_PUSH;
}
- (void)emitPushTrue
{
    NSLog(@"#%04lu push true", bcpos);
                
    EMIT_SINGLE(STPushTrueBytecode);
    STACK_PUSH;
}
- (void)emitPushFalse
{
    NSLog(@"#%04lu push false", bcpos);
                
    EMIT_SINGLE(STPushFalseBytecode);
    STACK_PUSH;
}
- (void)emitPushReceiverVariable:(unsigned)index
{
                
    NSLog(@"#%04lu push receiver variable %i (%@)",
                bcpos,index,[namedReferences objectAtIndex:index]);

    EMIT_DOUBLE(STPushRecVarBytecode,index);
    STACK_PUSH;
}

- (void)emitPushTemporary:(unsigned)index
{
    NSLog(@"#%04lu push temporary %i (%@)",
                bcpos,index,[tempVars objectAtIndex:index]);
                
    EMIT_DOUBLE(STPushTemporaryBytecode,index);
    STACK_PUSH;
    
}

- (void)emitPushLiteral:(unsigned)index
{
    NSLog(@"#%04lu push literal %i (%@)",
                bcpos,index,[literals objectAtIndex:index]);
                
    EMIT_DOUBLE(STPushLiteralBytecode,index);
    STACK_PUSH;
    stackSize++;
}
- (void)emitPushVariable:(unsigned)index
{
    NSLog(@"#%04lu push external variable %i (%@)",
                bcpos,index,[namedReferences objectAtIndex:index]);
                
    EMIT_DOUBLE(STPushExternBytecode,index);
    STACK_PUSH;
}
- (void)emitPopAndStoreTemporary:(unsigned)index
{
    NSLog(@"#%04lu pop and store temp %i (%@)",
                bcpos,index,[tempVars objectAtIndex:index]);
                
    EMIT_DOUBLE(STPopAndStoreTempBytecode,index);
    STACK_POP;
}
- (void)emitPopAndStoreVariable:(unsigned)index
{
    NSLog(@"#%04lu pop and store ext variable %i (%@)",
                bcpos,index,[namedReferences objectAtIndex:index]);
                
    EMIT_DOUBLE(STPopAndStoreExternBytecode,index);
    STACK_POP;
}
- (void)emitPopAndStoreReceiverVariable:(unsigned)index
{
    NSLog(@"#%04lu pop and store rec variable %i (%@)",
                bcpos,index,[namedReferences objectAtIndex:index]);
                
    EMIT_DOUBLE(STPopAndStoreRecVarBytecode,index);
    STACK_POP;
}

- (void)emitSendSelector:(unsigned)index argCount:(unsigned)argCount
{
    NSLog(@"#%04lu send selector %i (%@) with %i args",
                bcpos,index,[literals objectAtIndex:index],argCount);
            
    EMIT_TRIPPLE(STSendSelectorBytecode,index,argCount);
    STACK_PUSH_COUNT(argCount);
    STACK_POP_COUNT(argCount);
}
- (void)emitDuplicateStackTop
{
    NSLog(@"#%04lu dup",bcpos);
                
    EMIT_SINGLE(STDupBytecode);
    STACK_PUSH;
}
- (void)emitPopStack
{
    NSLog(@"#%04lu pop stack",bcpos);
                
    EMIT_SINGLE(STPopStackBytecode);
    STACK_POP;
}
- (void)emitReturn
{
    NSLog(@"#%04lu return",bcpos);
                
    EMIT_SINGLE(STReturnBytecode);
}
- (void)emitReturnFromBlock
{
    NSLog(@"#%04lu return from block",bcpos);
                
    EMIT_SINGLE(STReturnBlockBytecode);
}
- (void)emitBlockCopy
{
    NSLog(@"#%04lu create block",bcpos);
                
    EMIT_SINGLE(STBlockCopyBytecode);
}
- (void)emitLongJump:(short)offset
{
    NSLog(@"#%04lu long jump %i (0x%04lu)",bcpos,offset,bcpos+offset);
                
/*
    EMIT_TRIPPLE(STLongJumpBytecode,STLongJumpFirstByte(offset),
                                    STLongJumpSecondByte(offset));
*/
    EMIT_DOUBLE(STLongJumpBytecode, offset);
}
- (void)fixupLongJumpAt:(unsigned)index with:(short)offset
{
    //unsigned char bytes[4] = {0,STLongJumpFirstByte(offset),0,STLongJumpSecondByte(offset)};
    unsigned char bytes[2] = { (offset >> 8) & 0xff, offset & 0xff };

    NSLog(@"# fixup long jump at 0x%04lu to 0x%04lu",index, index + offset);

    [byteCodes replaceBytesInRange:NSMakeRange(index+1,2) withBytes:bytes];
}
- (unsigned)currentBytecode
{
    return [byteCodes length];
}

@end
