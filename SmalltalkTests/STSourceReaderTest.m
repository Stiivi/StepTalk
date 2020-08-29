//
//  STSourceReaderTest.m
//  SmalltalkTests
//
//  Created by Stefan Urbanek on 2020/8/30.
//  Copyright © 2020 Stefan Urbanek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Smalltalk/STSourceReader.h>

@interface STSourceReaderTest : XCTestCase

@end

@implementation STSourceReaderTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEmpty {
    STSourceReader *reader;
    
    reader = [[STSourceReader alloc] initWithString: @""];
    XCTAssertEqual([reader tokenType], STInvalidTokenType);
    XCTAssertEqual([reader nextToken], STEndTokenType);
    XCTAssertEqual([reader nextToken], STEndTokenType);
    XCTAssertEqual([reader tokenType], STEndTokenType);
}

- (void)testTokens {
    STSourceReader *reader;
    
    reader = [[STSourceReader alloc] initWithString:
              @"! | ^ : ; . ( ) [ ] #( # :="];
    XCTAssertEqual([reader nextToken],STSeparatorTokenType);
    XCTAssertEqual([reader nextToken],STBarTokenType);
    XCTAssertEqual([reader nextToken],STReturnTokenType);
    XCTAssertEqual([reader nextToken],STColonTokenType);
    XCTAssertEqual([reader nextToken],STSemicolonTokenType);
    XCTAssertEqual([reader nextToken],STDotTokenType);
    XCTAssertEqual([reader nextToken],STLParenTokenType);
    XCTAssertEqual([reader nextToken],STRParenTokenType);
    XCTAssertEqual([reader nextToken],STBlockOpenTokenType);
    XCTAssertEqual([reader nextToken],STBlockCloseTokenType);
    XCTAssertEqual([reader nextToken],STArrayOpenTokenType);
    XCTAssertEqual([reader nextToken],STSharpTokenType);
    XCTAssertEqual([reader nextToken],STAssignTokenType);
    XCTAssertEqual([reader nextToken],STEndTokenType);
}
- (void)testIdentifier {
    STSourceReader *reader;
    reader = [[STSourceReader alloc] initWithString:
              @"thing thing1 _thing thing_1"];
    XCTAssertEqual([reader nextToken],STIdentifierTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing"]);
    XCTAssertEqual([reader nextToken],STIdentifierTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing1"]);
    XCTAssertEqual([reader nextToken],STIdentifierTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"_thing"]);
    XCTAssertEqual([reader nextToken],STIdentifierTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing_1"]);
    XCTAssertEqual([reader nextToken],STEndTokenType);
}
- (void)testKeyword {
    STSourceReader *reader;
    reader = [[STSourceReader alloc] initWithString:
              @"thing: thing1: _thing: thing_1:"];
    XCTAssertEqual([reader nextToken],STKeywordTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing:"]);
    XCTAssertEqual([reader nextToken],STKeywordTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing1:"]);
    XCTAssertEqual([reader nextToken],STKeywordTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"_thing:"]);
    XCTAssertEqual([reader nextToken],STKeywordTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing_1:"]);
    XCTAssertEqual([reader nextToken],STEndTokenType);
}
- (void)testSymbol {
    STSourceReader *reader;
    reader = [[STSourceReader alloc] initWithString:
              @"#thing #thing1 #_thing #thing_1"];
    XCTAssertEqual([reader nextToken],STSymbolTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing"]);
    XCTAssertEqual([reader nextToken],STSymbolTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing1"]);
    XCTAssertEqual([reader nextToken],STSymbolTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"_thing"]);
    XCTAssertEqual([reader nextToken],STSymbolTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing_1"]);
    XCTAssertEqual([reader nextToken],STEndTokenType);
}
- (void)testBinarySelectors {
    STSourceReader *reader;
    
    reader = [[STSourceReader alloc] initWithString:
              @"+ - && =="];
    XCTAssertEqual([reader nextToken],STBinarySelectorTokenType);
    XCTAssertEqual([reader nextToken],STBinarySelectorTokenType);
    XCTAssertEqual([reader nextToken],STBinarySelectorTokenType);
    XCTAssertEqual([reader nextToken],STBinarySelectorTokenType);
    XCTAssertEqual([reader nextToken],STEndTokenType);
}
- (void)testString {
    STSourceReader *reader;
    reader = [[STSourceReader alloc] initWithString:
              @"'thing' 'spaced thing' '' 'quoted''string'"];
    XCTAssertEqual([reader nextToken],STStringTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"thing"]);
    XCTAssertEqual([reader nextToken],STStringTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"spaced thing"]);
    XCTAssertEqual([reader nextToken],STStringTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @""]);
    XCTAssertEqual([reader nextToken],STStringTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"quoted'thing"]);
    XCTAssertEqual([reader nextToken],STEndTokenType);
}

- (void)testCharacter {
    STSourceReader *reader;
    reader = [[STSourceReader alloc] initWithString:
              @"$1 $a $$ $ab"];
    XCTAssertEqual([reader nextToken],STCharacterTokenType);
    NSLog(@"S1: [%@]", [reader tokenString]);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"1"]);
    XCTAssertEqual([reader nextToken],STCharacterTokenType);
    NSLog(@"S1: [%@]", [reader tokenString]);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"a"]);
    XCTAssertEqual([reader nextToken],STCharacterTokenType);
    NSLog(@"S1: [%@]", [reader tokenString]);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"$"]);
    XCTAssertEqual([reader nextToken],STCharacterTokenType);
    NSLog(@"S1: [%@]", [reader tokenString]);
    XCTAssertEqual([reader nextToken],STErrorTokenType);
    XCTAssertEqual([reader nextToken],STEndTokenType);
}
- (void)testInteger {
    STSourceReader *reader;
    reader = [[STSourceReader alloc] initWithString:
              @"1 11 01 1234 123a"];
    XCTAssertEqual([reader nextToken],STIntNumberTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"1"]);
    XCTAssertEqual([reader nextToken],STIntNumberTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"11"]);
    XCTAssertEqual([reader nextToken],STIntNumberTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"01"]);
    XCTAssertEqual([reader nextToken],STIntNumberTokenType);
    XCTAssertTrue([[reader tokenString] isEqualToString: @"1234"]);
    XCTAssertEqual([reader nextToken],STErrorTokenType);
    XCTAssertEqual([reader nextToken],STEndTokenType);
}

@end
