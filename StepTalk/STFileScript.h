/**
    STScript
  
    Written by: Stefan Urbanek <stefan.urbanek@gmail.com>
    Date: 2002 Mar 10
 
    This file is part of the StepTalk project.
 
   */

#import <StepTalk/STScript.h>

@interface STFileScript:STScript
{
    NSString *fileName;
    NSString *localizedName;
    NSString *menuKey;
    NSString *description;
}
+ scriptWithFile:(NSString *)file;

- initWithFile:(NSString *)aFile;
- (NSString *)fileName;
- (NSString *)scriptName;
- (NSString *)localizedName;
- (NSString *)scriptDescription;
- (NSComparisonResult)compareByLocalizedName:(STFileScript *)aScript;
@end
