#import "NSError+LjsAdditions.h"
#import "Lumberjack.h"


#ifdef LOG_CONFIGURATION_DEBUG
static const int __unused ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int __unused ddLogLevel = LOG_LEVEL_WARN;
#endif


@implementation NSError (NSError_LjsAdditions)


+ (NSError *) errorWithDomain:(NSString *) aDomain
                         code:(NSInteger) aCode
         localizedDescription:(NSString *) aLocalizedDescription
                otherUserInfo:(NSDictionary *) aOtherUserInfo {
  NSMutableDictionary *userInfo;
  if (aOtherUserInfo == nil) {
    userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
  } else {
    userInfo = [NSMutableDictionary dictionaryWithDictionary:aOtherUserInfo];
  }

  userInfo[NSLocalizedDescriptionKey] = aLocalizedDescription;
  userInfo[NSStringEncodingErrorKey] = @(NSUTF8StringEncoding);
  return [NSError errorWithDomain:aDomain
                             code:aCode
                         userInfo:userInfo];

}


+ (NSError *) errorWithDomain:(NSString *) aDomain
                         code:(NSInteger) aCode
         localizedDescription:(NSString *) aLocalizedDescription {
  return [NSError errorWithDomain:aDomain
                             code:aCode
             localizedDescription:aLocalizedDescription
                    otherUserInfo:nil];
}

@end


@interface LjsErrorFactory ()

+ (NSString *) errorDomain;

@end


@implementation LjsErrorFactory


#pragma mark Memory Management


- (id) init {
  //  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

+ (NSString *) errorDomain {
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

+ (NSError *) errorWithCode:(NSInteger) aCode
       localizedDescription:(NSString *) aLocalizedDescription
              otherUserInfo:(NSDictionary *) aOtherUserInfo {
  NSMutableDictionary *userInfo;
  if (aOtherUserInfo == nil) {
    userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
  } else {
    userInfo = [NSMutableDictionary dictionaryWithDictionary:aOtherUserInfo];
  }
  
  userInfo[NSLocalizedDescriptionKey] = aLocalizedDescription;
  userInfo[NSStringEncodingErrorKey] = @(NSUTF8StringEncoding);
  return [NSError errorWithDomain:[LjsErrorFactory errorDomain]
                             code:aCode
                         userInfo:userInfo];
}


+ (NSError *) errorWithCode:(NSInteger) aCode
       localizedDescription:(NSString *) aLocalizedDescription
             userInfoObject:(id) aObject
                userInfoKey:(id) aKey {
  NSDictionary *ui = @{aKey: aObject};
  return [LjsErrorFactory errorWithCode:aCode
                   localizedDescription:aLocalizedDescription
                          otherUserInfo:ui];
}


+ (NSError *) errorWithCode:(NSInteger) aCode
       localizedDescription:(NSString *) aLocalizedDescription {
  return [NSError errorWithDomain:[LjsErrorFactory errorDomain]
                             code:aCode
             localizedDescription:aLocalizedDescription
                    otherUserInfo:nil];
}

+ (NSError *) errorForInvalidArgumentWithLocalizedDescription:(NSString *) aLocalizedDescription {
  return [LjsErrorFactory errorWithCode:kLjsErrorCode_InvalidArgument
                   localizedDescription:aLocalizedDescription];
}


@end
