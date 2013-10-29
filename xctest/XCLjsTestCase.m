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

#import "XCLjsTestCase.h"
#import "Lumberjack.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation XCLjsTestCase

- (id) init {
  self = [super init];
  if (self) {
    
    self.gestalt = [[LjsGestalt alloc] init];
    
    self.findDocumentDirectoryPathOriginal = 
    class_getClassMethod([LjsFileUtilities class],
                         @selector(findDocumentDirectory));
    self.findDocumentDirectoryPathMock = 
    class_getInstanceMethod([self class],
                            @selector(findDocumentDirectoryPathSwizzled));
    

    self.findLibraryDirectoryPathForUserpOriginal = 
    class_getClassMethod([LjsFileUtilities class],
                         @selector(findLibraryDirectoryForUserp:));
    self.findLibraryDirectoryPathForUserpMock =
    class_getInstanceMethod([self class],
                            @selector(findLibraryDirectoryPathForUserpSwizzled:));
    
    self.findPreferencesPathForUserpOriginal =
    class_getClassMethod([LjsFileUtilities class], 
                         @selector(findPreferencesDirectoryForUserp:));
    self.findPreferencesPathForUserpMock =
    class_getInstanceMethod([self class], 
                            @selector(findPreferencesPathForUserpSwizzled:));
    

    self.findCoreDataStorePathForUserpOriginal = 
    class_getClassMethod([LjsFileUtilities class], 
                         @selector(findCoreDataStoreDirectoryForUserp:));
    self.findCoreDataStorePathForUserpOriginal =
    class_getInstanceMethod([self class], 
                            @selector(findCoreDataStorePathForUserpSwizzled:));
    
#if !TARGET_OS_IPHONE
    self.findApplicationSupportDirectoryForUserpOriginal =
    class_getClassMethod([LjsFileUtilities class], 
                         @selector(findApplicationSupportDirectoryForUserp:));
    self.findApplicationSupportDirectoryForUserpMock =
    class_getInstanceMethod([self class], 
                            @selector(findApplicationSupportDirectoryForUserpSwizzled:));
#endif
  
  }
  return self;
}


//- (void) setUpClass {
//  // Run at start of all tests in the class
//  [super setUpClass];
//  if (getenv("GHUNIT_CLI")) {
//    GHTestLog(@"swizzling paths");
//    [self swizzleFindDocumentDirectoryPath];
//    [self swizzleFindPreferencesPath];
//    [self swizzleFindLibraryDirectoryPath];
//    [self swizzleFindCoreDataPath];
//    
//#if !TARGET_OS_IPHONE
//    [self swizzleFindApplicationSupportDirectory];
//#endif
//  }
//
//  NSString *devnull = @"/dev/null/";
//  NSUInteger len = [devnull length];
//  
//  NSString *docsPath = [LjsFileUtilities findDocumentDirectory];
////  NSLog(@"document directory path = %@", docsPath);
//  GHAssertNotEqualStrings([docsPath substringToIndex:len], devnull,
//                          @"path < %@ > should not start with %@",
//                          docsPath, devnull);
//  
//  NSString *libraryPath = [LjsFileUtilities findLibraryDirectoryForUserp:YES];
////  NSLog(@"library path = %@", libraryPath);
//  GHAssertNotEqualStrings([libraryPath substringToIndex:len], devnull,
//                          @"path < %@ > should not start with %@",
//                          libraryPath, devnull);
//
//  NSString *prefPath = [LjsFileUtilities findPreferencesDirectoryForUserp:YES];
////  NSLog(@"preferences path = %@", prefPath);
//  GHAssertNotEqualStrings([prefPath substringToIndex:len], devnull,
//                          @"path < %@ > should not start with %@",
//                          prefPath, devnull);
//  
//  NSString *coreDataPath = [LjsFileUtilities findCoreDataStoreDirectoryForUserp:YES];
////  NSLog(@"core data path path = %@", coreDataPath);
//  GHAssertNotEqualStrings([coreDataPath substringToIndex:len], devnull,
//                          @"path < %@ > should not start with %@",
//                          coreDataPath, devnull);
//  
//#if !TARGET_OS_IPHONE
//  NSString *appSupportPath = [LjsFileUtilities findApplicationSupportDirectoryForUserp:YES];
////  NSLog(@"application support path = %@", appSupportPath);
//  GHAssertNotEqualStrings([appSupportPath substringToIndex:len], devnull,
//                          @"path < %@ > should not start with %@",
//                          appSupportPath, devnull);
//#endif
//
//}

//- (void) tearDownClass {
//  // Run at end of all tests in the class  
//  if (getenv("GHUNIT_CLI")) {
//    GHTestLog(@"restoring swizzled paths");
//    [self restoreFindDocumentDirectoryPath];
//    [self restoreFindPreferencesPath];
//    [self restoreFindLibraryDirectoryPath];
//    [self restoreFindCoreDataPath];
//    
//#if !TARGET_OS_IPHONE
//    [self restoreFindApplicationSupportDirectory];
//#endif
//  }
//  
//  [super tearDownClass];
//}

- (void) setUp {
  [super setUp];
  if (getenv("GHUNIT_CLI")) {
    NSLog(@"swizzling paths");
    [self swizzleFindDocumentDirectoryPath];
    [self swizzleFindPreferencesPath];
    [self swizzleFindLibraryDirectoryPath];
    [self swizzleFindCoreDataPath];
    
#if !TARGET_OS_IPHONE
    [self swizzleFindApplicationSupportDirectory];
#endif
  }
  
  NSString *devnull = @"/dev/null/";
  NSUInteger len = [devnull length];
  
  NSString *docsPath = [LjsFileUtilities findDocumentDirectory];
  //  NSLog(@"document directory path = %@", docsPath);
  XCTAssertNotEqualObjects([docsPath substringToIndex:len], devnull,
                          @"path < %@ > should not start with %@",
                          docsPath, devnull);
  
  NSString *libraryPath = [LjsFileUtilities findLibraryDirectoryForUserp:YES];
  //  NSLog(@"library path = %@", libraryPath);
  XCTAssertNotEqualObjects([libraryPath substringToIndex:len], devnull,
                          @"path < %@ > should not start with %@",
                          libraryPath, devnull);
  
  NSString *prefPath = [LjsFileUtilities findPreferencesDirectoryForUserp:YES];
  //  NSLog(@"preferences path = %@", prefPath);
  XCTAssertNotEqualObjects([prefPath substringToIndex:len], devnull,
                          @"path < %@ > should not start with %@",
                          prefPath, devnull);
  
  NSString *coreDataPath = [LjsFileUtilities findCoreDataStoreDirectoryForUserp:YES];
  //  NSLog(@"core data path path = %@", coreDataPath);
  XCTAssertNotEqualObjects([coreDataPath substringToIndex:len], devnull,
                          @"path < %@ > should not start with %@",
                          coreDataPath, devnull);
  
#if !TARGET_OS_IPHONE
  NSString *appSupportPath = [LjsFileUtilities findApplicationSupportDirectoryForUserp:YES];
  //  NSLog(@"application support path = %@", appSupportPath);
  XCTAssertNotEqualObjects([appSupportPath substringToIndex:len], devnull,
                          @"path < %@ > should not start with %@",
                          appSupportPath, devnull);
#endif

}

- (void) tearDown {
  // Run at the end of each test
  // Run at end of all tests in the class
  if (getenv("GHUNIT_CLI")) {
    NSLog(@"restoring swizzled paths");
    [self restoreFindDocumentDirectoryPath];
    [self restoreFindPreferencesPath];
    [self restoreFindLibraryDirectoryPath];
    [self restoreFindCoreDataPath];
    
#if !TARGET_OS_IPHONE
    [self restoreFindApplicationSupportDirectory];
#endif
  }
  [super tearDown];
}

- (NSString *) emptyStringOrNil {
  NSString *result = nil;
  if ([LjsVariates flip]) {
    result = @"";
  }
  return result;
}

- (BOOL) flip {
  return [LjsVariates flip];
}

// must swizzle for command line builds because Application does not exist
// on the CLI so document path is /dev/null/Documents
- (NSString *) findDocumentDirectoryPathSwizzled {
//  NSLog(@"in find document directory path swizzled");
  NSString *path = @"./build/sandbox/Documents";
  NSError *error = nil;
  BOOL success = [LjsFileUtilities ensureDirectory:path];
  XCTAssertTrue(success, @"could not create directory at path: %@\n%@ : %@",
               path, [error localizedDescription], error);
  
  return path;
}

- (void) swizzleFindDocumentDirectoryPath {
  method_exchangeImplementations(self.findDocumentDirectoryPathOriginal,
                                 self.findDocumentDirectoryPathMock);
}

- (void) restoreFindDocumentDirectoryPath {
  method_exchangeImplementations(self.findDocumentDirectoryPathMock,
                                 self.findDocumentDirectoryPathOriginal);

}

- (NSString *) findLibraryDirectoryPathForUserpSwizzled:(BOOL) ignorable {
//  NSLog(@"in find library directory path swizzled");
  NSString *path = @"./build/sandbox/Library";
  NSError *error = nil;
  BOOL success = [LjsFileUtilities ensureDirectory:path];
  XCTAssertTrue(success, @"could not create directory at path: %@\n%@ : %@",
               path, [error localizedDescription], error);
  return path;
}

- (void) swizzleFindLibraryDirectoryPath {
  method_exchangeImplementations(self.findLibraryDirectoryPathForUserpOriginal, 
                                 self.findLibraryDirectoryPathForUserpMock);
}

- (void) restoreFindLibraryDirectoryPath {
  method_exchangeImplementations(self.findLibraryDirectoryPathForUserpMock, 
                                 self.findLibraryDirectoryPathForUserpOriginal);
}

- (NSString *) findPreferencesPathForUserpSwizzled:(BOOL) ignorable {
//  NSLog(@"in find preference path swizzled");
  NSString *path = @"./build/sandbox/Library/Preferences";
  BOOL success = [LjsFileUtilities ensureDirectory:path];
  XCTAssertTrue(success, @"could not create directory at path: %@", path);
  return path;
}

- (void) swizzleFindPreferencesPath {
  method_exchangeImplementations(self.findPreferencesPathForUserpOriginal,
                                 self.findPreferencesPathForUserpMock);
}

- (void) restoreFindPreferencesPath {
  method_exchangeImplementations(self.findPreferencesPathForUserpMock, 
                                 self.findPreferencesPathForUserpOriginal);
}


- (NSString *) findCoreDataStorePathForUserpSwizzled:(BOOL) ignorable {
//  NSLog(@"in find core data path swizzled");
  NSString *path = @"./build/sandbox/Library";
  BOOL success = [LjsFileUtilities ensureDirectory:path];
  XCTAssertTrue(success, @"could not create directory at path: %@", path);
  return path;
}

- (void) swizzleFindCoreDataPath {
  method_exchangeImplementations(self.findCoreDataStorePathForUserpOriginal,
                                 self.findCoreDataStorePathForUserpMock);
}

- (void) restoreFindCoreDataPath {
  method_exchangeImplementations(self.findCoreDataStorePathForUserpMock,
                                 self.findCoreDataStorePathForUserpOriginal);

}


#if !TARGET_OS_IPHONE
- (NSString *) findApplicationSupportDirectoryForUserpSwizzled:(BOOL) ignorable {
//  NSLog(@"in find application support directory swizzled");
  NSString *path = @"./build/sandbox/Library/Application Support";
  BOOL success = [LjsFileUtilities ensureDirectory:path];
  GHAssertTrue(success, @"could not create directory at path: %@", path);
  return path;
}

- (void) swizzleFindApplicationSupportDirectory {
  method_exchangeImplementations(self.findApplicationSupportDirectoryForUserpOriginal,
                                 self.findApplicationSupportDirectoryForUserpMock);
}

- (void) restoreFindApplicationSupportDirectory {
  method_exchangeImplementations(self.findApplicationSupportDirectoryForUserpMock,
                                 self.findApplicationSupportDirectoryForUserpOriginal);
}
#endif

- (void) dummyControlSelector:(id) sender {
  NSLog(@"dummy control selector called with sender: %@", sender);
  return;
}

- (void) dummySelector {
  NSLog(@"dummy selector called");
}

- (NSArray *) arrayOfAbcStrings {
  return [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
}

- (NSSet *) setOfAbcStrings {
  return [NSSet setWithArray:[self arrayOfAbcStrings]];
}

#pragma mark - dates

- (NSDate *) dateByAddingDays:(NSInteger) aNumDays
                       toDate:(NSDate *) aDate {
  NSDateComponents *comps = [[NSDateComponents alloc] init];
  comps.day = aNumDays;
  return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:aDate options:0];
}

- (NSArray *) arrayOfDatesTodayTormorrowDayAfter {
  NSDate *date = [NSDate date];
  return @[date,
          [self dateByAddingDays:1 toDate:date],
          [self dateByAddingDays:2 toDate:date]];
}


- (NSArray *) arrayOfMutableStrings {
  NSArray *array = [NSArray arrayWithObjects:
                    [@"a" mutableCopy],
                    [@"b" mutableCopy],
                    [@"c" mutableCopy],
                    nil];
  return array;
}

- (NSSet *) setOfMutableStrings {
  NSSet *set = [NSSet setWithObjects:
                [@"a" mutableCopy],
                [@"b" mutableCopy],
                [@"c" mutableCopy],
                nil];
  return set;
}

- (NSDictionary *) dictionaryOfMutableStrings {
  return [NSDictionary dictionaryWithObjects:[self arrayOfMutableStrings]
                                     forKeys:[self arrayOfAbcStrings]];
}

- (NSDate *) dateForTimeOutWithSeconds:(NSTimeInterval) aSeconds {
  return [[NSDate date] dateByAddingTimeInterval:aSeconds];
}

- (NSDate *) dateForDefaultTimeOut {
  return [self dateForTimeOutWithSeconds:1.5];
}

#pragma mark - comparing arrays

- (void) compareArray:(NSArray *) aActual
              toArray:(NSArray *) aExpected
            asStrings:(BOOL) aCompareElementsAsStrings {
  XCTAssertNotNil(aActual, @"pre-condition - should not be nil");
  XCTAssertNotNil(aExpected, @"pre-condition - should not be nil");
  XCTAssertEqual((NSUInteger)[aActual count], (NSUInteger)[aExpected count],
                 @"arrays should have the same number of elements");
  [aActual enumerateObjectsUsingBlock:^(id actual, NSUInteger idx, BOOL *stop) {
    id expected = [aExpected objectAtIndex:idx];
    if (aCompareElementsAsStrings) {
      XCTAssertEqualObjects(actual, expected, @"expected string equality - failed at index '%d'", idx);
    } else {
      XCTAssertEqualObjects(actual, expected, @"expected object equality - failed at index '%d'", idx);
    }
  }];
}

@end
