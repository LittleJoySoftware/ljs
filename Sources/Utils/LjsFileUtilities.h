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

extern NSString *LjsFileUtilitiesErrorDomain;
extern NSString *LjsFileUtilitiesFileOrDirectoryErrorUserInfoKey;

typedef enum : NSUInteger {
  kLjsFileUtilitiesErrorCodeRead = 911,
  kLjsFileUtilitiesErrorCodeWrite,
  kLjsFileUtilitiesErrorCodeFileDoesNotExist
} LjsFileUtilitiesErrorCode;


@interface LjsFileUtilities : NSObject 

+ (NSString *) findDocumentDirectory;
+ (NSString *) findLibraryDirectoryForUserp:(BOOL) forUser;
+ (NSString *) findPreferencesDirectoryForUserp:(BOOL) forUser;
+ (NSString *) findCoreDataStoreDirectoryForUserp:(BOOL) forUser;
#if !TARGET_OS_IPHONE
+ (NSString *)findApplicationSupportDirectoryForUserp:(BOOL) forUser; 
#endif

+ (BOOL) ensureDirectory:(NSString *) aPath
                 manager:(NSFileManager *) aFileManager;
+ (BOOL) ensureDirectory:(NSString *) aDirectoryPath;

+ (NSString *) parentDirectoryForPath:(NSString *) childPath;

#if !TARGET_OS_IPHONE
+ (NSString *) pathFromOpenPanelWithPrompt:(NSString *) aPrompt 
                                     title:(NSString *) aTitle
                             lastDirectory:(NSString *) aLastDirectory
                         fallBackDirectory:(NSString *) fallbackDirectory
                          defaultsKeyOrNil:(NSString *) aDefaultsKeyOrNil;

#endif



+ (NSString *) lastDirectoryPathWithDefaultsKey:(NSString *) aDefaultsKey
                              fallbackDirectory:(NSString *) aFallbackDirectory;


+ (BOOL) writeDictionary:(NSDictionary *) aDict toFile:(NSString *) aPath;
+ (BOOL) writeDictionary:(NSDictionary *) aDict 
                  toFile:(NSString *) aPath 
       ensureDirectories:(BOOL) aShouldCreateDirectories;

+ (NSDictionary *) readDictionaryFromFile:(NSString *) aPath;
+ (BOOL) writeArray:(NSArray *) aArray toFile:(NSString *) aPath;

+ (BOOL) writeArray:(NSArray *) aArray 
             toFile:(NSString *) aPath 
  ensureDirectories:(BOOL) aShouldCreateDirectories;


+ (NSArray *) readArrayFromFile:(NSString *) aPath;

+ (NSArray *) readLinesFromFile:(NSString *) aPath;


@end
