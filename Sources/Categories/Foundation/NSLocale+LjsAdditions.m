#import "Lumberjack.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int __unused ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int __unused ddLogLevel = LOG_LEVEL_WARN;
#endif


@implementation NSLocale (NSLocale_LjsAdditions)


+ (NSLocale *) localeForEnglishUS {
  return [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
}

- (BOOL) localeUses24HourClock {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setLocale:self];
  [formatter setDateStyle:NSDateFormatterNoStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  NSString *dateString = [formatter stringFromDate:[NSDate date]];
  NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
  NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
  BOOL is24Hour = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
  return is24Hour;
}


+ (BOOL) currentLocaleUsesMetricSystem {
  NSLocale *current = [NSLocale autoupdatingCurrentLocale];
  return [[current objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

+ (NSString *) groupSepForCurrentLocale {
  return [NSLocale groupSepForLocale:[NSLocale autoupdatingCurrentLocale]];
}

+ (NSString *) groupSepForLocale:(NSLocale *) aLocale {
  return [aLocale objectForKey:NSLocaleGroupingSeparator];
}

+ (NSString *) decimalSepForCurrentLocale {
  return [NSLocale decimalSepForLocale:[NSLocale autoupdatingCurrentLocale]];
}

+ (NSString *) decimalSepForLocale:(NSLocale *) aLocale {
  return [aLocale objectForKey:NSLocaleDecimalSeparator];
}


+ (NSNumberFormatter *) numberFormatterForCurrentLocale {
  return [NSLocale numberFormatterWithLocale:[NSLocale autoupdatingCurrentLocale]];
}

+ (NSNumberFormatter *) numberFormatterWithLocale:(NSLocale *) aLocale {
  NSString *groupSep = [NSLocale groupSepForLocale:aLocale];
  NSString *decimalSep = [NSLocale decimalSepForLocale:aLocale];
  return [NSLocale numberFormatterWithGroupingSep:groupSep
                                             demicalSep:decimalSep];
}


+ (NSNumberFormatter *) numberFormatterWithGroupingSep:(NSString *) groupingSep
                                            demicalSep:(NSString *) decimalSep {
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  
  [formatter setGroupingSeparator:groupingSep];
  [formatter setGroupingSize:3];
  [formatter setUsesGroupingSeparator:YES];
  
  [formatter setDecimalSeparator:decimalSep];
  [formatter setAlwaysShowsDecimalSeparator:YES];
  
  [formatter setMinimumFractionDigits:2];
  [formatter setMaximumFractionDigits:2];
  [formatter setRoundingMode:NSNumberFormatterRoundFloor];
  return formatter;
}

+ (NSLocale *) localeWith12hourClock {
  return  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  
}

+ (NSLocale *) localeWith24hourClock {
  return  [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
}

+ (NSLocale *) localeWithMondayAsFirstDayOfWeek {
  return [[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"];
}

@end
