// Copyright (c) 2010 Little Joy Software
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

#import "LjsVariates.h"
#import "Lumberjack.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif


static const NSString *_alphanumeric = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
static const NSUInteger _max_index = 26 + 26 + 10 - 1;

static const float ARC4RANDOM_MAX = 0x100000000;
static double const LjsE = 2.71828;

@implementation LjsVariates

+ (NSUInteger) factorial:(NSUInteger) n {
  return [LjsVariates _factorialHelperWithN:n accumulator:1];
}

+ (NSUInteger) _factorialHelperWithN:(NSUInteger) n
                         accumulator:(NSUInteger) accumulator {
  return n < 1 ? accumulator : [LjsVariates _factorialHelperWithN:n - 1 accumulator:accumulator * n];
}


+ (BOOL) flip {
  return (BOOL)[LjsVariates randomIntegerWithMin:0 max:1];
}

+ (BOOL) flipWithProbilityOfYes:(double) aProbability {
  return [LjsVariates randomDoubleWithMin:0.0 max:1.0] <= aProbability;
}



/*
 e is the base of the natural logarithm (e = 2.71828...)
 k is the number of occurrences of an event — the probability of which is given by the function
 k! is the factorial of k
 λ is a positive real number, equal to the expected number of occurrences during the given interval. For instance, if the events occur on average 4 times per minute, and one is interested in the probability of an event occurring k times in a 10 minute interval, one would use a Poisson distribution as the model with λ = 10×4 = 40.
 As a function of k, this is the probability mass function. The Poisson distribution can be derived as a limiting case of the binomial distribution.
 */

+ (double) possionWithK:(NSUInteger) aK
                 lambda:(double) aLambda {
  NSUInteger denomiator = [LjsVariates factorial:aK];
  double lambdaToK = pow(aLambda, aK);
  double eToNegLambda = pow(LjsE, -1.0 * aLambda);
  double numerator = lambdaToK * eToNegLambda;
  return (numerator/denomiator) * 1.0;
}



+ (double) randomDouble {
  return (double) arc4random() / ARC4RANDOM_MAX;
}

+ (NSDecimalNumber *) randomDecimalDouble {
  double random = [LjsVariates randomDouble];
  return [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:random] decimalValue]];
}

+ (double) randomDoubleWithMin:(double) min max:(double) max {
  double result;
  if (max <= min) {
    result = max;
  } else {
    
    result = ((max - min) * [LjsVariates randomDouble]) + min;
  }
  return result;
}


+ (NSDecimalNumber *) randomDecimalDoubleWithMin:(NSDecimalNumber *) min
                                             max:(NSDecimalNumber *) max {
  double random = [LjsVariates randomDoubleWithMin:[min doubleValue]
                                               max:[max doubleValue]];
  return [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:random] decimalValue]];
}

+ (NSUInteger) randomInteger {
  return arc4random_uniform(UINT32_MAX);
}

+ (NSDecimalNumber *) randomDecimalInteger {
  NSInteger random = (NSInteger)[LjsVariates randomInteger];
  return [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:random] decimalValue]];
}

+ (NSUInteger) _randomIntegerHelperWithMin:(NSUInteger) aMin
                                       max:(NSUInteger) aMax {
  return (NSUInteger)(((aMax - aMin + 1) * [LjsVariates randomDouble]) + aMin);
}

+ (NSUInteger) randomIntegerWithMin:(NSUInteger) min max:(NSUInteger) max {
  if (max <= min) {
    return max;
  }
  
  // avoid blowing up if the min or max is too high
  NSUInteger result;
  if (max <= min) {
    result = max;
  } else {
    result = [LjsVariates _randomIntegerHelperWithMin:min max:max];
    // sometimes the RNG algorithm produces max + 1; this is expected
    while (result > max) {
      result = [LjsVariates _randomIntegerHelperWithMin:min max:max];
    }
  }
  return result;
}

+ (NSDecimalNumber *) randomDecimalIntegerWithMin:(NSDecimalNumber *) min
                                              max:(NSDecimalNumber *) max {
  
  NSUInteger random = [LjsVariates randomIntegerWithMin:[min unsignedIntegerValue]
                                                    max:[max unsignedIntegerValue]];
  return [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithUnsignedInteger:random] decimalValue]];
}

+ (NSArray *) sampleWithReplacement:(NSArray *) array number:(NSUInteger) number {
  NSMutableArray *sampled = [NSMutableArray new];
  NSUInteger randomIndex;
  NSUInteger maxArrayIndex = [array count] - 1;
  for (NSUInteger loopVar = 0; loopVar < number; loopVar++) {
    randomIndex = [LjsVariates randomIntegerWithMin:0 max:maxArrayIndex];
    [sampled addObject:[array objectAtIndex:randomIndex]];
  }
  
  NSArray *result = [NSArray arrayWithArray:sampled];
  return result;
}

+ (NSArray *) sampleWithoutReplacement:(NSArray *) array number:(NSUInteger) number {
  NSMutableArray *sampled = [NSMutableArray arrayWithArray:array];
  NSArray *result;
  NSUInteger arraySize = [array count];
  if (arraySize < number) {
    // not possible to generate enough samples with out replacement
    result = nil;
  } else {
    NSUInteger remainingCount, index, randomIndex;
    
    for (index = 0; index < arraySize; index++) {
      remainingCount = arraySize - index;
      randomIndex = ([LjsVariates randomInteger] % remainingCount) + index;
      [sampled exchangeObjectAtIndex:index withObjectAtIndex:randomIndex];
    }
    result = [sampled subarrayWithRange:NSMakeRange(0, number)];
  }
  return result;
}

+ (id) randomElement:(NSArray *) array {
  if (array == nil || [array count] == 0) {
    return nil;
  }
  
  NSUInteger count = [array count];
  if (count == 1) {
    return [array objectAtIndex:0];
  }
  
  NSUInteger max = count - 1;
  NSUInteger index = [LjsVariates randomIntegerWithMin:0 max:max];
  return [array objectAtIndex:index];
}

+ (NSArray *) shuffle:(NSArray *) array {
  NSUInteger count = [array count];
  NSArray *shuffled = [self sampleWithoutReplacement:array number:count];
  return shuffled;
}


+ (NSString *) randomStringWithLength:(NSUInteger) length {
  
  NSString *result = @"";
  NSUInteger random;
  
  for(NSUInteger finger = 0; finger < length; finger++) {
    random = [LjsVariates randomIntegerWithMin:0 max:_max_index];
    char character = (char)[_alphanumeric characterAtIndex:random];
    result = [result stringByAppendingFormat:@"%c", character];
  }
  return result;
}


+ (NSString *) randomAsciiWithLengthMin:(NSUInteger) aMin
                              lenghtMax:(NSUInteger) aMax {
  NSUInteger count = [LjsVariates randomIntegerWithMin:aMin max:aMax];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  for (NSUInteger index = 0; index < count; index++) {
    unsigned char code = (unsigned char)[LjsVariates randomIntegerWithMin:32 max:126];
    [array addObject:[NSString stringWithFormat:@"%c", code]];
  }
  return [array componentsJoinedByString:@""];
}


+ (NSDate *) randomDateBetweenStart:(NSDate *) aStart end:(NSDate *) aEnd {
  if ([aStart compare:aEnd] != NSOrderedAscending) {
    DDLogError(@"end date must be after start date");
    DDLogError(@"start: %@", [aStart descriptionWithLocale:[NSLocale currentLocale]]);
    DDLogError(@"  end: %@", [aEnd descriptionWithLocale:[NSLocale currentLocale]]);
    DDLogError(@"returning nil");
    return nil;
  }
  
  NSTimeInterval interval = [aEnd timeIntervalSinceDate:aStart];
  NSTimeInterval secondsToAdd = [LjsVariates randomDoubleWithMin:1 max:interval];
  NSDate *date = [aStart dateByAddingTimeInterval:secondsToAdd];

  return date;
}


/**
 @return an integer on the range eg. (1, 5)
 @param aRange the range to sample
 */
+ (NSUInteger) randomIntegerWithRange:(NSRange) aRange {
  return [LjsVariates randomIntegerWithMin:aRange.location max:aRange.length];
}



@end
