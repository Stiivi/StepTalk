/**
    STSourceReader.m
    Source reader class.
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 
 */

#import "STSourceReader.h"
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSCharacterSet.h>

#import <StepTalk/STExterns.h>

#import "Externs.h"

static NSCharacterSet *identStartCharacterSet;
static NSCharacterSet *identCharacterSet;
static NSCharacterSet *wsCharacterSet;
static NSCharacterSet *numericCharacterSet;
static NSCharacterSet *symbolicSelectorCharacterSet;
static NSCharacterSet *validCharacterCharacterSet;

#define AT_END (srcOffset >= NSMaxRange(srcRange))
// #define AT_END ([self atEnd])

@interface NSString (LineCounting)
- (NSUInteger)lineNumberForIndex:(NSUInteger)index;
@end

@implementation NSString (LineCounting)
- (NSUInteger)lineNumberForIndex:(NSUInteger)index
{
    NSUInteger i, len;
    NSUInteger cr = 0;
    NSUInteger line = 1;
    
    len = [self length];
    index = (index < len) ? index : len;

    for(i=0;i<index;i++)
    {
        switch([self characterAtIndex:i])
        {
        case 0x000a: if(cr) 
                      { cr = 0; break; }
        case 0x000d: cr = 1;
        case 0x2028: 
        case 0x2029: cr = 0;
                     line++;
                     break;
        }
    }
    return line;
}

@end

#define PEEK_CHAR [source characterAtIndex:srcOffset]
#define GET_CHAR [source characterAtIndex:srcOffset++]

@interface NSMutableString(CharacterAppending)
- (void)appendCharacter:(unichar)character;
@end
@implementation NSMutableString(CharacterAppending)
- (void)appendCharacter:(unichar)character
{
    [self appendString:[NSString stringWithCharacters:&character 
                                               length:1]];
}
@end

static NSString *_STNormalizeStringToken(NSString *token)
{
    NSMutableString *string = [NSMutableString string];
    unsigned int     i;
    unichar          c;
    NSUInteger     len = [token length];

    for(i = 0;i < len; i++)
    {
        c = [token characterAtIndex:i];
        if(c == '\\')
        {
            i++;
            c = [token characterAtIndex:i];
            switch(c)
            {
            case 'a': [string appendCharacter:'\a']; break;
            case 'b': [string appendCharacter:'\b']; break;
            case 'e': [string appendCharacter:'\e']; break;
            case 'n': [string appendCharacter:'\n']; break;
            case 'r': [string appendCharacter:'\r']; break;
            case 't': [string appendCharacter:'\t']; break;
            case 'v': [string appendCharacter:'\v']; break;
            default:[string appendCharacter:c]; break;
            }
        }
        else
        {
            [string appendCharacter:c];
        }
    }

    return string;
}

@implementation STSourceReader
+ (void)initialize
{
    NSMutableCharacterSet *set; 

    set = [[NSCharacterSet letterCharacterSet] mutableCopy]; 
    [set addCharactersInString:@"_"]; 
    identStartCharacterSet = [set copy];

    [set formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    identCharacterSet = [set copy];

    wsCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    numericCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
    symbolicSelectorCharacterSet = 
                    [NSCharacterSet characterSetWithCharactersInString:
                                                        @"%&*+-,/<=>?@\\~"];

    set = [[NSCharacterSet controlCharacterSet] mutableCopy];
    [set formUnionWithCharacterSet:[NSCharacterSet illegalCharacterSet]];
    [set formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    validCharacterCharacterSet = [set invertedSet];
    
}

- initWithString:(NSString *)aString
{
    return [self initWithString:aString range:NSMakeRange(0,[aString length])];
}

- initWithString:(NSString *)aString range:(NSRange)range
{
    source = aString;
    srcRange = range;
    srcOffset = range.location;
    tokenRange = NSMakeRange(0,0);
    tokenType = STInvalidTokenType;
    
    return self;
}

- (STTokenType) tokenType
{
    return tokenType;
}

- (NSString *)tokenString
{

    if(tokenType == STStringTokenType)
    {
        return _STNormalizeStringToken([source substringWithRange:tokenRange]);
    }
    else
    {       
        return [source substringWithRange:tokenRange];
    }
}

- (NSRange)tokenRange;
{
    return tokenRange;
}

- (BOOL) atEnd
{
    return (srcOffset >= NSMaxRange(srcRange));
}

- (NSUInteger) currentLine
{
    return [source lineNumberForIndex:srcOffset];
}

- (BOOL) eatWhiteSpace
{
    unichar uc;
    
    for(;;)
    {
        if(AT_END)
        {
            return 0;
        }
            
        uc = PEEK_CHAR;

        /* treat comments as whitespace */
        if(uc == '"')
        {
            NSUInteger start = srcOffset;
            do
            {
                srcOffset++;
                if(AT_END)
                {
                    tokenRange = NSMakeRange(start, 1);
                
                    [NSException raise:STCompilerSyntaxException
                                format:@"Unterminated comment"];
                    return 1;
                }
            } while(PEEK_CHAR != '"');
        }
        else if([wsCharacterSet characterIsMember:uc] == NO)
        {
            return 0;
        }
        srcOffset++;
    }
    return 0;
}

- (STTokenType)readNextToken
{
    unichar c;
    NSUInteger start;
    
    if([self eatWhiteSpace])
    {
        return STErrorTokenType;
    }

    if(AT_END)
    {
        return STEndTokenType;
    }
    
    c = PEEK_CHAR;

    if([identStartCharacterSet characterIsMember:c])
    {
        BOOL isIdent = YES;
        
        start = srcOffset;
        srcOffset++;
        
        isIdent = [identCharacterSet characterIsMember:c];

        while(isIdent)
        {
            if(AT_END)
            {
                tokenRange = NSMakeRange(start,srcOffset - start);
                return STIdentifierTokenType;
            }
            
            c = GET_CHAR;
            isIdent = [identCharacterSet characterIsMember:c];
        }

        if(c == ':')
        {
            if(AT_END)
            {
                tokenRange = NSMakeRange(start,srcOffset - start);
                return STKeywordTokenType;
            }

            c = PEEK_CHAR;
            if(c == '=')
            {
                /* We have found := */
                srcOffset --;

                tokenRange = NSMakeRange(start,srcOffset - start - 1);
                return STIdentifierTokenType;
            }
            else
            {
                tokenRange = NSMakeRange(start,srcOffset - start);
                return STKeywordTokenType;
            }
        }
        else
        {
            /* Put back that character */
            srcOffset--;
    
            tokenRange = NSMakeRange(start,srcOffset - start);
            return STIdentifierTokenType;
        }
    }
    else if ( c == '-' || c == '+' || [numericCharacterSet characterIsMember:c])
    {
        BOOL maybesym = (c == '-' || c == '+');
        BOOL isReal = NO;
        BOOL isDigit = NO;
                
        start = srcOffset;
        srcOffset++;

        if(AT_END)
        {
            tokenRange = NSMakeRange(start, 1);
            if(maybesym)
            {
                return STBinarySelectorTokenType;
            }
            else
            {
                return STIntNumberTokenType;
            }
        }

        /* Take next character and see if it is binary selector */
        c = GET_CHAR;

        if(![numericCharacterSet characterIsMember:c] && maybesym)
        {
            if([symbolicSelectorCharacterSet characterIsMember:c])
            {
                /* Both characters are making one binary selector */
                tokenRange = NSMakeRange(start,2);
            }
            else
            {
                /* Other character was neither number nor binary selector
                   character, so we put it back. */
                srcOffset--;
                tokenRange = NSMakeRange(start, 1);
            }

            return STBinarySelectorTokenType;
        }

        /* c should be a digit here */
        isDigit = [numericCharacterSet characterIsMember:c];

        while( isDigit )
        {
            if(AT_END)
            {
                tokenRange = NSMakeRange(start, srcOffset-start);
                return STIntNumberTokenType;
            }
            
            c = GET_CHAR;
            isDigit = [numericCharacterSet characterIsMember:c];
        }
        

        if(c == '.')
        {
            if(AT_END)
            {
                /* we have read a dot '.' at the end of string, do not treat it
                   as decimal point. We rather put it back and treat it like
                   end of statement. */
 
                srcOffset--;
                tokenRange = NSMakeRange(start, srcOffset - start);
                  
                return STIntNumberTokenType;
            }
            
            c = PEEK_CHAR;
            isDigit = [numericCharacterSet characterIsMember:c];

            if(!isDigit)
            {
                if([wsCharacterSet characterIsMember:c])
                {
                    /* If there is whitespace or newline after a decimal point,
                       we treat it as dot '.' - end of a statement. We have 
                       to put back that dot.
                    */
                    srcOffset --;
                    tokenRange = NSMakeRange(start,srcOffset - start);
                    return STIntNumberTokenType;
                }
                else
                {
                    tokenRange = NSMakeRange(start,srcOffset - start + 1);
                    [NSException raise:STCompilerSyntaxException
                                format:@"Invalid character '%c' after decimal point",
                                c];
                }
                return STErrorTokenType;
            }
    
            while(isDigit)
            {
                if(AT_END)
                {
                    tokenRange = NSMakeRange(start, srcOffset - start);
                    return STRealNumberTokenType;
                }
                
                c = GET_CHAR;
                isDigit = [numericCharacterSet characterIsMember:c];
            }
            
            isReal = YES;
            
            /* Here we are either at the end or just scanned non-digit 
               character. */
        }

        if(c == 'e' || c == 'E')
        {
            if(AT_END)
            {
                /* We have reached end of wource without specifying exponent.
                   This is error. */
 
                tokenRange = NSMakeRange(start,srcOffset - start);
                [NSException raise:STCompilerSyntaxException
                            format:@"Unexpected end of source. "
                                   @"Exponent is missing."];
                return STErrorTokenType;
            }
    
            c = GET_CHAR;
            
            if(c == '+' || c == '-')
            {
                if(AT_END)
                {
                    /* We have reached end of wource without specifying exponent.
                       This is error. */

                    tokenRange = NSMakeRange(start,srcOffset - start);
                    [NSException raise:STCompilerSyntaxException
                                format:@"Unexpected end of source. "
                                       @"Exponent is missing after '%c'.", c];
                    return STErrorTokenType;
                }

                c = GET_CHAR;
            }
            
            isDigit = [numericCharacterSet characterIsMember:c];

            while(isDigit)
            {
                if(AT_END)
                {
                    tokenRange = NSMakeRange(start, srcOffset - start);
                    return STRealNumberTokenType;
                }

                c = GET_CHAR;
                isDigit = [numericCharacterSet characterIsMember:c];
            }
    
            if([identStartCharacterSet characterIsMember:c])
            {
                tokenRange = NSMakeRange(start,srcOffset - start);
                [NSException raise:STCompilerSyntaxException
                            format:@"Invalid character '%c' in real number.", c];
                return STErrorTokenType;
            }
            isReal = YES;
        }
        else if([identStartCharacterSet characterIsMember:c])
        {
            tokenRange = NSMakeRange(start,srcOffset - start);
            [NSException raise:STCompilerSyntaxException
                        format:@"Invalid character '%c' in integer.", c];
            return STErrorTokenType;
        }
        
        srcOffset --;
        tokenRange = NSMakeRange(start,srcOffset - start);

        if([identStartCharacterSet characterIsMember:c] && c != 'e' && c != 'E')
        {
            tokenRange = NSMakeRange(start,srcOffset - start + 1);
            [NSException raise:STCompilerSyntaxException
                        format:@"Letter '%c' in number", c];
            return STErrorTokenType;
        }
        
        if(isReal)
        {
            return STRealNumberTokenType;
        }
        else
        {
            return STIntNumberTokenType;
        }
        
    }
    else if ([symbolicSelectorCharacterSet characterIsMember:c])
    {
        start = srcOffset++;
        c = PEEK_CHAR;
        if ([symbolicSelectorCharacterSet characterIsMember:c])
        {
            srcOffset++;
            tokenRange = NSMakeRange(start,2);
        }
        else
            tokenRange = NSMakeRange(start,1);
        return STBinarySelectorTokenType;
    }
    else 
    {
        switch(c)
        {
        case '$':
                srcOffset++;
                c = GET_CHAR;
                if(AT_END)
                {
                    tokenRange = NSMakeRange(srcOffset-2, 1);
                    [NSException raise:STCompilerSyntaxException
                                format:@"Character expected"];
                    return STErrorTokenType;
                };
                
                if([validCharacterCharacterSet characterIsMember:c])
                {
                    c = PEEK_CHAR;
                    if([identCharacterSet characterIsMember:c])
                    {
                        tokenRange = NSMakeRange(srcOffset-2, 3);
                        [NSException raise:STCompilerSyntaxException
                                    format:@"Too many characters"];
                        return STErrorTokenType;
                    }
                    
                    tokenRange = NSMakeRange(srcOffset-1,1);
                    srcOffset += 1;
                    return STCharacterTokenType;
                }

                tokenRange = NSMakeRange(srcOffset-2,2);\
                [NSException raise:STCompilerSyntaxException
                            format:@"Invalid character literal"];
                return STErrorTokenType;

        case '#':
                start=srcOffset++;
                c = PEEK_CHAR;
                if(c=='(')
                {
                    srcOffset++;
                    tokenRange = NSMakeRange(start,2);
                    return STArrayOpenTokenType;
                }
                
                if([identStartCharacterSet characterIsMember:c])
                {
                    start=srcOffset++;
                    while([identCharacterSet characterIsMember:c] || c == ':')
                    {
                        c = GET_CHAR;
                        if(AT_END)
                            break;
                    }
                    srcOffset--;
                    tokenRange = NSMakeRange(start,srcOffset - start);
                    return STSymbolTokenType;
                }
                tokenRange = NSMakeRange(start,srcOffset - start);
                return STSharpTokenType;
        case ':':
                start=srcOffset++;
                c = PEEK_CHAR;
                if(c == '=')
                {
                    srcOffset++;
                    tokenRange = NSMakeRange(start,srcOffset - start);
                    return STAssignTokenType;
                }
                tokenRange = NSMakeRange(start,srcOffset - start);
                return STColonTokenType;

#define SIMPLE_TOKEN_RETURN(type) \
            tokenRange = NSMakeRange(srcOffset++,1);\
            return type
            
        case '(':SIMPLE_TOKEN_RETURN(STLParenTokenType);
        case ')':SIMPLE_TOKEN_RETURN(STRParenTokenType);
        case '|':SIMPLE_TOKEN_RETURN(STBarTokenType);
        case ';':SIMPLE_TOKEN_RETURN(STSemicolonTokenType);
        case '[':SIMPLE_TOKEN_RETURN(STBlockOpenTokenType);
        case ']':SIMPLE_TOKEN_RETURN(STBlockCloseTokenType);
        case '^':SIMPLE_TOKEN_RETURN(STReturnTokenType);
        case '!':SIMPLE_TOKEN_RETURN(STSeparatorTokenType);
        case '.':SIMPLE_TOKEN_RETURN(STDotTokenType);
        case '\'':
                start= 1 + srcOffset++;
                for(;;)
                {
     
                    if(AT_END)
                    {
                        tokenRange = NSMakeRange(start-1,1);\

                        [NSException raise:STCompilerSyntaxException
                                    format:@"Unterminated string"];
                        return STErrorTokenType;
                    };
                    
                    c = GET_CHAR;
                    if( c=='\\')
                    {
                        if(AT_END)
                        {
                            [NSException raise:STCompilerSyntaxException
                                        format:@"\\ at end"];
                            return STErrorTokenType;
                        }
                        
                        GET_CHAR;
                    }
                    else if( c=='\'' )
                    {
                        if(AT_END)
                        {
                            return STStringTokenType;
                        }

                        c = GET_CHAR;
                        if(c != '\'')
                        {
                            srcOffset--;
                            tokenRange = NSMakeRange(start,
                                                     srcOffset - start - 1);
                            return STStringTokenType;
                        }
                        
                    }
                }
        default: return STErrorTokenType;
        }
    }
}

- (STTokenType)nextToken
{
    tokenType = [self readNextToken];
    
    return tokenType;
}

- (void)unreadLastToken
{
    srcOffset = tokenRange.location;
}
@end
