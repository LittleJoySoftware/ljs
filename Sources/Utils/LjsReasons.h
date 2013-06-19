// Copyright 2011 The Little Joy Software Company. All rights reserved.
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
#import <Foundation/Foundation.h>

typedef struct _LjsIntegerInterval {
  NSInteger min;
  NSInteger max;
} LjsIntegerInterval;

extern LjsIntegerInterval const LjsIntegerInterval_Invalid;

NS_INLINE LjsIntegerInterval LjsMakeIntegerInterval(NSInteger min, NSInteger max) {
  if (min > max) { return LjsIntegerInterval_Invalid; }
  LjsIntegerInterval interval;
  interval.min = min;
  interval.max = max;
  return interval;
}


@interface LjsReasons : NSObject

/**
 @return true iff checkString is valid email address
 Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
 @param checkString the string to check
 */
+ (BOOL) isValidEmail:(NSString *)checkString;

+ (BOOL) isFloat:(CGFloat) aFloat
   onIntervalMin:(CGFloat) aMin
             max:(CGFloat) aMax;

#if TARGET_OS_IPHONE
+ (BOOL) isZeroRect:(CGRect) aRect;
#endif



- (BOOL) hasReasons;
- (void) addReason:(NSString *) aReason;
- (void) addReasonWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (void) addReasonWithVarName:(NSString *)aVarName ifNil:(id) aObject;
- (void) ifNil:(id) aObject addReasonWithVarName:(NSString *) aVarName;

- (void) addReasonWithVarName:(NSString *)aVarName ifEmptyString:(NSString *) aString;
- (void) ifEmptyString:(NSString *) aString addReasonWithVarName:(NSString *) aVarName;

- (void) addReasonWithVarName:(NSString *)aVarName ifNilOrEmptyString:(NSString *) aString;
- (void) ifNilOrEmptyString:(NSString *) aString addReasonWithVarName:(NSString *) aVarName;

- (void) ifEmptyArray:(NSArray *) aArray addReasonWithVarName:(NSString *) aVarName;
- (void) ifCollection:(id) aCollection
     doesNotHaveCount:(NSUInteger) aCount
 addReasonWithVarName:(NSString *) aVarName;


- (void) addReasonWithVarName:(NSString *)aVarName ifElement:(id) aObject notInList:(id) aFirst, ...NS_REQUIRES_NIL_TERMINATION;
- (void) addReasonWithVarName:(NSString *)aVarName ifElement:(id) aObject notInArray:(NSArray *) aArray;
- (void) addReasonWithVarName:(NSString *)aVarName ifElement:(id)aObject inList:(id) aFirst, ...NS_REQUIRES_NIL_TERMINATION;
- (void) addReasonWithVarName:(NSString *)aVarName ifElement:(id) aObject inArray:(NSArray *) aArray;

- (void) ifObject:(id) aObject inCollection:(id) aCollection addReasonWithVarName:(NSString *) aVarName;

- (void) addReasonWithVarName:(NSString *)aVarName ifNilSelector:(SEL) aSel;

- (void) addReasonWithVarName:(NSString *)aVarName
                    ifInteger:(NSInteger) aValue
              isNotOnInterval:(LjsIntegerInterval) aInterval;

- (void) addReasonWithVarName:(NSString *)aVarName
                    ifInteger:(NSInteger) aValue
              isNotOnInterval:(LjsIntegerInterval) aRange
                    orEqualTo:(NSInteger) aOutOfRangeValue;


- (NSString *) explanation:(NSString *) aExplanation;
- (NSString *) explanation:(NSString *) aExplanation
           consequence:(NSString *) aConsequence;

@end
