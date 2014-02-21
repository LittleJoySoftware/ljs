#import "NSIndexPath+LjsAdditions.h"
#import "Lumberjack.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int __unused ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int __unused ddLogLevel = LOG_LEVEL_WARN;
#endif


@implementation NSIndexPath (NSIndexPath_LjsAdditions)

#if TARGET_OS_IPHONE

- (NSUInteger) u_row {
  return (NSUInteger)self.row;
}

- (NSUInteger) u_section {
  return (NSUInteger)self.section;
}

+ (NSIndexPath *) indexPath_urow:(NSUInteger) aRow usection:(NSUInteger) aSection {
  return [NSIndexPath indexPathForRow:(NSInteger)aRow inSection:(NSInteger)aSection];
}

#endif

@end
