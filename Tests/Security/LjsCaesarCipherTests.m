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
#import "LjsVariates.h"
#import "LjsCaesarCipher.h"
#import "NSOrderedSet+LjsAdditions.h"

@interface LjsCaesarCipherTests : LjsTestCase {}
@end

@implementation LjsCaesarCipherTests

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


- (void) test_encode_decode_with_illegal_rotation {
  NSOrderedSet *illegals = [LjsCaesarCipher illegalRotationValues];
  [illegals mapc:^(NSNumber *num, NSUInteger idx, BOOL *stop) {
    unichar rotate = [num unsignedCharValue];
    LjsCaesarCipher *cipher = [[LjsCaesarCipher alloc] initWithRotate:rotate];
    GHAssertNil(cipher, @"cipher should be nil if passed a non-transforming rotation");
  }];
}

- (void) test_encode_decode_with_random_rotation {
  for (unichar index = 0; index <= UCHAR_MAX; index++) {
    LjsCaesarCipher *cipher = [[LjsCaesarCipher alloc] initWithRotate:index];
    if (cipher != nil) {
      NSString *original = [LjsVariates randomAsciiWithLengthMin:5 lenghtMax:55];;
      NSString *encoded = [cipher stringByEncodingString:original];
      GHAssertNotEqualStrings(original, encoded, @"encoded string should not equal original rotation is: %d", index);
      NSString  *decoded = [cipher stringByDecodingString:encoded];
      GHAssertEqualStrings(original, decoded, nil);
    }
  }
}


@end
