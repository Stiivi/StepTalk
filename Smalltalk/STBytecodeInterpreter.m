/**
    STBytecodeInterpreter.m
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000

    This file is part of the StepTalk project.
 */

#import "STBytecodeInterpreter.h"

#import "Externs.h"
#import "STBlock.h"
#import "STBlockContext.h"
#import "STBytecodes.h"
#import "STCompiledMethod.h"
#import "STExecutionContext.h"
#import "STLiterals.h"
#import "STMessage.h"
#import "STMethodContext.h"
#import "STSmalltalkScriptObject.h"
#import "STStack.h"

#import <StepTalk/STEnvironment.h>
#import <StepTalk/STExterns.h>
#import <StepTalk/STFunctions.h>
#import <StepTalk/NSInvocation+additions.h>
#import <StepTalk/STScripting.h>
#import <Foundation/NSAutoreleasePool.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSValue.h>

@interface STBytecodeInterpreter(STPrivateMethods)
- (short)fetchBytecode;
- (BOOL)dispatchBytecode:(STBytecode)bytecode;
- (void)invalidBytecode:(STBytecode)bytecode;

- (void)setInstructionPointer:(unsigned)newIP;
- (unsigned)instructionPointer;

- (void)sendSelectorAtIndex:(unsigned)index withArgs:(unsigned)argCount;

- (id)interpret;
- (void)returnValue:(id)value;
@end

static Class NSInvocation_class = nil;

@implementation STBytecodeInterpreter
+ (void)initialize
{
    NSInvocation_class = [NSInvocation class];
}
+ interpreterWithEnvrionment:(STEnvironment *)env
{
    return [[self alloc] initWithEnvironment:env];
}

- initWithEnvironment:(STEnvironment *)env
{
    self = [super init];
    environment = env;
    return self;
}
- (void)setEnvironment:(STEnvironment *)env
{
    environment = env;
}

- (id)interpretMethod:(STCompiledMethod *)method 
          forReceiver:(id)anObject
            arguments:(NSArray*)args
{
    // NSAutoreleasePool *pool = [NSAutoreleasePool new];
    STExecutionContext *oldContext;
    STMethodContext    *newContext;
    id                  retval;
    
    if(!environment)
    {
        [NSException  raise:STInterpreterGenericException
                     format:@"No execution environment set"];
        return nil;
    }
    
    NSLog(@"Executing method %@ with %lu args",
                [method selector],[args count]);

    if(!method)
    {
        return nil;
    }
    
    if([args count] != [method argumentCount])
    {
        [NSException  raise:STInterpreterGenericException
                     format:@"Invalid argument count %lu (should be %i)"
                            @" for method %@ ",
                            [args count],[method argumentCount], 
                            [method selector]];
    }
    
    newContext = [[STMethodContext alloc] initWithMethod:method
                                             environment:environment];

    [newContext setArgumentsFromArray:args];
    [newContext setReceiver:anObject];

    oldContext = activeContext;
    [self setContext:newContext];

    retval = [self interpret];

    [self setContext:oldContext];

    newContext;

    return retval;
}

/* ---------------------------------------------------------------------------
 * Interpret
 * ---------------------------------------------------------------------------
 */

- (void)setContext:(STExecutionContext *)newContext
{
    
    NSLog(@"Switch from context %@ to context %@",
                activeContext, newContext);

    if(!newContext)
    {
        activeContext;
        activeContext = nil;
        stack = nil;
        bytecodes = nil;
        instructionPointer = 0;
        receiver = nil;
        
        return;
    }
    
    if( ![newContext isValid])
    {
        [NSException raise:STInterpreterGenericException
                    format:@"Trying to set an invalid context"];
    }

    [activeContext setInstructionPointer:instructionPointer];

    activeContext = newContext;

    stack = [activeContext stack];
    receiver = [activeContext receiver];

    if(!stack)
    {
        [NSException raise:STInternalInconsistencyException
                    format:@"No execution stack"];
    }

    instructionPointer = [activeContext instructionPointer];
    bytecodes = [activeContext bytecodes];
}

- (STExecutionContext *)context
{
    return activeContext;
}

- (id)interpret
{
    STBytecode bytecode;
    id         retval;
    
    entry++;

    NSLog(@"Interpreter entry %i", entry);
    NSLog(@"IP %x %ul", instructionPointer, [bytecodes length]);

    if(!bytecodes)
    {
        NSLog(@"Smalltalk: No bytecodes.");
        return nil;
    }

    stopRequested = NO;
    
    do
    {
        bytecode = [bytecodes fetchNextBytecodeAtPointer:&instructionPointer];

        if(stopRequested)
        {
            break;
        }

    } while( [self dispatchBytecode:bytecode] );

    if(!stopRequested)
    {
        retval = [stack pop];
    }
    else
    {
        NSLog(@"Stop requested");
        
        retval = nil;
    }

    NSLog(@"Returning '%@' from interpreter (entry %i)",retval,entry);

    entry --;
    return retval;
}

- (void)halt
{
    NSLog(@"Halt!");
    stopRequested = YES;
}

/* ---------------------------------------------------------------------------
 * Return
 * ---------------------------------------------------------------------------
 */
 
- (void)returnValue:(id)value
{

    NSLog(@"%@ return value '%@' from method",
                activeContext,value);

    [activeContext invalidate];
    [stack push:value];
}

- (unsigned)instructionPointer
{
    return instructionPointer;
}


/* ---------------------------------------------------------------------------
 * Block manipulation
 * ---------------------------------------------------------------------------
 */
- (void)createBlockWithArgumentCount:(int)argCount stackSize:(int)stackSize
{
    unsigned ptr;
    STBlock        *block;
    
    ptr = instructionPointer + STLongJumpBytecodeSize;

    NSLog(@"%@ Create block: argc:%i stack:%i ip:0x%04x",
                 activeContext, 
                 argCount,
                 stackSize,
                 ptr);

    block = [STBlock alloc];
    
    [block initWithInterpreter:self
                   homeContext:[activeContext homeContext]
                     initialIP:ptr
                 argumentCount:argCount
                     stackSize:stackSize];
  
    [stack push:block];
}

/* ---------------------------------------------------------------------------
    send selector (see also STEnvironment class)
 * ---------------------------------------------------------------------------
 */

- (void)sendSelectorAtIndex:(unsigned)selIndex withArgCount:(unsigned)argCount
{
    NSString          *selector;
    NSInvocation      *invocation;
    id                 target;
    int                index;
    id                 object;

    NSLog(@"send selector '%@' with %i args'",
                [activeContext literalObjectAtIndex:selIndex],argCount);
                
    target = [stack valueFromTop:argCount];
    
    /* FIXME */
    if(!target)
    {
        target = STNil;
    }
    
    selector = [activeContext literalObjectAtIndex:selIndex];

    NSLog(@"  %s receiver:%@ (%@) selector:%@",
               [receiver isProxy] ? "proxy for" : "",
               target,
               NSStringFromClass([target class]),
               selector);


    /* FIXME: this is too slow */
    selector = [environment translateSelector:selector forReceiver:target];

    invocation = [NSInvocation_class invocationWithTarget:target
                                             selectorName:selector];
                                       
    if(!invocation)
    {
        [NSException raise:STInternalInconsistencyException
                     format:@"Should not send selector '%@' to "
                            @"receiver of type %@ (could not create invocation)",
                            selector,[target className]];
        return;
    }
    

    for(index = argCount + 1; index > 1; index--)
    {

        object = [stack pop];
                   
        if(object == STNil)
        {
            object = nil;
        }
        
        NSLog(@"    argument %2i: '%@'",index - 2, object);

        [invocation setArgumentAsObject:object atIndex:index];
    }

    /* ---------------------------- 
     * invoke it!
     * ----------------------------
     */

    NSLog(@"  invoking... (%@ %s)",invocation, [[invocation methodSignature] methodReturnType]);
    [invocation invoke];
    NSLog(@"  done invoking.",invocation);

    /* FIXME */
    if(!stopRequested)
    {
        /* pop the receiver from the stack */
        [stack pop];
        [stack push: [invocation returnValueAsObject]];
    }
}


/* ---------------------------------------------------------------------------
    Bytecode manipulation
 * ---------------------------------------------------------------------------
 */
#define STDebugBytecode(bc) \
                NSLog(@"#%04x %@", \
                            (bc).pointer, \
                            STDissasembleBytecode(bc))

#define STDebugBytecodeWith(bc,object) \
                NSLog(@"#%04x %@ (%@)", \
                            (bc).pointer, \
                            STDissasembleBytecode(bc), \
                            (object))

- (BOOL)dispatchBytecode:(STBytecode)bytecode
{
    NSString *refName;
    id        object;
    
    switch(bytecode.code)
    {
    case STLongJumpBytecode:
                {
/*
                    int offset = STLongJumpOffset(bytecode.arg1,bytecode.arg2)
                                    - STLongJumpBytecodeSize;
*/
		    int offset = bytecode.arg1 - STLongJumpBytecodeSize;
                    STDebugBytecode(bytecode);
                    instructionPointer+=offset;
                    break;
                }

    case STPushReceiverBytecode:
            STDebugBytecodeWith(bytecode,receiver);
            [stack push:receiver];
            break;

    case STPushNilBytecode:
            STDebugBytecodeWith(bytecode,receiver);
            [stack push:nil];
            break;

    case STPushTrueBytecode:
            STDebugBytecodeWith(bytecode,receiver);
            [stack push: [NSNumber numberWithInt:YES]];
            break;

    case STPushFalseBytecode:
            STDebugBytecodeWith(bytecode,receiver);
            [stack push: [NSNumber numberWithInt:NO]];
            break;

    case STPushRecVarBytecode:
            refName = [activeContext referenceNameAtIndex:bytecode.arg1];
            object = [receiver valueForKey:refName];
            STDebugBytecodeWith(bytecode,object);
            [stack push:object];
            break;

    case STPushExternBytecode:
            refName = [activeContext referenceNameAtIndex:bytecode.arg1];
            object = [environment objectWithName:refName];
            STDebugBytecodeWith(bytecode,object);
            [stack push: object];
            break;

    case STPushTemporaryBytecode:
            object = [activeContext temporaryAtIndex:bytecode.arg1];
            [stack push:object];
            STDebugBytecodeWith(bytecode,object);
            break;

    case STPushLiteralBytecode:
            object = [activeContext literalObjectAtIndex:bytecode.arg1];
            STDebugBytecodeWith(bytecode,object);
            [stack push:object];
            break;

    case STPopAndStoreRecVarBytecode:
            STDebugBytecode(bytecode);

            refName = [activeContext referenceNameAtIndex:bytecode.arg1];
            object = [stack pop];
            [receiver setValue:object forKey:refName];

            break;

    case STPopAndStoreExternBytecode: 
            STDebugBytecode(bytecode);
            refName = [activeContext referenceNameAtIndex:bytecode.arg1];
            object = [stack pop];
            [environment setObject:object forName:refName];
            break;

    case STPopAndStoreTempBytecode:
            STDebugBytecode(bytecode);
            [activeContext setTemporary:[stack pop] atIndex:bytecode.arg1];
            break;

    case STSendSelectorBytecode:
            STDebugBytecodeWith(bytecode,
                                [activeContext literalObjectAtIndex:bytecode.arg1]);

            [self sendSelectorAtIndex:bytecode.arg1
                         withArgCount:bytecode.arg2];
            break;

    case STSuperSendSelectorBytecode: /* FIXME: not implemented */
            [self invalidBytecode:bytecode];
            break;

    case STDupBytecode:
            STDebugBytecode(bytecode);
            [stack duplicateTop];
            break;

    case STPopStackBytecode:
            STDebugBytecode(bytecode);
            [stack pop];
            break;

    case STReturnBytecode:
    case STReturnBlockBytecode:
            STDebugBytecode(bytecode);
            [self returnValue:[stack pop]];
            return NO;

    case STBlockCopyBytecode: 
            STDebugBytecode(bytecode);
            {
                STBlockLiteral *info = [stack pop];
                [self createBlockWithArgumentCount:[info argumentCount]
                                         stackSize:[info stackSize]];
            }
            break;

    default:
            [self invalidBytecode:bytecode];
            break;
    };

    return YES;
}

- (void)invalidBytecode:(STBytecode)bytecode
{
    [NSException raise:STInternalInconsistencyException
                 format:@"invalid bytecode (0x%02x) at 0x%06x",
                         bytecode.code,bytecode.pointer];
}
@end


