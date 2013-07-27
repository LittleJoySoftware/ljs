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

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LjsReasons.h"
#import "Lumberjack.h"
#import "LjsCategories.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

LjsIntegerInterval const LjsIntegerInterval_Invalid = {NSIntegerMax, NSIntegerMin};


MapcLjsIntegerIntervalBlock mapc_integer_interval = ^(LjsIntegerInterval aInterval, void(^block)(NSInteger)) {
  NSInteger stop = aInterval.max;
  for (NSInteger index = aInterval.min; index <= stop; index++) {
    block(index);
  }
};

@interface LjsReasons ()

@property (nonatomic, strong) NSMutableArray *reasons;

@end

@implementation LjsReasons

+ (BOOL) isValidEmail:(NSString *)checkString {
  BOOL stricterFilter = YES;
  NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
  NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
  NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
  NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
  return [emailTest evaluateWithObject:checkString];
}

+ (BOOL) isFloat:(CGFloat) aFloat
   onIntervalMin:(CGFloat) aMin
             max:(CGFloat) aMax {
  return ((aFloat >= aMin) && (aFloat <= aMax));
}

#if TARGET_OS_IPHONE
+ (BOOL) isZeroRect:(CGRect) aRect {
  NSString *str = NSStringFromCGRect(aRect);
  NSString *zero = NSStringFromCGRect(CGRectZero);
  return [str isEqualToString:zero];
}
#endif


- (id) init {
  self = [super init];
  if (self) {
    self.reasons = [NSMutableArray array];
  }
  return self;
}

- (BOOL) hasReasons {
  return [self.reasons not_empty];
}

- (void) addReason:(NSString *)aReason {
  if ([aReason has_chars] == NO) {
    DDLogWarn(@"declining to add reason < %@ > - reasons must be non-nil and non-empty", aReason);
    return;
  }
  [self.reasons nappend:aReason];
}

- (void) addReasonWithFormat:(NSString *) aFormat, ... NS_FORMAT_FUNCTION(1,2) {
  va_list ap;
	id ret;
	va_start(ap,  aFormat);
	ret = [[NSString alloc] initWithFormat: aFormat arguments:ap];
	va_end(ap);
	[self addReason:ret];
}


- (void) addReasonWithVarName:(NSString *)aVarName ifNil:(id) aObject {
  if (aObject == nil) {
    NSString *reason = [NSString stringWithFormat:@"%@ cannot be nil", aVarName];
    [self addReason:reason];
  }
}

- (void) ifNil:(id) aObject addReasonWithVarName:(NSString *) aVarName {
  [self addReasonWithVarName:aVarName ifNil:aObject];
}

- (void) addReasonWithVarName:(NSString *)aVarName ifNilSelector:(SEL) aSel {
  NSString *selStr = NSStringFromSelector(aSel);
  [self addReasonWithVarName:aVarName ifNil:selStr];
}

- (void) addReasonWithVarName:(NSString *)aVarName ifNilOrEmptyString:(NSString *) aString {
  if ([aString has_chars] == NO) {
    NSString *reason = [NSString stringWithFormat:@"%@ cannot be nil or empty",
                        aVarName];
    [self addReason:reason];
  }
}

- (void) ifNilOrEmptyString:(NSString *) aString addReasonWithVarName:(NSString *) aVarName {
  [self addReasonWithVarName:aVarName ifNilOrEmptyString:aString];
}


- (void) addReasonWithVarName:(NSString *)aVarName ifEmptyString:(NSString *) aString {
  if (aString != nil && [aString length] == 0) {
    NSString *reason = [NSString stringWithFormat:@"%@ cannot be nil or empty",
                        aVarName];
    [self addReason:reason];
  }
}

- (void) ifEmptyString:(NSString *) aString addReasonWithVarName:(NSString *) aVarName {
  [self addReasonWithVarName:aString ifEmptyString:aString];
}


- (void) ifEmptyArray:(NSArray *) aArray addReasonWithVarName:(NSString *) aVarName {
  if (aArray == nil || [aArray count] == 0) {
    NSString *reason = [NSString stringWithFormat:@"%@ cannot be empty", aVarName];
    [self addReason:reason];
  }
}


- (void) ifCollection:(id) aCollection
     doesNotHaveCount:(NSUInteger) aCount
 addReasonWithVarName:(NSString *) aVarName {
  if ([aCollection respondsToSelector:@selector(count)] == NO) {
    [self addReasonWithFormat:@"'%@' = '%@' is not a collection (does not respond to selector 'count')",
     aVarName, aCollection];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-selector-match"
    NSUInteger count = [aCollection count];
#pragma clang diagnostic pop
    if (count != aCount) {

      [self addReasonWithFormat:@"expected '%@' to have count '%lu' but found '%lu'",
       aVarName, (unsigned long)aCount, (unsigned long)count];
    }
  }
}


- (void) addReasonWithVarName:(NSString *)aVarName ifElement:(id) aObject notInList:(id) aFirst, ... {
  NSMutableArray *array = [NSMutableArray array];
  va_list args;
  va_start(args, aFirst);
  for (id arg = aFirst; arg != nil; arg = va_arg(args, id)) {
    [array nappend:arg];
  }
  va_end(args);
  [self addReasonWithVarName:aVarName ifElement:aObject notInArray:array];
  
}

- (void) addReasonWithVarName:(NSString *)aVarName ifElement:(id) aObject notInArray:(NSArray *) aArray {
  if ([aArray containsObject:aObject] == NO) {
    NSString *set = [aArray componentsJoinedByString:@" | "];
    set = [NSString stringWithFormat:@"{%@}", set];
    NSString *reason = [NSString stringWithFormat:@"%@ < %@ > is not in: %@",
                        aVarName, aObject, set];
    [self addReason:reason];
  }
}

- (void) addReasonWithVarName:(NSString *)aVarName ifElement:(id)aObject inList:(id) aFirst, ... {
  NSMutableArray *array = [NSMutableArray array];
  va_list args;
  va_start(args, aFirst);
  for (id arg = aFirst; arg != nil; arg = va_arg(args, id)) {
    [array nappend:arg];
  }
  va_end(args);
  [self addReasonWithVarName:aVarName ifElement:aObject inArray:array];
}

- (void) addReasonWithVarName:(NSString *)aVarName ifElement:(id) aObject inArray:(NSArray *) aArray {
  if ([aArray containsObject:aObject]) {
    NSString *set = [aArray componentsJoinedByString:@" | "];
    set = [NSString stringWithFormat:@"{%@}", set];
    NSString *reason = [NSString stringWithFormat:@"%@ < %@ > is in: %@",
                        aVarName, aObject, set];
    [self addReason:reason];
  }
}

- (void) ifObject:(id) aObject inCollection:(id) aCollection addReasonWithVarName:(NSString *) aVarName {
  if (aCollection == nil) {
    [self addReasonWithFormat:@"collection is nil so we cannot search '%@' in it", aCollection];
    return;
  }
  
  id lookFor = aObject == nil ? [NSNull null] : aObject;
  if ([aCollection respondsToSelector:@selector(containsObject:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-selector-match"
    BOOL contains = [aCollection containsObject:lookFor];
#pragma clang diagnostic pop
    if (contains == YES) {
      [self addReasonWithFormat:@"expected '%@': '%@' to _not_ be in collection '%@'",
       aVarName, aObject, aCollection];
    }
  }
}

- (void) addReasonWithVarName:(NSString *)aVarName ifInteger:(NSInteger) aValue isNotOnInterval:(LjsIntegerInterval) aRange {
  NSInteger min = aRange.min;
  NSInteger max = aRange.max;
  if (aValue < min || aValue > max) {
    NSString *reason = [NSString stringWithFormat:@"< %ld > is not on (%ld, %ld)",
                        (long)aValue, (long)min, (long)max];
    [self addReason:reason];
  }
}


- (void) addReasonWithVarName:(NSString *)aVarName
                    ifInteger:(NSInteger) aValue
              isNotOnInterval:(LjsIntegerInterval) aRange
                    orEqualTo:(NSInteger) aOutOfRangeValue {
  NSInteger min = aRange.min;
  NSInteger max = aRange.max;
  if ((aValue < min || aValue > max) && aValue != aOutOfRangeValue) {
    NSString *reason = [NSString stringWithFormat:@"< %ld > is not on (%ld, %ld) or equal to %ld",
                        (long)aValue, (long)min, (long)max, (long)aOutOfRangeValue];
    [self addReason:reason];
  }
}


- (NSString *) explanation:(NSString *) aExplanation {
  return [NSString stringWithFormat:@"%@ for these reasons:\n%@",
          aExplanation, self.reasons];
}

- (NSString *) explanation:(NSString *) aExplanation
           consequence:(NSString *) aConsequence {
  NSString *result = [self explanation:aExplanation];
  if ([aConsequence has_chars]) {
    result = [result stringByAppendingFormat:@"\nreturning %@", aConsequence];
  } 
  return result;
}




@end
