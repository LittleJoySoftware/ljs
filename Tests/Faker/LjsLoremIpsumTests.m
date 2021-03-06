

#import "LjsTestCase.h"
#import "LjsLoremIpsum.h"

@interface LjsLoremIpsumTests : LjsTestCase {}
@end


@implementation LjsLoremIpsumTests

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

- (void) test_characters {
  LjsLoremIpsum *li = [[LjsLoremIpsum alloc] init];
  NSUInteger number, actual;
  NSString *string;
  number = 10;
  string = [li characters:number];
  actual = [string length];
  GHAssertEquals((NSUInteger)actual, (NSUInteger)number, nil);
}

@end
