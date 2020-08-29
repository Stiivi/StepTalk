/**
    STBytecodes.m
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 
 */

#import "STBytecodes.h"

#import <StepTalk/STExterns.h>

#import "Externs.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>


NSArray *STBytecodeNames;

static void initNamesArray(void)
{
    NSString *invalid = @"invalid bytecode";
    NSMutableArray *array;
    int i;

    array = [NSMutableArray arrayWithCapacity:256];

    for(i=0;i<256;i++)
    {
        [array insertObject:invalid atIndex:i];
    }

    [array replaceObjectAtIndex:STPushReceiverBytecode 
                     withObject:@"push self"];
    [array replaceObjectAtIndex:STPushNilBytecode 
                     withObject:@"push nil"];
    [array replaceObjectAtIndex:STPushTrueBytecode 
                     withObject:@"push true"];
    [array replaceObjectAtIndex:STPushFalseBytecode 
                     withObject:@"push false"];
    [array replaceObjectAtIndex:STPushRecVarBytecode 
                     withObject:@"push ivar"];
    [array replaceObjectAtIndex:STPushExternBytecode 
                     withObject:@"push extern"];
    [array replaceObjectAtIndex:STPushTemporaryBytecode 
                     withObject:@"push temporary"];
    [array replaceObjectAtIndex:STPushLiteralBytecode 
                     withObject:@"push literal"];
    [array replaceObjectAtIndex:STPopAndStoreRecVarBytecode
                     withObject:@"pop and store ivar"];
    [array replaceObjectAtIndex:STPopAndStoreExternBytecode
                     withObject:@"pop and store extern"];
    [array replaceObjectAtIndex:STPopAndStoreTempBytecode
                     withObject:@"pop and store temp"];
    [array replaceObjectAtIndex:STSendSelectorBytecode
                     withObject:@"send selector"];
    [array replaceObjectAtIndex:STSuperSendSelectorBytecode
                     withObject:@"send super selector"];
    [array replaceObjectAtIndex:STBlockCopyBytecode 
                     withObject:@"block copy"];
    [array replaceObjectAtIndex:STDupBytecode 
                     withObject:@"dup"];
    [array replaceObjectAtIndex:STPopStackBytecode 
                     withObject:@"pop"];
    [array replaceObjectAtIndex:STReturnBytecode 
                     withObject:@"return"];
    [array replaceObjectAtIndex:STReturnBlockBytecode 
                     withObject:@"return from block"];
    [array replaceObjectAtIndex:STBreakpointBytecode 
                     withObject:@"breakpoint"];
    [array replaceObjectAtIndex:STLongJumpBytecode 
                     withObject:@"long jump"];

    STBytecodeNames = [[NSArray alloc] initWithArray:array];
}


NSString *STBytecodeName(unsigned short code)
{
    static NSString *invalid = @"invalid bytecode";
    NSString        *name;

    if( code > [STBytecodeNames count] )
    {
        return invalid;
    }
    
    name = [STBytecodeNames objectAtIndex:code];
    
    if(name == nil)
    {
        return invalid;
    }

    return name;
}

NSString *STDissasembleBytecode(STBytecode bytecode)
{
    NSString *str;
    
    str = STBytecodeName(bytecode.code);
    
    switch(bytecode.code)
    {
    case STLongJumpBytecode:
                {
                    //int offset = STLongJumpOffset(bytecode.arg1,bytecode.arg2);
                    int offset = bytecode.arg1;
                    return [NSString  stringWithFormat:@"%@ %i (0x%06x)",
                                      str, offset, bytecode.pointer+offset];
                }
    case STSendSelectorBytecode:
    case STSuperSendSelectorBytecode:
                return [NSString  stringWithFormat:@"%@ %i with %i args",
                                  str, bytecode.arg1, bytecode.arg2];
    case STPushRecVarBytecode:
    case STPushExternBytecode:
    case STPushTemporaryBytecode:
    case STPushLiteralBytecode:
    case STPopAndStoreRecVarBytecode:
    case STPopAndStoreExternBytecode:
    case STPopAndStoreTempBytecode:
                return [NSString  stringWithFormat:@"%@ %i",
                                  str, bytecode.arg1];
    case STPushReceiverBytecode:
    case STPushNilBytecode:
    case STPushTrueBytecode:
    case STPushFalseBytecode:
    case STBlockCopyBytecode:
    case STDupBytecode:
    case STPopStackBytecode:
    case STReturnBytecode:
    case STReturnBlockBytecode:
    case STBreakpointBytecode:
                return str;
    default:
                return [NSString stringWithFormat:@"invalid (0x%02x)",
                                                  bytecode.code];

    }
}


@implementation STBytecodes
+ (void)initialize
{
    initNamesArray();
}
/*
- (id) initWithBytesNoCopy: (void*)someBytes
		    length: (unsigned)length
		  fromZone: (NSZone*)zone
{
    bytes = [[NSData alloc] initWithBytesNoCopy:someBytes 
                                         length:length 
                                       fromZone:zone];
    return self;
}
*/

/* FIXME: rewrite this class - it is a leftover */

- (id) initWithData: (NSData *)data
{
    self = [super init];

    bytes = data;
    
    return self;
}

- (NSData *)data
{
    return bytes;
}

- (const void *)bytes
{
    return [bytes bytes];
}
- (NSUInteger) length
{
    return [bytes length];
}

- (NSString *)description
{
    return [bytes description];
}

- (STBytecode)fetchNextBytecodeAtPointer:(unsigned *)pointer
{
    STBytecode  bytecode;
    const unsigned char *bytesPtr = (const unsigned char *)[bytes bytes];
    unsigned    length = [self length];
    
    if(*pointer < length)
    {
        bytecode.pointer = *pointer;
        bytecode.code = bytesPtr[(*pointer)++];

        switch(bytecode.code)
        {
        case STSendSelectorBytecode:
        case STSuperSendSelectorBytecode:
                    if(*pointer + 2 >= length)
                    {
                        break;
                    }
/*
                    bytecode.arg1 = bytesPtr[(*pointer)++];
                    bytecode.arg2 = bytesPtr[(*pointer)++];
*/
                    bytecode.arg1 = (bytesPtr[(*pointer)++])<<8;
                    bytecode.arg1 |= bytesPtr[(*pointer)++];
                    bytecode.arg2 = (bytesPtr[(*pointer)++])<<8;
                    bytecode.arg2 |= bytesPtr[(*pointer)++];
                    return bytecode;
        case STLongJumpBytecode:
        case STPushRecVarBytecode:
        case STPushExternBytecode:
        case STPushTemporaryBytecode:
        case STPushLiteralBytecode:
        case STPopAndStoreRecVarBytecode:
        case STPopAndStoreExternBytecode:
        case STPopAndStoreTempBytecode:
                    if(*pointer + 1 >= length)
                    {
                        break;
                    }
/*
                    bytecode.arg1 = bytesPtr[(*pointer)++];
*/
                    bytecode.arg1 = (bytesPtr[(*pointer)++])<<8;
                    bytecode.arg1 |= bytesPtr[(*pointer)++];
                    bytecode.arg2 = 0;
                    return bytecode;
        case STPushReceiverBytecode:
        case STPushNilBytecode:
        case STPushTrueBytecode:
        case STPushFalseBytecode:
        case STBlockCopyBytecode:
        case STDupBytecode:
        case STPopStackBytecode:
        case STReturnBytecode:
        case STReturnBlockBytecode:
        case STBreakpointBytecode:
                    bytecode.arg1 = 0;
                    bytecode.arg2 = 0;
                    return bytecode;
        default:
                    [NSException raise:STInternalInconsistencyException
                                format:@"Invalid bytecode 0x%02x at 0x%06x",
                                       bytecode.code,*pointer-1];

        }
    }

    [NSException raise:STInternalInconsistencyException
                format:@"Instruction pointer 0x%06x out of bounds (0x%06x)",
                       *pointer,length];
    return bytecode;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:bytes];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; // super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &bytes];

    return self;
}

@end

