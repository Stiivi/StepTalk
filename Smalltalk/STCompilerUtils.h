/**
    STCompilerUtils.h
    Various compiler utilities.
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of StepTalk.
  */

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSString.h>

@class STCMessage;
@class STCStatements;
@class STCExpression;

enum{
    STCVariablePrimaryType,
    STCLiteralPrimaryType,
    STCBlockPrimaryType,
    STCExpressionPrimaryType
};

@interface STCompiler(Utils_private)
- (STCompiledMethod *)compileMethod:(STCMethod *)method;
- (id)createIntNumberLiteralFrom:(NSString *)aString;
- (id)createRealNumberLiteralFrom:(NSString *)aString;
- (id)createSymbolLiteralFrom:(NSString *)aString;
- (id)createStringLiteralFrom:(NSString *)aString;
- (id)createCharacterLiteralFrom:(NSString *)aString;
- (id)createArrayLiteralFrom:(NSArray *)anArray;
@end

/*
 * STCMethod
 * ---------------------------------------------------------------------------
 */

@interface STCMethod:NSObject
{
    STCMessage *messagePattern;
    STCStatements *statements;
}
+ methodWithPattern:(STCMessage *)patt statements:(STCStatements *)stats;
- initWithPattern:(STCMessage *)patt statements:(STCStatements *)stats;
- (STCStatements *)statements;
- (STCMessage *)messagePattern;
@end

/*
 * STCStatements
 * ---------------------------------------------------------------------------
 */
@interface STCStatements:NSObject
{
    NSArray *variables;
    NSArray *expressions;
    STCExpression *retexpr;
}
+ statements;

- (void)setTemporaries:(NSArray *)vars;
- (NSArray *)temporaries;

- (void)setExpressions:(NSArray *)exprs;
- (NSArray *)expressions;

- (void)setReturnExpression:(STCExpression *)ret;
- (STCExpression *)returnExpression;
@end


/*
 * STCMessage
 * ---------------------------------------------------------------------------
 */

@interface STCMessage:NSObject
{
    NSMutableString  *selector;
    NSMutableArray   *args;
}
+ message;
- (void) addKeyword:(NSString *)keyword object:object;
- (NSString *)selector;
- (NSArray*)arguments;
@end


/*
 * STCExpression
 * ---------------------------------------------------------------------------
 */

@interface STCExpression:NSObject
{
    NSArray    *cascade;
    NSArray    *assignments;
}
+ (STCExpression *) primaryExpressionWithObject:(id)anObject;
+ (STCExpression *) messageExpressionWithTarget:(id)anObject
                                        message:(STCMessage *)message;
- (void)setCascade:(NSArray *)casc;
- (void)setAssignments:(NSArray *)asgs;

- (NSArray *)cascade;
- (NSArray *)assignments;
- (BOOL) isPrimary;

- (id) target;
- (STCMessage *)message;
- (id) object;
@end

@interface STCMessageExpression:STCExpression
{
    id          target;
    STCMessage *message;
}
- initWithTarget:(id)anObject message:(STCMessage *)message;
@end

@interface STCPrimaryExpression:STCExpression
{
    id          object;
}
- initWithObject:(id)anObject;
@end

/*
 * STCPrimary
 * ---------------------------------------------------------------------------
 */
@interface STCPrimary:NSObject
{
    int type;
    id  object;
}
+ primaryWithVariable:(id)anObject;
+ primaryWithLiteral:(id)anObject;
+ primaryWithBlock:(id)anObject;
+ primaryWithExpression:(id)anObject;
- initWithType:(int)newType object:(id)obj;
- (int)type;
- object;
@end


/*
 * Compiler additions for literals
 * ---------------------------------------------------------------------------
 */

@interface NSString(STCompilerAdditions)
+ (NSString *) symbolFromString:(NSString *)aString;
+ (id) characterFromString:(NSString *)aString;
@end

@interface NSMutableString(STCompilerAdditions)
+ (id) stringFromString:(NSString *)aString;
@end

@interface NSNumber(STCompilerAdditions)
+ (id) intNumberFromString:(NSString *)aString;
+ (id) realNumberFromString:(NSString *)aString;
@end

@interface NSMutableArray(STCompilerAdditions)
+ (id) arrayFromArray:(NSArray *)anArray;
@end
