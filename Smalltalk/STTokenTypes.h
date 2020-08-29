/*
    STTokenTypes.h
    STSourceReader token types
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StpTalk project.
*/

typedef enum
{
    STInvalidTokenType,             
    STSeparatorTokenType,           //  !
    STBarTokenType,                 //  |
    STReturnTokenType,              //  ^
    STColonTokenType,               //  :
    STSemicolonTokenType,           //  ;
    STDotTokenType,                 //  .
    STLParenTokenType,              //  (
    STRParenTokenType,              //  )
    STBlockOpenTokenType,           //  [
    STBlockCloseTokenType,          //  ]
    STArrayOpenTokenType,           //  #(
    STSharpTokenType,               //  #
    STAssignTokenType,              //  :=

    STErrorTokenType,
    STIdentifierTokenType,          //  thisIsIdentifier
    STKeywordTokenType,             //  thisIsKeyword:
    
    STBinarySelectorTokenType,      //  +,-,*,/ 
    STSymbolTokenType,              //  #thisIsSymbol
    STStringTokenType,              //  'This is string'

    STCharacterTokenType,           //  $a (any single alphanum character)
    STIntNumberTokenType,           //  [+-]?[0-9]+
    STRealNumberTokenType,          //  [+-]?[0-9]+.[0-9]+[eE][+-][0-9]+
    
    STEndTokenType
    
} STTokenType;
