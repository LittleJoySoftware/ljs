
#import "LjsTestCase.h"
#import "LjsCategories.h"

@interface NSStringLjsAdditionsTest : LjsTestCase {}
@end


@implementation NSStringLjsAdditionsTest

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

- (void) test_has_chars_false {
  NSString *str = nil;
  GHAssertFalse([str has_chars], @"should not have chars: '%@'", str);
  GHAssertFalse([str not_empty], @"should not be not_empty: '%@'", str);
  NSMutableString *mstr = nil;
  GHAssertFalse([mstr has_chars], @"should not have chars: '%@'", mstr);
  GHAssertFalse([mstr not_empty], @"should not be not_empty: '%@'", mstr);

  str = @"";
  GHAssertFalse([str has_chars], @"should not have chars: '%@'", str);
  GHAssertFalse([str not_empty], @"should not be not_empty: '%@'", str);
  mstr = [NSMutableString stringWithString:str];
  GHAssertFalse([mstr has_chars], @"should not have chars: '%@'", mstr);
  GHAssertFalse([mstr not_empty], @"should not be not_empty: '%@'", mstr);
}

- (void) test_has_chars_true {
  NSString *str = @"a";
  GHAssertTrue([str has_chars], @"should have chars: '%@'", str);
  GHAssertTrue([str not_empty], @"should be not_empty: '%@'", str);
  NSMutableString *mstr = [NSMutableString stringWithString:str];
  GHAssertTrue([mstr has_chars], @"should have chars: '%@'", mstr);
  GHAssertTrue([mstr not_empty], @"should be not_empty: '%@'", mstr);
}

#if TARGET_OS_IPHONE
- (void) test_string_by_truncating_with_ellipsis {
  NSString *text, *actual;
  CGFloat w;
  CGSize size;
  UIFont *font = [UIFont systemFontOfSize:18];
  text = @"The horse raced past the barn fell.";
  size = [text sizeWithFont:font];
  w = size.width / 2;
  actual = [text stringByTruncatingToWidth:w withFont:font];

  // bloody fucking impossible to figure out
  // and maybe non-deterministic
  // iphone sim 4.3, mercury,  ipad 4.3 sim (non-retina)
  // The horse rac...
  // pluto, ipad 5.0 sim (non-retina/non-retina)
  // The horse ra...
  NSArray *candidates = @[@"The horse rac...",
                         @"The horse ra..."];
  
  GHAssertTrue([candidates containsObject:actual], 
               @"%@ should be one of these strings: %@", actual, candidates);
}
#endif

#pragma mark - contains chars of set

- (void) test_stringContiansOnlyMembersOfCharacterSet {
  NSString *string;
  BOOL actual;
  NSCharacterSet *set;
  
  string = nil;
  set = nil;
  actual = [string containsOnlyMembersOfCharacterSet:set];
  GHAssertFalse(actual, nil);
  
  string = nil;
  set = [NSCharacterSet alphanumericCharacterSet];
  actual = [string containsOnlyMembersOfCharacterSet:set];
  GHAssertFalse(actual, nil);
  
  string = @"";
  set = [NSCharacterSet alphanumericCharacterSet];
  actual = [string containsOnlyMembersOfCharacterSet:set];
  GHAssertFalse(actual, nil);
  
  string = @"abcde1234";
  set = [NSCharacterSet alphanumericCharacterSet];
  actual = [string containsOnlyMembersOfCharacterSet:set];
  GHAssertTrue(actual, nil);
  
  string = @"abc de1234";
  set = [NSCharacterSet alphanumericCharacterSet];
  actual = [string containsOnlyMembersOfCharacterSet:set];
  GHAssertFalse(actual, nil);
  
  string = @"abcde1234";
  set = [NSCharacterSet decimalDigitCharacterSet];
  actual = [string containsOnlyMembersOfCharacterSet:set];
  GHAssertFalse(actual, nil);
  
}

- (void) test_isAlphaNumeric {
  NSString *test;
  BOOL actual;
  
  test = nil;
  actual = [test containsOnlyAlphaNumeric:test];
  GHAssertFalse(actual, nil);
  
  test = @"";
  actual = [test containsOnlyAlphaNumeric:test];
  GHAssertFalse(actual, nil);
  
  test = @"530";
  actual = [test containsOnlyAlphaNumeric:test];
  GHAssertTrue(actual, nil);
  
  test = @"5--";
  actual = [test containsOnlyAlphaNumeric:test];
  GHAssertFalse(actual, nil);
  
  test = @"5adf";
  actual = [test containsOnlyAlphaNumeric:test];
  GHAssertTrue(actual, nil);
}


- (void) test_isNumeric {
  NSString *test;
  BOOL actual;
  
  test = nil;
  actual = [test containsOnlyNumbers:test];
  GHAssertFalse(actual, nil);
  
  test = @"";
  actual = [test containsOnlyNumbers:test];
  GHAssertFalse(actual, nil);
  
  test = @"530";
  actual = [test containsOnlyNumbers:test];
  GHAssertTrue(actual, nil);
  
  test = @"5--";
  actual = [test containsOnlyNumbers:test];
  GHAssertFalse(actual, nil);
  
  test = @"5adf";
  actual = [test containsOnlyNumbers:test];
  GHAssertFalse(actual, nil);
}


@end
