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

#import "Lumberjack.h"
#import "NSCalendar+LjsAdditions.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int __unused ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int __unused ddLogLevel = LOG_LEVEL_WARN;
#endif



NSString *LjsHoursMinutesSecondsDateFormat = @"H:mm:ss";
NSString *LjsHoursMinutesSecondsMillisDateFormat = @"H:mm:ss:SSS";
NSString *LjsISO8601_DateFormatWithMillis = @"yyyy-MM-dd HH:mm:ss.SSS";

NSString *LjsISO8601_DateFormat = @"yyyy-MM-dd HH:mm:ss";
NSString *LjsOrderedDateFormat = @"yyyy_MM_dd_HH_mm";
NSString *LjsOrderedDateFormatWithMillis = @"yyyy_MM_dd_HH_mm_SSS";

@implementation NSDateFormatter (NSDateFormatter_LjsAdditions)

+ (NSDateFormatter *) formatterWithFormatString:(NSString *) aFormatString {
  NSDateFormatter *result = [[NSDateFormatter alloc]
                             init];
  [result setDateFormat:aFormatString];
  return result;
}


#pragma mark - common date formatters

/**
 @return a date formatter for `H:mm a` format
 */
+ (NSDateFormatter *) hoursMinutesAmPmFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  
  [formatter setDateFormat:@"H:mm a"];
  return formatter;
}

/**
 @return a date formatter for `ccc MMM d HH:mm a` or Wed Sep 7 1:30 PM
 */
+ (NSDateFormatter *) briefDateAndTimeFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"ccc MMM d HH:mm a"];
  return formatter;
}

/**
 @return a date formatter for `H:mm:ss`
 */
+ (NSDateFormatter *) hoursMinutesSecondsDateFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:LjsHoursMinutesSecondsDateFormat];
  return formatter;
}

/**
 @return a date formatter for `H:mm:ss:SSS`
 */
+ (NSDateFormatter *) millisecondsFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:LjsHoursMinutesSecondsMillisDateFormat];
  return formatter;
}

/**
 @return a date formatter for `yyyy-MM-dd HH:mm:ss`
 */
+ (NSDateFormatter *) isoDateFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:LjsISO8601_DateFormat];
  return formatter;
}

/**
 @return a date formatter for `yyyy-MM-dd HH:mm:ss.SSS`
 */
+ (NSDateFormatter *) isoDateWithMillisFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:LjsISO8601_DateFormatWithMillis];
  return formatter;
}

+ (NSDateFormatter *) isoDateWithMillisAnd_GMT_Formatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:LjsISO8601_DateFormatWithMillis];
  NSCalendar *calendar = [NSCalendar gregorianCalendar];
  NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
  calendar.timeZone = tz;
  formatter.calendar = calendar;
  formatter.timeZone = tz;
  return formatter;
}

/**
 @return a date formatter for `yyyy_MM_dd_HH_mm`
 */
+ (NSDateFormatter *) orderedDateFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:LjsOrderedDateFormat];
  return formatter;
}

/**
 @return a date formatter for `yyyy_MM_dd_HH_mm.SSS`
 */
+ (NSDateFormatter *) orderedDateFormatterWithMillis {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:LjsOrderedDateFormatWithMillis];
  return formatter;
}



@end
