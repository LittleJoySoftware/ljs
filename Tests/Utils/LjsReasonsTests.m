#import "LjsTestCase.h"
#import "LjsReasons.h"
#import "LjsVariates.h"


@interface LjsValidatorTests : LjsTestCase {}

@end


@implementation LjsValidatorTests

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


#if TARGET_OS_IPHONE
- (void) test_isZeroRect_true {
  BOOL actual = [LjsReasons isZeroRect:CGRectZero];
  GHAssertTrue(actual, @"should be true");
}

- (void) test_isZeroRect_false {
  BOOL actual = [LjsReasons isZeroRect:CGRectMake(0,1,0,1)];
  GHAssertFalse(actual, @"should be false");
}
#endif

#pragma mark - test ljs integer interval

- (void) test_integer_interval {
  LjsIntegerInterval interval = {-1, 1};
  GHAssertEquals((NSInteger)interval.min, (NSInteger)-1, @"min should be set correctly");
  GHAssertEquals((NSInteger)interval.max, (NSInteger)1, @"max should be set correctly");
}

- (void) test_integer_interval_invalid_equality {
  LjsIntegerInterval interval = LjsMakeIntegerInterval(1, -1);
  GHAssertEquals((NSInteger)interval.min, (NSInteger)NSIntegerMax, @"min should be set correctly");
  GHAssertEquals((NSInteger)interval.max, (NSInteger)NSIntegerMin, @"max should be set correctly");
  GHAssertEquals((LjsIntegerInterval)interval, (LjsIntegerInterval)LjsIntegerInterval_Invalid,
                 @"should be invalid interval");
}

/*
 NS_INLINE BOOL integer_interval_invalid(LjsIntegerInterval aInterval) {
 return aInterval.min == 0 && aInterval.max == 0;
 }
 
 NS_INLINE NSUInteger integer_interval_count(LjsIntegerInterval aInterval) {
 if (aInterval.min == aInterval.max) { return 1; }
 if (integer_interval_invalid(aInterval)) { return 0; }
 NSInteger max = aInterval.max;
 NSUInteger count = 0;
 for (NSInteger index = aInterval.min; index <= max; index++) {
 count = count + 1;
 }
 return count;
 }

 */

- (void) test_integer_invalid_YES {
  GHAssertTrue(integer_interval_invalid(LjsIntegerInterval_Invalid),
               @"should return true because interval is invalid");
}

- (void) test_integer_invalid_NO {
  LjsIntegerInterval interval = LjsMakeIntegerInterval(1, 3);
  GHAssertFalse(integer_interval_invalid(interval),
               @"should return false because interval is valid");
}


- (void) test_integer_interval_count_0 {
  GHAssertEquals((NSUInteger)integer_interval_count(LjsIntegerInterval_Invalid),
                 (NSUInteger)0, @"the invalid interval should have count 0");
}

- (void) test_integer_interval_count_1 {
  LjsIntegerInterval interval = LjsMakeIntegerInterval(1, 1);
  GHAssertEquals((NSUInteger)integer_interval_count(interval),
                 (NSUInteger)1, @"the invalid interval should have count 1");
}

- (void) test_integer_interval_count_two_negatives {
  LjsIntegerInterval interval = LjsMakeIntegerInterval(-4, -1);
  GHAssertEquals((NSUInteger)integer_interval_count(interval),
                 (NSUInteger)4, @"the interval should have count 4");
}

- (void) test_integer_interval_count_min_negative {
  LjsIntegerInterval interval = LjsMakeIntegerInterval(-2, 1);
  GHAssertEquals((NSUInteger)integer_interval_count(interval),
                 (NSUInteger)4, @"the interval should have count 4");
}

- (void) test_integer_interval_count_min_postive {
  LjsIntegerInterval interval = LjsMakeIntegerInterval(1, 4);
  GHAssertEquals((NSUInteger)integer_interval_count(interval),
                 (NSUInteger)4, @"the interval should have count 4");
}

- (void) test_integer_interval_count_min_zero {
  LjsIntegerInterval interval = LjsMakeIntegerInterval(0, 3);
  GHAssertEquals((NSUInteger)integer_interval_count(interval),
                 (NSUInteger)4, @"the interval should have count 4");
}

- (void) test_integer_interval_count_max_zero {
  LjsIntegerInterval interval = LjsMakeIntegerInterval(-3, 0);
  GHAssertEquals((NSUInteger)integer_interval_count(interval),
                 (NSUInteger)4, @"the interval should have count 4");
}



#pragma mark test init

- (void) test_ljsReasonsInit {
  LjsReasons *reasons = [[LjsReasons alloc] init];
  GHAssertNotNil(reasons, @"reasons should not be nil");
  GHAssertFalse([reasons hasReasons], @"reasons array should be empty");
}

- (void) test_ljsReasonsAddReason {
  LjsReasons *reasons = [[LjsReasons alloc] init];
  [reasons addReason:@"foo"];
  GHAssertTrue([reasons hasReasons], @"reasons array should have one reason after adding a reason");
}

- (void) test_ljsReasonsAddReasonIfNil {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo" ifNil:@"bar"];
  GHAssertFalse([reasons hasReasons], @"reasons array should be empty");
  [reasons addReasonWithVarName:@"niller" ifNil:nil];
  GHAssertTrue([reasons hasReasons], @"reasons array should have one reason after adding a reason");
  
  reasons = [LjsReasons new];
  [reasons ifNil:@"bar" addReasonWithVarName:@"foo"];
  GHAssertFalse([reasons hasReasons], @"reasons array should be empty");
  [reasons ifNil:nil addReasonWithVarName:@"niller"];
  GHAssertTrue([reasons hasReasons], @"reasons array should have one reason after adding a reason");
}

- (void) test_explanation {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReason:@"foo"];
  
  NSString *actual = [reasons explanation:@"could not make foo"
                              consequence:nil];
  GHTestLog(@"explanation = %@", actual);
  NSString *expected = @"could not make foo for these reasons:\n(\n    foo\n)";
  GHAssertEqualStrings(actual, expected, nil);
}

- (void) test_explanationWithNoConsequence {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReason:@"foo"];

  NSString *actual = [reasons explanation:@"could not make foo"
                              consequence:nil];
  GHTestLog(@"explanation = %@", actual);
  NSString *expected = @"could not make foo for these reasons:\n(\n    foo\n)";
  GHAssertEqualStrings(actual, expected, nil);
}

- (void) test_explanationWithConsequence {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReason:@"foo"];
  
  NSString *actual = [reasons explanation:@"could not make foo"
                              consequence:@"nil"];
  GHTestLog(@"explanation = %@", actual);
  NSString *expected = @"could not make foo for these reasons:\n(\n    foo\n)\nreturning nil";
  GHAssertEqualStrings(actual, expected, nil);
}


//- (void) addReason:(NSString *)aReason ifNilOrEmptyString:(NSString *) aString;
- (void) test_addReasonIfNilOrEmptyString {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo" ifNilOrEmptyString:[self emptyStringOrNil]];
  GHAssertTrue([reasons hasReasons], @"should have reasons");  
}

//- (void) addReason:(NSString *)aReason ifElement:(id) aObject notInList:(id) aFirst, ... {

- (void) test_addReasonIfElementNotInList_ElementInList {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo" ifElement:@"a" notInList:@"a", @"b", @"c", nil];
  GHAssertFalse([reasons hasReasons], @"should not have reasons");
}


- (void) test_addReasonIfElementNotInList_ElementNotInList {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo" ifElement:@"q" notInList:@"a", @"b", @"c", nil];
  GHAssertTrue([reasons hasReasons], @"should have reasons");
  GHTestLog(@"explanation: %@", [reasons explanation:@"i will give a reason"]);
}

- (void) test_addReasonIfElementNotInArray_element_in_list {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo" 
                      ifElement:@"a"
                     notInArray:@[@"a", @"b", @"c"]];
  GHAssertFalse([reasons hasReasons], @"should not have reasons");
}

- (void) test_addReasonIfElementNotInArray_element_not_in_list {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo" 
                      ifElement:@"q"
                     notInArray:@[@"a", @"b", @"c"]];
  GHAssertTrue([reasons hasReasons], @"should have reasons");  
}

- (void) test_addReasonIfElementInList_elementInList {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo"
                      ifElement:@"a"
                         inList:@"a", @"b", @"c", nil];
  GHAssertTrue([reasons hasReasons], @"should have reasons");  
}

- (void) test_addReasonIfElementInList_elementNotInList {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo"
                      ifElement:@"q"
                         inList:@"a", @"b", @"c", nil];
  GHAssertFalse([reasons hasReasons], @"should not have reasons");
}

- (void) test_addReasonIfElementInArray_elementInArray {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo"
                      ifElement:@"a"
                        inArray:@[@"a", @"b", @"c"]];
  GHAssertTrue([reasons hasReasons], @"should have reasons");  
}

- (void) test_addReasonIfElementInArray_elementNotInArray {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"foo"
                      ifElement:@"q"
                        inArray:@[@"a", @"b", @"c"]];
  GHAssertFalse([reasons hasReasons], @"should not have reasons");  
}

- (void) test_addReasonIfSelectorIsNil {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"selector"
                  ifNilSelector:nil];
  GHAssertTrue([reasons hasReasons], @"should have reasons");  
}


- (void) test_addReasonIfSelectorIsNotNil {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"selector"
                  ifNilSelector:@selector(dummySelector)];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if selector is non-nil");
}

- (void) test_addReasonIfIntegerIsOnRange_on_range {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"integer" ifInteger:1 isNotOnInterval:LjsMakeIntegerInterval(0, 2)];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if integer is on interval");
}

- (void) test_addReasonIfIntegerIsOnRange_on_lhs {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"integer" ifInteger:0 isNotOnInterval:LjsMakeIntegerInterval(0, 2)];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if integer is on interval");
}

- (void) test_addReasonIfIntegerIsOnRange_on_rhs {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"integer" ifInteger:2 isNotOnInterval:LjsMakeIntegerInterval(0, 2)];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if integer is on interval");
}

- (void) test_addReasonIfIntegerIsOnRange_lt_lhs {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"integer" ifInteger:5 isNotOnInterval:LjsMakeIntegerInterval(6, 10)];
  GHAssertTrue([reasons hasReasons], @"should have reasons if integer is not on interval");
}

- (void) test_addReasonIfIntegerIsOnRange_gt_rhs {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"integer" ifInteger:3 isNotOnInterval:LjsMakeIntegerInterval(0, 2)];
  GHAssertTrue([reasons hasReasons], @"should have reasons if integer is not on interval");
}

#pragma mark - Empty String Testing

- (void) test_addReasonIfEmptyString_nil {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"string" ifEmptyString:nil];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if the string is nil");
  
  reasons = [LjsReasons new];
  [reasons ifEmptyString:nil addReasonWithVarName:@"string"];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if the string is nil");

}

- (void) test_addReasonIfEmptyString_not_empty {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"string" ifEmptyString:@"foo"];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if the string is not empty");
  
  reasons = [LjsReasons new];
  [reasons ifEmptyString:@"foo" addReasonWithVarName:@"string"];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if the string is not empty");
}

- (void) test_addReasonIfEmptyString_empty {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"string" ifEmptyString:@""];
  GHAssertTrue([reasons hasReasons], @"should have reasons if the string is empty");
  
  reasons = [LjsReasons new];
  [reasons ifEmptyString:@"" addReasonWithVarName:@"string"];
  GHAssertTrue([reasons hasReasons], @"should have reasons if the string is empty");
}

#pragma mark - Empty or Nil String Testing

- (void) test_if_empty_or_nil_string_nil_or_empty {
  LjsReasons *reasons = [LjsReasons new];
  [reasons ifNilOrEmptyString:[self emptyStringOrNil] addReasonWithVarName:@"string"];
  GHAssertTrue([reasons hasReasons], @"should have reasons if the string is nil or empty");
}

- (void) test_if_empty_or_nil_string_not_nil_not_empty {
  LjsReasons *reasons = [LjsReasons new];
  [reasons ifNilOrEmptyString:@"foo" addReasonWithVarName:@"string"];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if the string is not empty or nil");
}

#pragma mark - Interval Testing

- (void) test_add_reason_if_not_on_interval_or_equal_to_value_not_on_lhs {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"integer"
                      ifInteger:5
                isNotOnInterval:LjsMakeIntegerInterval(6, 10)
                      orEqualTo:NSNotFound];
  GHAssertTrue([reasons hasReasons], @"should have reasons if integer is not on interval or equal to outlier");
}

- (void) test_add_reason_if_not_on_interval_or_equal_to_value_not_on_rhs {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"integer"
                      ifInteger:3
                isNotOnInterval:LjsMakeIntegerInterval(0, 2)
                      orEqualTo:NSNotFound];
  GHAssertTrue([reasons hasReasons], @"should have reasons if integer is not on interval or equal to outlier");
}

- (void) test_add_reason_if_not_on_interval_or_equal_to_value_on_interval_equal_outlier {
  LjsReasons *reasons = [LjsReasons new];
  [reasons addReasonWithVarName:@"integer"
                      ifInteger:NSNotFound
                isNotOnInterval:LjsMakeIntegerInterval(0, 2)
                      orEqualTo:NSNotFound];
  GHAssertFalse([reasons hasReasons], @"should not have reasons if integer is not on interval, but equal to outlier");
}

#pragma mark - Array Testing 
- (void) test_if_empty_array_empty {
  LjsReasons *reasons = [LjsReasons new];
  [reasons ifEmptyArray:@[] addReasonWithVarName:@"array"];
  GHAssertTrue([reasons hasReasons], @"should have reason if array is empty");
}


- (void) test_if_empty_array_nil_array {
  LjsReasons *reasons = [LjsReasons new];
  [reasons ifEmptyArray:nil addReasonWithVarName:@"array"];
  GHAssertTrue([reasons hasReasons], @"should have reason if array is nil");
}

- (void) test_if_empty_array_not_empty {
  LjsReasons *reasons = [LjsReasons new];
  [reasons ifEmptyArray:[self arrayOfAbcStrings] addReasonWithVarName:@"array"];
  GHAssertFalse([reasons hasReasons], @"should not have reason if array is not empty");
}

@end
