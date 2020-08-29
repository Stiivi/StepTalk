/**
    NSInvocation+additions
    Various NSInvocation additions
    
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of the StepTalk project.  
 */

#import "NSInvocation+additions.h"

#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSString.h>
#import <Foundation/NSMethodSignature.h>

#import "STExterns.h"
#import "STObjCRuntime.h"
#import "STScripting.h"
#import "STSelector.h"
#import "STStructure.h"

#import <objc/runtime.h>

#define CASE_NUMBER_TYPE(otype,type,msgtype)\
            case otype: object = [NSNumber numberWith##msgtype:*((type *)value)];\
                        NSLog(@"    is number value '%@'", object);\
                        break

/** This method is a factory method, that means that you have to release the
    object when you no longer need it. */
id STObjectFromValueOfType(void *value, const char *type)
{
    id object;

    switch(*type)
    {
    case '@':
            object = *((__weak id *)value);
            NSLog(@"    is object value %p", object);
            break;
    case '#':
            object = *((Class *)value);
            NSLog(@"    is class value %p", object);
            break;
    CASE_NUMBER_TYPE('c',char,Char);
    CASE_NUMBER_TYPE('C',unsigned char, UnsignedChar);
    CASE_NUMBER_TYPE('s',short,Short);
    CASE_NUMBER_TYPE('S',unsigned short,UnsignedShort);
    CASE_NUMBER_TYPE('i',int,Int);
    CASE_NUMBER_TYPE('I',unsigned int,UnsignedInt);
    CASE_NUMBER_TYPE('l',long,Long);
    CASE_NUMBER_TYPE('L',unsigned long,UnsignedLong);
    CASE_NUMBER_TYPE('q',long long,LongLong);
    CASE_NUMBER_TYPE('Q',unsigned long long,UnsignedLongLong);
    CASE_NUMBER_TYPE('f',float,Float);
    CASE_NUMBER_TYPE('d',double,Double);
    case '^':
                object = [NSValue valueWithPointer:*((void **)value)];
                NSLog(@"    is pointer value %p", *((void **)value));
                break;
    case '*':
            object = [NSString stringWithCString:*((char **)value) encoding: NSUTF8StringEncoding];
                NSLog(@"    is string value '%s'", *((char **)value));
                break;
    case 'v':
                object = nil;
                break;
    case '{':
                object = [[STStructure alloc] initWithValue:value
                                                       type:type];
                break;
    case ':':
                object = [[STSelector alloc] initWithSelector:*((SEL *)value)];
                break;
    default:
        [NSException raise:STInvalidArgumentException
                    format:@"unhandled ObjC type '%s'",
                            type];

    }       
    return object;
}

#define CASE_TYPE(otype,type,msgtype)\
            case otype:(*((type *)value)) = [anObject msgtype##Value];\
                        NSLog(@"    is number value '%@'", anObject);\
                       break

void STGetValueOfTypeFromObject(void *value, const char *type, id anObject)
{
    switch(*type)
    {
    case '@':
        (*(__weak id *)value) = anObject;
        break;
    case '#':
            (*(Class *)value) = anObject;
            break;
    CASE_TYPE('c',char,char);
    CASE_TYPE('C',unsigned char,unsignedChar);
    CASE_TYPE('s',short,short);
    CASE_TYPE('S',unsigned short,unsignedShort);
    CASE_TYPE('i',int,int);
    CASE_TYPE('I',unsigned int,unsignedInt);
    CASE_TYPE('l',long,long);
    CASE_TYPE('L',unsigned long,unsignedLong);
    CASE_TYPE('q',long long,longLong);
    CASE_TYPE('Q',unsigned long long,unsignedLongLong);
    CASE_TYPE('f',float,float);
    CASE_TYPE('d',double,double);
    CASE_TYPE('^',void *,pointer);
    case '*': /* FIXME: check if this is good (copy/no copy)*/
            (*((const char **)value)) = [[anObject stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"is cstring '%@'", [anObject stringValue]);
            break;
    case '{':
            /* FIXME: chech for struct compatibility */
            NSLog(@"is structure");
            [(STStructure*)anObject getValue:value];
            break;

    case ':':
            (*((SEL *)value)) = [anObject selectorValue];
            break;
            
    default:
        [NSException raise:STInvalidArgumentException
                    format:@"unhandled ObjC type '%s'",
                            type];
    }        
}


@implementation NSInvocation(STAdditions)
+ invocationWithTarget:(id)target selectorName:(NSString *)selectorName
{
    NSMethodSignature *signature;
    NSInvocation      *invocation;
    SEL                sel;
    
    // NSLog(@"GETTING SELECTOR %@", selectorName);
    sel = NSSelectorFromString(selectorName);
    
    if(!sel)
    {
        // NSLog(@"REGISTERING SELECTOR");
        const char *name = [selectorName cStringUsingEncoding: NSUTF8StringEncoding];
        
        sel = sel_registerName(name);

        if(!sel)
        {
            [NSException raise:STInternalInconsistencyException
                         format:@"Unable to register selector '%@'",
                                selectorName];
        }
    }
    
    signature = [target methodSignatureForSelector:sel];

    /* FIXME: this is workaround for gnustep DO bug (hight priority) */

    if(!signature)
    {
        [NSException raise:STInternalInconsistencyException
                     format:@"No method signature for selector '%@' for "
                            @"receiver of type %@",
                            selectorName,[target className]];
    }
  
    invocation = [NSInvocation invocationWithMethodSignature:signature];

    [invocation setSelector:sel];
    [invocation setTarget:target];

    return invocation;
}

+ invocationWithTarget:(id)target selector:(SEL)selector
{
    NSMethodSignature *signature;
    NSInvocation      *invocation;
    
    signature = [target methodSignatureForSelector:selector];


    if(!signature)
    {
        [NSException raise:STInternalInconsistencyException
                     format:@"No method signature for selector '%@' for "
                            @"receiver of type %@",
                            NSStringFromSelector(selector),[target className]];
    }
  
    invocation = [NSInvocation invocationWithMethodSignature:signature];

    [invocation setSelector:selector];
    [invocation setTarget:target];

    return invocation;
}

- (void)setArgumentAsObject:(id)anObject atIndex:(int)anIndex
{
    const char *type;
    void *value;
    NSUInteger size;
    
    NSGetSizeAndAlignment(type, &size, NULL);
    
    type = [[self methodSignature] getArgumentTypeAtIndex:anIndex];
    value = NSZoneMalloc(STMallocZone,size);

    STGetValueOfTypeFromObject(value, type, anObject);

    [self setArgument:(void *)value atIndex:anIndex];
    NSZoneFree(STMallocZone,value);
}


- (id)getArgumentAsObjectAtIndex:(int)anIndex
{
    const char *type;
    void *value;
    id    object;
    NSUInteger size;
    
    NSGetSizeAndAlignment(type, &size, NULL);

    type = [[self methodSignature] getArgumentTypeAtIndex:anIndex];

    value = NSZoneMalloc(STMallocZone,size);
    [self getArgument:value atIndex:anIndex];

    object = STObjectFromValueOfType(value,type);
    
    NSZoneFree(STMallocZone,value);
    
    return object;
}
- (id)returnValueAsObject
{
    const char *type;
    NSUInteger   returnLength;
    void *value;
    id    returnObject = nil;
    
    NSMethodSignature *signature = [self methodSignature];

    type = [signature methodReturnType];
    returnLength = [signature methodReturnLength];

    NSLog(@"  return type '%s', buffer length %lui",type,returnLength);

    if(returnLength!=0)
    {
        value = NSZoneMalloc(STMallocZone,returnLength);
        [self getReturnValue:value];
                           
        if( *type == '?' )
        {
            returnObject = [self target];
        }
        else
        {
            returnObject = STObjectFromValueOfType(value, type);
        }

        NSZoneFree(STMallocZone,value);
        NSLog(@"  returned object %@",returnObject);
    }
    else
    {
        returnObject = [self target];
    }

    return returnObject;
}
@end

