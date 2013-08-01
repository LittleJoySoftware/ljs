// Copyright 2011 Little Joy Software. All rights reserved.
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

#if !TARGET_OS_IPHONE

typedef enum : NSUInteger {
  LjsGestaltMinor_v_10_0 = 0,
  LjsGestaltMinor_v_10_1,
  LjsGestaltMinor_v_10_2,
  LjsGestaltMinor_v_10_3,
  LjsGestaltMinor_v_10_4,
  LjsGestaltMinor_v_10_5,
  LjsGestaltMinor_v_10_6,
  LjsGestaltMinor_v_10_7,
  LjsGestaltMinor_v_10_8
} LjsGestaltMinorVersion;
#else

extern NSString *const k_ljs_ios_700;
extern CGFloat const k_ljs_iphone_5_height;


#define ljs_is_iphone_5 (((CGRect)[[UIScreen mainScreen] bounds]).size.height == 568)
#define ljs_ios_version_eql(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define ljs_ios_version_gt(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define ljs_ios_version_gte(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define ljs_ios_version_lt(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define ljs_ios_version_lte(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


NS_INLINE CGFloat ljs_iphone_screen_height(BOOL tabbar, BOOL navbar, BOOL tallNav) {
  if (ljs_ios_version_gte(k_ljs_ios_700)) {
    return ljs_is_iphone_5 ? k_ljs_iphone_5_height : 480;
  }
  // max drawable area on iOS 5 + 6
  CGFloat result = 460;
  if (tabbar) { result -= 49; }
  if (navbar) { result -= 44; }
  if (tallNav) { result -= 30; }
  if (ljs_is_iphone_5) { result += 88; }
  return result;
}


#endif

@interface LjsGestalt : NSObject 


#if !TARGET_OS_IPHONE

@property (nonatomic, assign) NSUInteger majorVersion;
@property (nonatomic, assign) NSUInteger minorVersion;
@property (nonatomic, assign) NSUInteger bugVersion;


- (BOOL)getSystemVersionMajor:(SInt32 *)major
                        minor:(SInt32 *)minor
                       bugFix:(SInt32 *)bugFix;


#endif

#if TARGET_OS_IPHONE
- (BOOL) isDeviceIpad;
- (BOOL) isDeviceIphone;
- (BOOL) isDeviceUsingRetina;
- (BOOL) isDeviceIphone5;

#endif


- (NSString *) buildConfiguration:(BOOL) abbrevated;

- (BOOL) isIphone;
- (BOOL) isSimulator;
- (BOOL) isMacOs;


- (BOOL) isDebugBuild;
- (BOOL) isAdHocBuild;
- (BOOL) isAppStoreBuild;

- (BOOL) shouldDebugLabels;
- (BOOL) shouldDebugButtons;

- (NSString *) currentLanguageCode;
- (BOOL) currentLangCodeIsEqualToCode:(NSString *) aCode;
- (BOOL) isCurrentLanguageEnglish;

- (BOOL) isGhUnitCommandLineBuild;


@end

