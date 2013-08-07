#import "UIBarButtonItem+AccessibilityIdentifier.h"
#import "Lumberjack.h"
#import <objc/runtime.h>

#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif


static NSString *const kAssociativeRefKey_accessibilityIdentifier = @"com.littlejoysoftware UIBarButtonItem AR KEY accessibilityIdentifier";

@implementation UIBarButtonItem (UIBarButtonItem_AccessibilityIdentifier)

- (NSString *) accessibilityIdentifier {
  NSString *res = objc_getAssociatedObject(self, (__bridge const void *)(kAssociativeRefKey_accessibilityIdentifier));
  if (res != nil) { return res; }
  return self.accessibilityLabel;
}

- (void) setAccessibilityIdentifier:(NSString *) aAccessId {
  // if the access id is nil, just return nil
  if (aAccessId == nil) { return; }
  objc_setAssociatedObject(self, (__bridge const void *)(kAssociativeRefKey_accessibilityIdentifier), aAccessId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
