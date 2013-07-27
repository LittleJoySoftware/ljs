#import <Foundation/Foundation.h>

/**
 NSIndexPath on NSIndexPath_LjsAdditions category.
 */
@interface NSIndexPath (NSIndexPath_LjsAdditions)

#if TARGET_OS_IPHONE
- (NSUInteger) u_row;
- (NSUInteger) u_section;
+ (NSIndexPath *) indexPath_urow:(NSUInteger) aRow usection:(NSUInteger) aSection;
#endif



@end
