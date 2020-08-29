/**
    STCompilerUtils.m
    Various compiler utilities.
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of StepTalk.
 
 */

#import "STCompiler.h"

#import "STCompilerUtils.h"
#import "STSourceReader.h"

#import <StepTalk/StepTalk.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

/* 
 * Compiler utilities
 * --------------------------------------------------------------------------
 */

/*
 * STCMethod
 * ---------------------------------------------------------------------------
 */



@implementation STCMethod
+ methodWithPattern:(STCMessage *)patt statements:(STCStatements *)stats
{
    STCMethod *method;
    method = [[STCMethod alloc] initWithPattern:patt statements:stats];
    return method;
}
- initWithPattern:(STCMessage *)patt statements:(STCStatements *)stats
{
    self = [super init];
    messagePattern = patt;
    statements = stats;
    return self;
}

- (STCStatements *)statements
{
    return statements;
}

- (STCMessage *)messagePattern
{
    return messagePattern;
}
@end

/*
 * STCStatements
 * ---------------------------------------------------------------------------
 */
@implementation STCStatements
+ statements
{
    STCStatements *statements = [[STCStatements alloc] init];
    return statements;
}
- (void)setTemporaries:(NSArray *)vars
{
    variables = vars;
}
- (void)setExpressions:(NSArray *)exprs
{
    expressions = exprs;
}
- (void)setReturnExpression:(STCExpression *)ret
{
    retexpr = ret;
}

- (NSArray *)temporaries
{
    return variables;
}
- (NSArray *)expressions
{
    return expressions;
}
- (STCExpression *)returnExpression
{
    return retexpr;
}
@end

/*
 * STCMessage
 * ---------------------------------------------------------------------------
 */

@implementation STCMessage
+ message
{
    STCMessage *message = [[STCMessage alloc] init];
    return message;
}
- init
{
    self = [super init];
    
    selector = [[NSMutableString alloc] init];
    args = [[NSMutableArray alloc] init];

    return self;
}

-(void) addKeyword:(NSString *)keyword object:object
{
    [selector appendString:keyword];
    if(object!=nil)
        [args addObject:object];
}
- (NSString *)selector
{
    return selector;
}
- (NSArray *)arguments
{
    return args;
}
@end

/*
 * STCExpression
 * ---------------------------------------------------------------------------
 */
@implementation STCExpression:NSObject
+ (STCExpression *) primaryExpressionWithObject:(id)anObject
{
    STCPrimaryExpression *expr;
    expr = [[STCPrimaryExpression alloc] initWithObject:anObject];
    return expr;
}

+ (STCExpression *) messageExpressionWithTarget:(id)anObject
                                        message:(STCMessage *)message
{
    STCMessageExpression *expr;
    expr = [[STCMessageExpression alloc] initWithTarget:anObject
                                                message:message];
    return expr;
}


- (void)setCascade:(NSArray *)casc
{
    cascade = casc;
}
- (void)setAssignments:(NSArray *)asgs
{
    assignments = asgs;
}
- (NSArray *)cascade
{
    return cascade;
}
- (NSArray *)assignments
{
    return assignments;
}
- (BOOL)isPrimary
{
    [self subclassResponsibility:_cmd];
    return NO;
}
- (id) target
{
    [self subclassResponsibility:_cmd];
    return nil;
}
- (STCMessage *)message
{
    [self subclassResponsibility:_cmd];
    return nil;
}
- (id) object
{
    [self subclassResponsibility:_cmd];
    return nil;
}

@end

@implementation STCMessageExpression:STCExpression
- initWithTarget:(id)anObject message:(STCMessage *)aMessage;
{
    self = [super init];
    
    target = anObject;
    message = aMessage;
    
    return self;
}

- (id) target
{
    return target;
}
- (STCMessage *)message
{
    return message;
}
- (BOOL)isPrimary
{
    return NO;
}
@end

@implementation STCPrimaryExpression:STCExpression
- initWithObject:(id)anObject
{
    self = [super init];
    object = anObject;
    return self;
}

- (id) object
{
    return object;
}
- (BOOL)isPrimary
{
    return YES;
}
@end

/*
 * STCPrimary
 * ---------------------------------------------------------------------------
 */
@implementation STCPrimary
+ primaryWithVariable:(id) anObject
{
    STCPrimary *primary;
    primary = [[STCPrimary alloc] initWithType:STCVariablePrimaryType object:anObject];
    return primary;
}
+ primaryWithLiteral:(id) anObject
{
    STCPrimary *primary;
    primary = [[STCPrimary alloc] initWithType:STCLiteralPrimaryType object:anObject];
    return primary;
}
+ primaryWithBlock:(id) anObject
{
    STCPrimary *primary;
    primary = [[STCPrimary alloc] initWithType:STCBlockPrimaryType object:anObject];
    return primary;
}
+ primaryWithExpression:(id) anObject
{
    STCPrimary *primary;
    primary = [[STCPrimary alloc] initWithType:STCExpressionPrimaryType object:anObject];
    return primary;
}
- initWithType:(int)newType object:obj
{
    type = newType;
    object = obj;
    return [super init];
}

- (int)type
{
    return type;
}
- object
{
    return object;
}
@end


/*
 * Compiler additions for literals
 * ---------------------------------------------------------------------------
 */

@implementation NSString(STCompilerAdditions)
+ (NSString *) symbolFromString:(NSString *)aString
{
    return [self stringWithString:aString];
}
+ (id) characterFromString:(NSString *)aString
{
    return [self stringWithString:aString];
}
@end

@implementation NSMutableString(STCompilerAdditions)
+ (id) stringFromString:(NSString *)aString
{
    return [self stringWithString:aString];
}
@end

@implementation NSNumber(STCompilerAdditions)
+ (id) intNumberFromString:(NSString *)aString
{
    return [self numberWithInt:[aString intValue]];
}
+ (id) realNumberFromString:(NSString *)aString
{
    return [self numberWithDouble:[aString doubleValue]];
}
@end

@implementation NSMutableArray(STCompilerAdditions)
+ (id) arrayFromArray:(NSArray *)anArray
{
    return [self arrayWithArray:anArray];
}
@end
