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
#import <OCMock/OCMock.h>

#import "LjsGestalt.h"
#import "LjsFileUtilities.h"

#import "LjsVariates.h"
#import "LjsBlocks.h"
#import "LjsCategories.h"
#import <objc/runtime.h>

// hamcrest
//https://github.com/jonreid/OCHamcrest/issues/7
//#define HC_SHORTHAND


#define pending(description) \
[self failWithException:[NSException ghu_failureInFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, nil)]]

#if TARGET_OS_IPHONE

#import <GHUnitIOS/GHUnit.h>

@interface UIView (UIView_TESTING)
- (NSMutableDictionary *)fullDescription;
@end
#endif

@class LjsGestalt;

@interface LjsTestCase : GHTestCase


@property (nonatomic, strong) LjsGestalt *gestalt;

@property (assign) Method findDocumentDirectoryPathOriginal;
@property (assign) Method findDocumentDirectoryPathMock;

@property (assign) Method findLibraryDirectoryPathForUserpOriginal;
@property (assign) Method findLibraryDirectoryPathForUserpMock;

@property (assign) Method findPreferencesPathForUserpOriginal;
@property (assign) Method findPreferencesPathForUserpMock;

@property (assign) Method findCoreDataStorePathForUserpOriginal;
@property (assign) Method findCoreDataStorePathForUserpMock;

#if !TARGET_OS_IPHONE
@property (assign) Method findApplicationSupportDirectoryForUserpOriginal;
@property (assign) Method findApplicationSupportDirectoryForUserpMock;
#endif


- (NSString *) findDocumentDirectoryPathSwizzled;
- (void) swizzleFindDocumentDirectoryPath;
- (void) restoreFindDocumentDirectoryPath;

- (NSString *) findLibraryDirectoryPathForUserpSwizzled:(BOOL) ignorable;
- (void) swizzleFindLibraryDirectoryPath;
- (void) restoreFindLibraryDirectoryPath;

- (NSString *) findPreferencesPathForUserpSwizzled:(BOOL) ignorable;
- (void) swizzleFindPreferencesPath;
- (void) restoreFindPreferencesPath;

- (NSString *) findCoreDataStorePathForUserpSwizzled:(BOOL) ignorable;
- (void) swizzleFindCoreDataPath;
- (void) restoreFindCoreDataPath;

#if !TARGET_OS_IPHONE
- (NSString *) findApplicationSupportDirectoryForUserpSwizzled:(BOOL) ignorable;
- (void) swizzleFindApplicationSupportDirectory;
- (void) restoreFindApplicationSupportDirectory;
#endif

#pragma mark - variates

- (BOOL) flip;

#pragma mark - selectors

- (void) dummyControlSelector:(id) sender;
- (void) dummySelector;

#pragma mark - strings

- (NSString *) emptyStringOrNil;
- (NSArray *) arrayOfAbcStrings;
- (NSSet *) setOfAbcStrings;
- (NSArray *) arrayOfMutableStrings;
- (NSSet *) setOfMutableStrings;
- (NSDictionary *) dictionaryOfMutableStrings;

#pragma mark - dates

- (NSDate *) dateByAddingDays:(NSInteger) aNumDays
                       toDate:(NSDate *) aDate;
- (NSArray *) arrayOfDatesTodayTormorrowDayAfter;
- (NSDate *) dateForTimeOutWithSeconds:(NSTimeInterval) aSeconds;
- (NSDate *) dateForDefaultTimeOut;

#pragma mark - comparing arrays

- (void) compareArray:(NSArray *) aActual
              toArray:(NSArray *) aExpected
            asStrings:(BOOL) aCompareElementsAsStrings;

@end
