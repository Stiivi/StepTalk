/**
    NSArray-additions.m
    Various methods for NSArray
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
 
 */

#import "NSArray+additions.h"
#import "NSNumber+additions.h"
#import "STBlock.h"

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSEnumerator.h>

@implementation NSArray (STCollecting)
- do:(STBlock *)block
{
    NSEnumerator *enumerator;
    id            object;
    id            retval = nil;
    
    enumerator = [self objectEnumerator];
    while( (object = [enumerator nextObject]) )
    {
        retval = [block valueWith:object];
    }

    return retval;
}
- select:(STBlock *)block
{
    NSMutableArray *array;
    NSEnumerator   *enumerator;
    id              object;
    id              value;
    
    array = [NSMutableArray array];
    
    enumerator = [self objectEnumerator];
    while( (object = [enumerator nextObject]) )
    {
        value = [block valueWith:object];
        if([(NSNumber *)value isTrue])
        {
            [array addObject:object];
        }
    }

    return [NSArray arrayWithArray:array];
}

- reject:(STBlock *)block
{
    NSMutableArray *array;
    NSEnumerator   *enumerator;
    id              object;
    id              value;
    
    array = [NSMutableArray array];
    
    enumerator = [self objectEnumerator];
    while( (object = [enumerator nextObject]) )
    {
        value = [block valueWith:object];
        if([(NSNumber *)value isFalse])
        {
            [array addObject:object];
        }
    }

    return [NSArray arrayWithArray:array];
}

- collect:(STBlock *)block
{    
    NSMutableArray *array;
    NSEnumerator   *enumerator;
    id              object;
    id              value;
    
    array = [NSMutableArray array];
    
    enumerator = [self objectEnumerator];
    while( (object = [enumerator nextObject]) )
    {
        value = [block valueWith:object];
        [array addObject:value];
    }

    return [NSArray arrayWithArray:array];

}
- detect:(STBlock *)block
{
    NSEnumerator *enumerator;
    id            object;
    id            retval = nil;

    enumerator = [self objectEnumerator];
    while( (object = [enumerator nextObject]) )
    {
        retval = [block valueWith:object];
        if([(NSNumber *)retval isTrue])
        {
            return object;
        }
    }
    return retval;
}
@end
