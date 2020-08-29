/**
    STStructure.h
    C structure wrapper
 
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2000
   
    This file is part of StepTalk.
  */

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSRange.h>

// @class STRange;
// @class STPoint;
// @class STRect;
@class NSString;
@class NSMutableArray;

@interface STStructure:NSObject
{
    NSString *structType;
    NSString *name;
    NSMutableArray  *fields;
}
+ structureWithValue:(void *)value type:(const char*)type;
+ structureWithRange:(NSRange)range;
+ structureWithPoint:(NSPoint)point;
+ structureWithRect:(NSRect)rect;
+ structureWithSize:(NSSize)size;

- initWithValue:(void *)value type:(const char*)type;
- (const char *)type;
- (NSString *)structureName;

- (void)getValue:(void *)value;

- (NSRange)rangeValue;
- (NSPoint)pointValue;
- (NSRect)rectValue;
- (NSSize)sizeValue;

- valueAtIndex:(unsigned)index;
- (void)setValue:anObject atIndex:(unsigned)index;

- (int)intValueAtIndex:(unsigned)index;
- (float)floatValueAtIndex:(unsigned)index;
@end

/*
@interface STRange:STStructure
- rangeWithLocation:(int)loc length:(int)length;
- (int)location;
- (int)length;
@end

@interface STPoint:STStructure
- pointWithX:(float)x y:(float)y;
- (float)x;
- (float)y;
@end

@interface STRect:STStructure
- rectWithX:(float)x y:(float)y width:(float)w heigth:(float)h;
- rectWithOrigin:(NSPoint)origin size:(NSPoint)size;
- (float)x;
- (float)y;
- (float)width;
- (float)height;
- (NSPoint)origin;
- (NSPoint)size;
@end
*/
