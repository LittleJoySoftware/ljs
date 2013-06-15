#import <Foundation/Foundation.h>

/**
 NSLocale on NSLocale_LjsAdditions category.
 */
@interface NSLocale (NSLocale_LjsAdditions)

+ (NSLocale *) localeForEnglishUS;
- (BOOL) localeUses24HourClock;

+ (BOOL) currentLocaleUsesMetricSystem;

+ (NSString *) groupSepForCurrentLocale;
+ (NSString *) groupSepForLocale:(NSLocale *) aLocale;
+ (NSString *) decimalSepForCurrentLocale;
+ (NSString *) decimalSepForLocale:(NSLocale *) aLocale;

+ (NSNumberFormatter *) numberFormatterForCurrentLocale;
+ (NSNumberFormatter *) numberFormatterWithLocale:(NSLocale *) aLocale;
+ (NSNumberFormatter *) numberFormatterWithGroupingSep:(NSString *) groupingSep
                                            demicalSep:(NSString *) decimalSep;

+ (NSLocale *) localeWith12hourClock;
+ (NSLocale *) localeWith24hourClock;
+ (NSLocale *) localeWithMondayAsFirstDayOfWeek;

@end
