#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

@interface OCMockWorkingTest : XCTestCase
@end

@implementation OCMockWorkingTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void) setUp {
  [super setUp];
  // Run before each test method
}

- (void) tearDown {
  // Run after each test method
  [super tearDown];
}  

- (void) test_OCMockWorking {
  id actual;
  id mock = [OCMockObject mockForClass:[NSString class]];
  [[[mock expect] andReturn:@"megamock"] lowercaseString];
  actual = [mock lowercaseString];
  [mock verify];

  XCTAssertEqualObjects(actual, @"megamock", @"Should have returned stubbed value.");
}




@end
