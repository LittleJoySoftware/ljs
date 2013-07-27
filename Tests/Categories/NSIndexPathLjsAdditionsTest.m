#import "LjsTestCase.h"
#import "NSIndexPath+LjsAdditions.h"

@interface NSIndexPathLjsAdditionsTest : LjsTestCase {}
@end


@implementation NSIndexPathLjsAdditionsTest

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

#pragma mark - tests

#if TARGET_OS_IPHONE

- (void) test_u_row {
  NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:1];
  GHAssertEquals((NSUInteger)ip.u_row, (NSUInteger)1, @"should be ==");
}

- (void) test_u_section {
  NSIndexPath *ip = [NSIndexPath indexPathForRow:1 inSection:1];
  GHAssertEquals((NSUInteger)ip.u_section, (NSUInteger)1, @"should be ==");
}

- (void) test_u_constructor {
  NSIndexPath *ip = [NSIndexPath indexPath_urow:1 usection:1];
  GHAssertNotNil(ip, @"should be able to create an index path");
}

#endif

@end
