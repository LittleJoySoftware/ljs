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
#import "LjsCategories.h"
#import "LjsBlocks.h"

@interface NSDictionaryLjsAdditionsTests : LjsTestCase {}
- (id) randomCollection;
@end

@implementation NSDictionaryLjsAdditionsTests


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

- (void) test_emptyp_with_empty_dictionary {
  BOOL actual = [[NSDictionary dictionary] has_objects];
  GHAssertFalse(actual, @"empty dictionary should be emptyp");
  actual = [[NSDictionary dictionary] not_empty];
  GHAssertFalse(actual, @"empty dictionary should be emptyp");
}

- (void) test_emptyp_with_empty_dictionary_mutable {
  BOOL actual = [[NSMutableDictionary dictionary] has_objects];
  GHAssertFalse(actual, @"empty dictionary should be emptyp");
  actual = [[NSMutableDictionary dictionary] not_empty];
  GHAssertFalse(actual, @"empty dictionary should be emptyp");

}


- (void) test_emptyp_with_non_empty_dict {
  BOOL actual = [[NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"] has_objects];
  GHAssertTrue(actual, @"non-empty dictionaries should not be emptyp");
  actual = [[NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"] not_empty];
  GHAssertTrue(actual, @"non-empty dictionaries should not be emptyp");

}

- (void) test_emptyp_with_non_empty_dict_mutable {
  BOOL actual = [[NSMutableDictionary dictionaryWithObject:@"foo" forKey:@"bar"] has_objects];
  GHAssertTrue(actual, @"non-empty dictionaries should not be emptyp");
  actual = [[NSMutableDictionary dictionaryWithObject:@"foo" forKey:@"bar"] not_empty];
  GHAssertTrue(actual, @"non-empty dictionaries should not be emptyp");
}

- (void) test_keySet_with_empty_dict {
  NSSet *set = [[NSDictionary dictionary] keySet];
  GHAssertNotNil(set, @"set should not be nil");
  GHAssertTrue([set count] == 0, @"set should contain no elements");
}

- (void) test_keySet_with_empty_mutable_dict {
  NSSet *set = [[NSMutableDictionary dictionary] keySet];
  GHAssertNotNil(set, @"set should not be nil");
  GHAssertTrue([set count] == 0, @"set should contain no elements");
}

- (void) test_keySet_with_non_empty_dict {
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"1", @"a",
                        @"2", @"b",
                        @"3", @"c", nil];
  NSSet *set = [dict keySet];
  GHAssertTrue([set containsObject:@"a"], @"set should contain a");
  GHAssertTrue([set containsObject:@"b"], @"set should contain b");
  GHAssertTrue([set containsObject:@"c"], @"set should contain c");
  GHAssertTrue([set count] == 3, @"set should contain 3 objects");
}

- (void) test_keySet_with_non_empty_mutable_dict {
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               @"1", @"a",
                               @"2", @"b",
                               @"3", @"c", nil];
  NSSet *set = [dict keySet];
  GHAssertTrue([set containsObject:@"a"], @"set should contain a");
  GHAssertTrue([set containsObject:@"b"], @"set should contain b");
  GHAssertTrue([set containsObject:@"c"], @"set should contain c");
  GHAssertTrue([set count] == 3, @"set should contain 3 objects");
}

- (void) test_maphash {
  NSDictionary *actual = [self dictionaryOfMutableStrings];
  [actual maphash:^(NSString *key, NSMutableString *val, BOOL *stop) {
    [val setString:[val uppercaseString]];
  }];
  NSSet *expected = [NSSet setWithObjects:@"A", @"B", @"C", nil];
  GHAssertTrue([[NSSet setWithArray:[actual allValues]] isEqualToSet:expected], 
               @"after maphash, all strings should be upcased");
}

- (void) test_maphash_concurrent {
  NSDictionary *actual = [self dictionaryOfMutableStrings];
  [actual maphash:^(NSString *key, NSMutableString *val, BOOL *stop) {
    [val setString:[val uppercaseString]];
  }
       concurrent:YES];
  NSSet *expected = [NSSet setWithObjects:@"A", @"B", @"C", nil];
  GHAssertTrue([[NSSet setWithArray:[actual allValues]] isEqualToSet:expected], 
               @"after maphash, all strings should be upcased");
}

- (void) test_mapcar {
  NSArray *actual =  [[self dictionaryOfMutableStrings] mapcar:^id(id key, id val) {
    return [val uppercaseString];
  }];
  NSSet *expected = [NSSet setWithObjects:@"A", @"B", @"C", nil];
  GHAssertTrue([[NSSet setWithArray:actual] isEqualToSet:expected], 
               @"mapcar should return an array of upcased strings");
}

#pragma mark - contains keys

- (void) test_nil_dictionary_contains_keys {
  NSDictionary *dict = nil;
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertFalse([dict containsKeys:[wself arrayOfAbcStrings]], @"nil dictionary should never contain keys");
  });
}

- (void) test_dictionary_contains_keys_yes {
  NSDictionary *dict = @{@"a" : @"0",
                         @"b" : @"1",
                         @"c" : @"2",
                         @"d" : @"3",
                         @"e" : @"4"};

  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertTrue([dict containsKeys:[wself arrayOfAbcStrings]], @"dictionary should contain all keys");
  });
}


- (void) test_dictionary_contains_keys_no {
  NSDictionary *dict = @{@"0" : @"a",
                         @"1" : @"b",
                         @"2" : @"c",
                         @"a" : @"0",
                         @"b" : @"1"};
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertFalse([dict containsKeys:[wself arrayOfAbcStrings]], @"dictionary does not contain all keys");
  });
}


- (void) test_dictionary_contains_keys_allows_others_yes {
  NSDictionary *dict = @{@"a" : @"0",
                         @"b" : @"1",
                         @"c" : @"2",
                         @"d" : @"3",
                         @"e" : @"4"};
  
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertTrue([dict containsKeys:[wself arrayOfAbcStrings] allowsOthers:YES], @"dictionary should contain all keys and allow others");
  });
}

- (void) test_dictionary_contains_keys_allows_others_no {
  NSDictionary *dict = @{@"a" : @"0",
                         @"b" : @"1",
                         @"c" : @"2",
                         @"d" : @"3",
                         @"e" : @"4"};
  
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    GHAssertFalse([dict containsKeys:[wself arrayOfAbcStrings] allowsOthers:NO], @"dictionary should contain all keys and _not_ allow others");
  });
}

- (void) test_dictionary_contains_keys_key_not_a_collection {
  NSDictionary *dict = @{@"a" : @"0",
                         @"b" : @"1",
                         @"c" : @"2",
                         @"d" : @"3",
                         @"e" : @"4"};
  
  __weak typeof(self) wself = self;
  dotimes(5, ^{
    id keys = [wself flip] ? [wself emptyStringOrNil] : @(5);
    GHAssertFalse([dict containsKeys:keys allowsOthers:NO], @"dictionary should contain all keys and _not_ allow others");
  });
}



@end
