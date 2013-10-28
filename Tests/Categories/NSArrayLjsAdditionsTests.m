// Copyright 2012 Little Joy Software. All rights reserved.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Neither the name of the Little Joy Software nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY LITTLE JOY SOFTWARE ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LITTLE JOY SOFTWARE BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LjsTestCase.h"
#import "NSArray+LjsAdditions.h"
#import "LjsBlocks.h"

@interface NSArrayLjsAdditionsTests : LjsTestCase {}

- (id) randomCollection;

@end

@implementation NSArrayLjsAdditionsTests

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


#pragma mark - helpers

- (id) randomCollection {
  NSUInteger rand = [LjsVariates randomIntegerWithMin:0 max:2];
  switch (rand) {
    case 0: return [self arrayOfAbcStrings];
    case 1: return [self setOfAbcStrings];
    case 2: return [NSOrderedSet orderedSetWithArray:[self arrayOfAbcStrings]];
    default:
      GHFail(@"should never get here");
      return nil;
  }
}


#pragma mark - tests


- (void) test_nth {
  NSArray *array;
  NSUInteger index;
  id actual;
  id expected;
  
  array = nil;
  index = 0;
  actual = [array nth:index];
  GHAssertNil(actual, nil);
  
  array = [NSArray array];
  index = 0;
  actual = [array nth:index];
  GHAssertNil(actual, nil);
  
  expected = @"foo";
  array = [NSArray arrayWithObject:expected];
  index = 0;
  actual = [array nth:index];
  GHAssertEqualObjects(actual, expected, nil);
  
  expected = @"foo";
  array = [NSArray arrayWithObjects:@"bar", expected, @"ble", nil];
  index = 1;
  actual = [array nth:index];
  GHAssertEqualObjects(actual, expected, nil);
  
  expected = @"foo";
  array = [NSArray arrayWithObjects:@"bar", @"ble", expected, nil];
  index = 2;
  actual = [array nth:index];
  GHAssertEqualObjects(actual, expected, nil);
  
  expected = nil;
  array = [NSArray arrayWithObjects:@"bar", @"ble", nil];
  index = 2;
  actual = [array nth:index];
  GHAssertEqualObjects(actual, expected, nil);
  GHAssertNil(actual, nil);
}


- (void) test_s_nth {
  NSArray *array = [self arrayOfAbcStrings];
  NSInteger index = -1;
  GHAssertNil([array s_nth:index], @"should return nil if index < 0");
  GHAssertEqualStrings([array s_nth:0], [array first], @"should return nth if index is > -1");
}

- (void) test_rest {
  NSArray *array;
  NSArray *actual, *expected;
  
  expected = nil;
  array = nil;
  actual = [array rest];
  GHAssertNil(actual, nil);
  
  expected = nil;
  array = [NSArray array];
  actual = [array rest];
  GHAssertNil(actual, nil);
  
  expected = nil;
  array = [NSArray arrayWithObject:@"foo"];
  actual = [array rest];
  GHAssertNil(actual, nil);
  
  
  array = [NSArray arrayWithObjects:@"first", @"foo", nil];
  actual = [array rest];
  GHAssertEqualStrings([actual first], @"foo", nil);
}

- (void) test_reverse {
  NSArray *array;
  NSArray *actual, *expected;
  NSUInteger actualCount, expectedCount;
  
  array = nil;
  actual = [array reverse];
  GHAssertNil(actual, nil);
  
  array = [NSArray array];
  actual = [array reverse];
  actualCount = [actual count];
  expectedCount = 0;
  GHAssertEquals((NSUInteger) actualCount, (NSUInteger) expectedCount, nil);
  
  array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  expected = [NSArray arrayWithObjects:@"c", @"b", @"a", nil];
  expectedCount = [expected count];
  actual = [array reverse];
  actualCount = [actual count];
  GHAssertEquals((NSUInteger) actualCount, (NSUInteger) expectedCount, nil);
  for (NSUInteger index; index < actualCount; index++) {
    GHAssertEqualStrings([actual nth:index], [expected nth:index], nil);
  }
}

#pragma mark - append

- (void) test_append_mutable_array_fails {
  NSMutableArray *ma = [NSMutableArray array];
  GHAssertThrows([ma append:@"a"], @"should throw does not respond to selector");
}

- (void) test_append_to_nil {
  id object = nil;
  NSArray *array = nil;
  NSArray *actual = [array append:object];
  GHAssertNil(actual, nil);
}

- (void) test_append_nil_obj {
  id object = nil;
  NSArray *array = [NSArray array];
  NSArray *actual = [array append:object];
  GHAssertFalse([actual has_objects], @"should have not objects: %@", array);
}

- (void) test_append_obj {
  id object = @"d";
  NSArray *array = [self arrayOfAbcStrings];
  NSArray *actual = [array append:object];
  GHAssertEquals((int)[actual count], (int)4, @"should have the correct count");
  GHAssertEqualStrings([actual nth:3], object, nil);
}

- (void) test_append_array {
  id object = [self arrayOfAbcStrings];
  NSArray *array = [self arrayOfAbcStrings];
  NSArray *actual = [array append:object];
  NSArray *expected = @[@"a", @"b", @"c", @"a", @"b", @"c"];
  [self compareArray:actual toArray:expected asStrings:YES];
}

#pragma mark - not_empty and has_objects

- (void) test_has_objects_false {
  NSArray *array = [NSArray array];
  GHAssertFalse([array has_objects], @"should not have objects: '%@'", array);
  NSMutableArray *marray = [NSMutableArray array];
  GHAssertFalse([marray has_objects], @"should not have objects: '%@'", marray);
  NSArray *nil_array = nil;
  GHAssertFalse([nil_array has_objects], @"should not have objects:'%@'", nil_array);
}

- (void) test_not_empty_false {
  NSArray *array = [NSArray array];
  GHAssertFalse([array not_empty], @"should not have objects: '%@'", array);
  NSMutableArray *marray = [NSMutableArray array];
  GHAssertFalse([marray not_empty], @"should not have objects: '%@'", marray);
  NSArray *nil_array = nil;
  GHAssertFalse([nil_array not_empty], @"should not have objects:'%@'", nil_array);
}

- (void) test_has_objects_true {
  NSArray *array = @[@"a"];
  GHAssertTrue([array has_objects], @"should have objects: '%@'", array);
  NSMutableArray *marray = [NSMutableArray arrayWithArray:array];
  GHAssertTrue([marray has_objects], @"should have objects: '%@'", marray);
}

- (void) test_not_empty_true {
  NSArray *array = @[@"a"];
  GHAssertTrue([array not_empty], @"should have objects: '%@'", array);
  NSMutableArray *marray = [NSMutableArray arrayWithArray:array];
  GHAssertTrue([marray not_empty], @"should have objects: '%@'", marray);
}

#pragma mark - Mapping

- (void) test_mapcar {
  NSArray *array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  NSArray *upcased = [array mapcar:^(id obj) {
    return [obj uppercaseString];
  }];
  NSOrderedSet *expected = [NSOrderedSet orderedSetWithArray:@[@"A", @"B", @"C"]];
  NSOrderedSet *actual = [NSOrderedSet orderedSetWithArray:upcased];
  GHAssertTrue([actual isEqualToOrderedSet:expected], @"upcased should contain all uppercase strings");
}


/*
 - (NSArray *) mapc:(void (^)(id obj)) aBlock;
 // the threshold for useful concurrency is 10,000 and 50,000 objects
 //http://darkdust.net/writings/objective-c/nsarray-enumeration-performance#The_graphs
 - (NSArray *) mapc:(void (^)(id obj)) aBlock concurrent:(BOOL) aConcurrent;

*/

- (void) test_mapc {
  NSArray *array = [self arrayOfMutableStrings];
  NSArray *upcased = [array mapc:^(NSMutableString *obj, NSUInteger idx, BOOL *stop) {
    [obj setString:[obj uppercaseString]];
  }];
  GHAssertEqualObjects(array, upcased, @"array returned by mapc should be the same object as the target");
  NSOrderedSet *expected = [NSOrderedSet orderedSetWithArray:@[@"A", @"B", @"C"]];
  NSOrderedSet *actual = [NSOrderedSet orderedSetWithArray:upcased];
  GHAssertTrue([actual isEqualToOrderedSet:expected], @"upcased should contain all uppercase strings");
}

- (void) test_mapc_using_index {
  NSArray *array = [self arrayOfMutableStrings];
  NSArray *numbers = [array mapc:^(NSMutableString *obj, NSUInteger idx, BOOL *stop) {
    NSString *newStr = [NSString stringWithFormat:@"%ld", (long)idx];
    [obj setString:newStr];
  }];
  GHAssertEqualObjects(array, numbers, @"array returned by mapc should be the same object as the target");
  NSOrderedSet *expected = [NSOrderedSet orderedSetWithArray:@[@"0", @"1", @"2"]];
  NSOrderedSet *actual = [NSOrderedSet orderedSetWithArray:numbers];
  GHAssertTrue([actual isEqualToOrderedSet:expected], @"numbers should contain array of string numbers");
}

- (void) test_mapc_concurrent {
  NSArray *array = [self arrayOfMutableStrings];
  NSArray *upcased = [array mapc:^(NSMutableString *obj, NSUInteger idx, BOOL *stop) {
    [obj setString:[obj uppercaseString]];
  }
                     concurrent:YES];
  GHAssertEqualObjects(array, upcased, @"array returned by mapc should be the same object as the target");
  
  NSOrderedSet *expected = [NSOrderedSet orderedSetWithArray:@[@"A", @"B", @"C"]];
  NSOrderedSet *actual = [NSOrderedSet orderedSetWithArray:upcased];
  GHAssertTrue([actual isEqualToOrderedSet:expected], @"upcased should contain all uppercase strings");
}

- (void) test_arrayByRemovingObjectInArray_nil_array {
  NSArray *array = [NSArray arrayWithObjects:@"a", nil];
  NSArray *actual = [array arrayByRemovingObjectsInArray:nil];
  GHAssertTrue([actual count] == 1, @"array should have object");
  GHAssertTrue([actual containsObject:@"a"], @"array should contain < a >");
}

- (void) test_arrayByRemovingObjectInArray_empty_array {
  NSArray *array = [NSArray arrayWithObjects:@"a", nil];
  NSArray *actual = [array arrayByRemovingObjectsInArray:nil];
  GHAssertTrue([actual count] == 1, @"array should have object");
  GHAssertTrue([actual containsObject:@"a"], @"array should contain < a >");
}

- (void) test_arrayByRemovingObjectInArray_array_with_one_object_found {
  NSArray *array = [NSArray arrayWithObjects:@"a", nil];
  NSArray *toRemove = [NSArray arrayWithObjects:@"a", nil];
  NSArray *actual = [array arrayByRemovingObjectsInArray:toRemove];
  GHAssertFalse([actual has_objects], @"array should be emptyp");
}


- (void) test_arrayByRemovingObjectInArray_array_with_no_objects_found {
  NSArray *array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  NSArray *toRemove = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
  NSArray *actual = [array arrayByRemovingObjectsInArray:toRemove];
  NSOrderedSet *e = [NSOrderedSet orderedSetWithArray:array];
  NSOrderedSet *a = [NSOrderedSet orderedSetWithArray:actual];
  GHAssertTrue([a isEqualToOrderedSet:e], @"array should contain only the original objects");
}

- (void) test_arrayByRemovingObjectInArray_array_with_some_objects_found {
  NSArray *array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
  NSArray *toRemove = [NSArray arrayWithObjects:@"1", @"b", @"c", nil];
  NSArray *actual = [array arrayByRemovingObjectsInArray:toRemove];
  NSOrderedSet *e = [NSOrderedSet orderedSetWithArray:@[@"a"]];
  NSOrderedSet *a = [NSOrderedSet orderedSetWithArray:actual];
  GHAssertTrue([a isEqualToOrderedSet:e], @"array should contain only '%@'", @"a");
}

- (void) test_string_with_enum_empty_array {
  NSArray *array = [NSArray array];
  NSString *actual = [array stringWithEnum:0];
  GHAssertNil(actual, @"string should be nil because array is empty");
  actual = [array stringWithEnum:1];
  GHAssertNil(actual, @"string should be nil because array is empty");
}

- (void) test_string_with_enum_one_element_array {
  NSArray *array = [NSArray arrayWithObjects:@"a", nil];
  NSString *actual = [array stringWithEnum:0];
  GHAssertEqualStrings(actual, @"a", @"strings should be the same");
  actual = [array stringWithEnum:1];
  GHAssertNil(actual, @"string should be nil because 1 is out of bounds");
}

#pragma mark - validation

- (void) test_array_nil_contains_objects {
  NSArray *array = nil;
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertFalse([array containsObjects:[wself randomCollection]],
                  @"nil arrays should never contain objects");
  });
}

- (void) test_array_empty_contains_objects {
  NSArray *array = @[];
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertFalse([array containsObjects:[wself randomCollection]],
                  @"nil arrays should never contain objects");
  });
}

- (void) test_array_contains_objects_yes {
  NSArray *array = @[@"a", @"b", @"c"];
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertTrue([array containsObjects:[wself randomCollection]],
                 @"array should contain objects");
  });
}

- (void) test_array_contains_objects_no {
  NSArray *array = @[@"A", @"B"];
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertFalse([array containsObjects:[wself randomCollection]],
                 @"array should not contain objects");
  });
}


- (void) test_array_contains_objects_allows_others_no {
  NSArray *array = @[@"a", @"b", @"c"];
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertTrue([array containsObjects:[wself randomCollection] allowsOthers:NO],
                  @"array should contain objects and no others");
  });
}

- (void) test_array_contains_objects_allows_others_yes {
  NSArray *array = @[@"a", @"b", @"c", @"d"];
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertTrue([array containsObjects:[wself randomCollection] allowsOthers:YES],
                 @"array should contain objects and no others");
  });
}


- (void) test_array_contains_objects_no_allows_others {
  NSArray *array = @[@"a", @"b", @"d"];
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertFalse([array containsObjects:[wself randomCollection] allowsOthers:[wself flip]],
                 @"array should contain objects and no others");
  });
}

@end
