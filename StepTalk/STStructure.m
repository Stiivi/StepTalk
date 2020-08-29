/**
    STStructure.m
    C structure wrapper
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of StepTalk.
 */

#import "STStructure.h"

#import "STExterns.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSDebug.h>
#import "NSInvocation+additions.h"

#import <objc/objc-api.h>

@implementation STStructure
+ structureWithValue:(void *)value type:(const char*)type
{
    STStructure *str;
    str = [[self alloc] initWithValue:value type:type];
    return str;
}
+ structureWithRange:(NSRange)range
{
    STStructure *str;
    str = [[self alloc] initWithValue:&range type:@encode(NSRange)];
    return str;
}

+ structureWithPoint:(NSPoint)point
{
    STStructure *str;
    str = [[self alloc] initWithValue:&point type:@encode(NSPoint)];
    return str;
}
+ structureWithSize:(NSSize)size
{
    STStructure *str;
    str = [[self alloc] initWithValue:&size type:@encode(NSSize)];
    return str;
}

+ structureWithRect:(NSRect)rect
{
    STStructure *str;
    str = [[self alloc] initWithValue:&rect type:@encode(NSRect)];
    return str;
}

- initWithValue:(void *)value type:(const char*)type
{
    const char *nameBeg;
    int offset = 0;
    NSUInteger size;
    NSUInteger align;
    int rem;
    

    self = [super init];

    NSLog(@"creating structure of type '%s' value ptr %p",type,value);
    
    structType = [[NSString alloc] initWithCString:type encoding:NSUTF8StringEncoding];
    
    fields = [[NSMutableArray alloc] init];

    type++;

    nameBeg = type;
    while (*type != '}' && *type != '=') {
        type += 1;
    };

    name = [[NSString alloc] initWithBytes:nameBeg
                                    length:type-nameBeg
                                  encoding: NSUTF8StringEncoding];
    
    while(*type != '}')
    {
        NSGetSizeAndAlignment(type, &size, &align);
        
        [fields addObject:STObjectFromValueOfType(((char *)value)+offset,type)];

        offset += size;
            
        rem = offset % align;
        if(rem != 0)
        {
            offset += align - rem;
        }

        // #FIXME: We need a better type iterator here
        // #FIXME: same in next method getValue:
        //
        // #TODO: See https://nshipster.com/type-encodings/ for more information
        //
        // Original was:
        // type = objc_skip_typespec(type);

        type += 1;

        if(*type == '}')
        {
            break;
        }
    }

    return self;
}

- (void)getValue:(void *)value
{
    const char *type = [structType cStringUsingEncoding: NSUTF8StringEncoding];
    int offset=0;
    NSUInteger size;
    NSUInteger align;
    int rem;
    int i = 0;
    
    type++;
    while (*type != '}' && *type++ != '=');

    while(*type != '}')
    {
        STGetValueOfTypeFromObject((void *)((char*)value+offset),
                                   type,
                                   [fields objectAtIndex:i++]);

        NSGetSizeAndAlignment(type, &size, &align);
        offset += size;
        rem = offset % align;
        if(rem != 0)
        {
            offset += align - rem;
        }

        // #FIXME: see comment in initWithValue
        // #TODO: See https://nshipster.com/type-encodings/ for more information
        //
        // Original was:
        // type = objc_skip_typespec(type);
        type += 1;

        if(*type == '}')
        {
            break;
        }
    }
}

- (const char *)type
{
    return [structType cStringUsingEncoding:NSUTF8StringEncoding];
}
- (NSString *)structureName
{
    return name;
}
- (NSRange)rangeValue
{
    /* FIXME: do some checking */
    return NSMakeRange([self intValueAtIndex:0],[self intValueAtIndex:1]);
}

- (NSPoint)pointValue
{
    /* FIXME: do some checking */
    return NSMakePoint([self floatValueAtIndex:0],[self floatValueAtIndex:1]);
}

- (NSSize)sizeValue
{
    /* FIXME: do some checking */
    return NSMakeSize([self floatValueAtIndex:0],[self floatValueAtIndex:1]);
}

- (NSRect)rectValue
{
    NSPoint origin = [[fields objectAtIndex:0] pointValue];
    NSSize size = [[fields objectAtIndex:1] sizeValue];
    NSRect rect;
    
    /* FIXME: do some checking */
    rect.origin = origin;
    rect.size = size;
    return rect;
}

- valueAtIndex:(unsigned)index
{
    return [fields objectAtIndex:index];
}
- (void)setValue:anObject atIndex:(unsigned)index
{
    [fields replaceObjectAtIndex:index withObject:anObject];
}

- (int)intValueAtIndex:(unsigned)index
{
    return (int)[[fields objectAtIndex:index] intValue];
}
- (float)floatValueAtIndex:(unsigned)index
{
    return (float)[[fields objectAtIndex:index] floatValue];
}

/* NSRange */

- (int)location
{
    return [[fields objectAtIndex:0] intValue];
}

- (int)length
{
    return [[fields objectAtIndex:1] intValue];
}

- (void)setLocation:(int)location
{
    [fields replaceObjectAtIndex:0 withObject: [NSNumber numberWithInt:location]];
}

- (void)setLength:(int)length
{
    [fields replaceObjectAtIndex:1 withObject: [NSNumber numberWithInt:length]];
}

/* NSPoint */

- (float)x
{
    return [[fields objectAtIndex:0] floatValue];
}

- (void)setX:(float)x
{
    [fields replaceObjectAtIndex:0 withObject: [NSNumber numberWithFloat:x]];
}

- (float)y
{
    return [[fields objectAtIndex:1] floatValue];
}

- (void)setY:(float)y
{
    [fields replaceObjectAtIndex:1 withObject: [NSNumber numberWithFloat:y]];
}

/* NSSize */

- (float)width
{
    return [[fields objectAtIndex:0] floatValue];
}

- (float)height
{
    return [[fields objectAtIndex:1] floatValue];
}

- (void)setWidth:(float)width
{
    [fields replaceObjectAtIndex:0 withObject: [NSNumber numberWithFloat:width]];
}
- (void)setHeight:(float)height
{
    [fields replaceObjectAtIndex:1 withObject: [NSNumber numberWithFloat:height]];
}

/* NSRect */

- (id)origin
{
    NSLog(@"Origin %@", [fields objectAtIndex:0]);
    return [fields objectAtIndex:0];
}

- (id)size
{
    NSLog(@"Size %@", [fields objectAtIndex:1]);
    return [fields objectAtIndex:1] ;
}

@end
