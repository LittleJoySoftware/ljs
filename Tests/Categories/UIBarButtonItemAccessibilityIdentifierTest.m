#import "LjsTestCase.h"
#import "UIBarButtonItem+AccessibilityIdentifier.h"

@interface UIBarButtonItemAccessibilityIdentifierTest : LjsTestCase {}
@end


@implementation UIBarButtonItemAccessibilityIdentifierTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void) setUpClass {
  [super setUpClass];
  // Run at start of all tests in the class
}

- (void) tearDownClass {
  // Run at end of all tests in the class
  [super tearDownClass];
}

- (void) setUp {
  [super setUp];
  // Run before each test method
}

- (void) tearDown {
  // Run after each test method
  [super tearDown];
}

- (void) test_access_id {
  UIBarButtonItem *item = [[UIBarButtonItem alloc]
                           initWithTitle:@"foo"
                           style:UIBarButtonItemStyleDone
                           target:nil action:nil];
  item.accessibilityIdentifier = @"access id";
  GHAssertEqualStrings(item.accessibilityIdentifier, @"access id", @"should be able to get and set the access id");
}

- (void) test_access_id_nil {
  UIBarButtonItem *item = [[UIBarButtonItem alloc]
                           initWithTitle:@"foo"
                           style:UIBarButtonItemStyleDone
                           target:nil action:nil];
  item.accessibilityIdentifier = nil;
  GHAssertNil(item.accessibilityIdentifier, @"accessibility identifier should be nil");
}



@end
