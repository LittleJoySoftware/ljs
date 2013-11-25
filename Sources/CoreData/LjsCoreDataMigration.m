#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LjsCoreDataMigration.h"
#import "LjsCategories.h"
#import <CoreData/CoreData.h>
#import "LjsUUIDGen.h"

#import "Lumberjack.h"
#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface LjsCompatMapping : NSObject

@property (nonatomic, strong, readonly) NSMappingModel *mappingModel;
@property (nonatomic, strong, readonly) NSManagedObjectModel *objectModel;
@property (nonatomic, copy, readonly) NSString *modelPath;
@property (nonatomic, copy, readonly) NSString *sourceVersion;
@property (nonatomic, copy, readonly) NSString *targetVersion;

- (id) initWithMappingModel:(NSMappingModel *) aMappingModel
                objectModel:(NSManagedObjectModel *) aObjectModel
                  modelPath:(NSString *) aModelPath
              sourceVersion:(NSString *) aSourceNumber
              targetVersion:(NSString *) aTargetNumber;


@end


@implementation LjsCompatMapping

#pragma mark - Memory Management

@synthesize mappingModel = _mappingModel;
@synthesize objectModel = _objectModel;
@synthesize modelPath = _modelPath;
@synthesize sourceVersion = _sourceVersion;
@synthesize targetVersion = _targetVersion;

- (id) init { [self doesNotRecognizeSelector:_cmd]; return nil; }

- (id) initWithMappingModel:(NSMappingModel *) aMappingModel
                objectModel:(NSManagedObjectModel *) aObjectModel
                  modelPath:(NSString *) aModelPath
              sourceVersion:(NSString *) aSourceNumber
              targetVersion:(NSString *) aTargetNumber {
  self = [super init];
  if (self) {
    _mappingModel = aMappingModel;
    _objectModel = aObjectModel;
    _modelPath = aModelPath;
    _sourceVersion = aSourceNumber;
    _targetVersion = aTargetNumber;
  }
  return self;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"<Mapping:  %@ ==> %@ : %@",
          _sourceVersion, _targetVersion, [_modelPath lastPathComponent]];
}

@end

static NSString *const kErrorDomain = @"com.littlejoysoftware.core data progressive migration";

typedef enum : NSUInteger {
  kErrorCode = 8001
} error_codes;


/**
 LjsProgressMigration (Private)
 */
@interface LjsCoreDataMigration ()

/** @name Properties */

/**
 a timestamped diretory in which all the migration work is done
 */
@property (nonatomic, copy, readonly) NSString *timestampedDirectory;
@property (nonatomic, strong, readonly) NSArray *ignorableModels;
@property (nonatomic, strong, readonly) NSArray *availableModelVersions;

/** @name Utilitiy */

- (NSURL *) URLforDestinationStoreWithSourceStoreURL:(NSURL *) aSourceStoreURL
                                           modelName:(NSString *) aModelName
                                      storeExtension:(NSString *) aStoreExtention
                                               error:(NSError **) aError;

- (BOOL) swapSourceStoreURL:(NSURL *) aSourceStoreURL
    withDestinationStoreURL:(NSURL *) aDestinationStoreURL
                  modelName:(NSString *) aModelName
             storeExtension:(NSString *) aStoreExtension
                      error:(NSError **) aError;

- (NSError *) errorWithMessage:(NSString *) aMessage;


@end

@implementation LjsCoreDataMigration


#pragma mark Memory Management

@synthesize timestampedDirectory = _timestampedDirectory;
@synthesize ignorableModels = _ignorableModels;
@synthesize availableModelVersions = _availableModelVersions;


- (NSError *) errorWithMessage:(NSString *) aMessage {
  return [NSError errorWithDomain:kErrorDomain code:kErrorCode localizedDescription:aMessage];
}

- (NSArray *) availableModelVersions {
  if (_availableModelVersions != nil)  { return _availableModelVersions; }
  NSBundle *main = [NSBundle mainBundle];
  NSArray *momdArray = [main pathsForResourcesOfType:@"momd"
                                         inDirectory:nil];
  NSMutableArray *modelPaths = [NSMutableArray array];
  for (NSString *momdPath in momdArray) {
    NSString *resourceSubpath = [momdPath lastPathComponent];
    NSArray *array = [main pathsForResourcesOfType:@"mom"
                                       inDirectory:resourceSubpath];
    [modelPaths addObjectsFromArray:array];
  }
  NSArray* otherModels = [main pathsForResourcesOfType:@"mom"
                                           inDirectory:nil];
  [modelPaths addObjectsFromArray:otherModels];
  
  NSArray *ignorable = self.ignorableModels;
  if ([ignorable has_objects] == NO) {
    return [NSArray arrayWithArray:modelPaths];
  }
  
  NSArray *filtered = [modelPaths filteredArrayUsingPassingBlock:^BOOL(NSString *path, NSUInteger idx, BOOL *stop) {
    NSString *filename = [[path lastPathComponent] stringByDeletingPathExtension];
    return [ignorable containsObject:filename] == NO;
  }];
  
  _availableModelVersions = filtered;
  
  return _availableModelVersions;
}


/**
 @return a initialized instance
 sets the timepstamed directory property to `migration-` _current-date_
 */
- (id) init {
  self = [super init];
  if (self) {
    NSDateFormatter *df = [NSDateFormatter orderedDateFormatterWithMillis];
    NSString *dateStr = [df stringFromDate:[NSDate date]];
    _timestampedDirectory = [NSString stringWithFormat:@"migration-%@", dateStr];
  }
  return self;
}

- (id) initWithIgnorableModels:(NSArray *) aIgnorableModels {
  self = [self init];
  if (self != nil) {
    _ignorableModels = [NSArray arrayWithArray:aIgnorableModels];
  }
  return self;
}

/*
 recursively walks over all the model versions and attempts to merge each in turn with the
 store found at soureStoreURL.
 @return YES if the migration was successful and NO if not
 @param aSourceStoreURL the store that is to be migrated to
 @param aStoreType the kind of store (have seen problems with in memory stores)
 @param aFinalModel the model that we are trying to migrate to
 @param aError if non-NULL will be populated if there is an error - this will
 be indicated by a return value of NO
 */
- (BOOL) recursivelyMigrateURL:(NSURL *) aSourceStoreURL
                     storeType:(NSString *) aStoreType
                       toModel:(NSManagedObjectModel *) aFinalModel
                         error:(NSError **) aError {
  
  
  NSError *metadataError = nil;
  NSDictionary *sourceMetadata =
  [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:aStoreType
                                                             URL:aSourceStoreURL
                                                           error:&metadataError];
  // no metadata - return nil
  if (sourceMetadata == nil) {
    DDLogError(@"no source metadata");
    if (aError != NULL) {  *aError = metadataError; }
    return NO;
  }
  
  // compatible model - nil the error and return YES
  if ([aFinalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
    DDLogDebug(@"compatible model - returning YES!");
    if (aError != NULL) { *aError = nil; }
    return YES;
  }
  
  //Find the source model
  NSManagedObjectModel *sourceModel = [NSManagedObjectModel
                                       mergedModelFromBundles:nil
                                       forStoreMetadata:sourceMetadata];
  if (sourceModel == nil) {
    NSString *msg = [@"failed to create source model from metadata: "
                     stringByAppendingFormat:@"%@", sourceMetadata];
    DDLogError(msg); if (aError != NULL) { *aError = [self errorWithMessage:msg]; }
    return NO;
  }
  
  // find all of the mom and momd files in the Resources directory
  NSArray *modelPaths = [self availableModelVersions];
  if ([modelPaths has_objects] == NO) {
    NSString *message = @"No models found in bundle.";
    DDLogError(message); if (aError != NULL) { *aError = [self errorWithMessage:message]; }
    return NO;
  }
  
  LjsCompatMapping *compat = [self compatibleMappingWithModelPaths:modelPaths
                                                       sourceModel:sourceModel];
  
  modelPaths = nil;
  
  if (compat == nil) {
    NSString *message = @"Could not find matching destination MOM and mapping.";
    DDLogError(message); if (aError != NULL) { *aError = [self errorWithMessage:message]; }
    return NO;
  }
  
  NSMappingModel *mappingModel = compat.mappingModel;
  NSManagedObjectModel *destinationModel = compat.objectModel;
  NSString *modelPath = compat.modelPath;
  
  compat = nil;
  
  //We have a mapping model and a destination model.  Time to migrate
  NSMigrationManager *manager = [[NSMigrationManager alloc]
                                 initWithSourceModel:sourceModel
                                 destinationModel:destinationModel];
  
  
  //[self.managers addObject:manager];
  NSError *urlError = nil;
  NSString *modelName = [[modelPath lastPathComponent] stringByDeletingPathExtension];
  NSString *storeExtension = [[aSourceStoreURL path] pathExtension];
  NSURL *destinationStoreURL = [self URLforDestinationStoreWithSourceStoreURL:aSourceStoreURL
                                                                    modelName:modelName
                                                               storeExtension:storeExtension
                                                                        error:&urlError];
  if (destinationStoreURL == nil) {
    // error populated in the URLforDestinationStore
    DDLogError(@"destination URL is nil");
    if (aError != nil) { *aError = urlError; }
    
    return NO;
  }
  
  
  NSDictionary *options = nil;
  
  // do migration - if returns NO, then we return NO
  NSError *migrationError = nil;
  if ([manager migrateStoreFromURL:aSourceStoreURL
                              type:aStoreType
                           options:options
                  withMappingModel:mappingModel
                  toDestinationURL:destinationStoreURL
                   destinationType:aStoreType
                destinationOptions:options
                             error:&migrationError] == NO) {
    DDLogError(@"could not migrate");
    if (aError != NULL) { *aError = migrationError; }
    return NO;
  }
  
  
  //Migration was successful, move the files around to preserve the source
  NSError *backupError = nil;
  if ([self swapSourceStoreURL:aSourceStoreURL
       withDestinationStoreURL:destinationStoreURL
                     modelName:modelName
                storeExtension:storeExtension
                         error:&backupError] == NO) {
    DDLogError(@"could not make swap source and destination");
    if (aError != nil) { *aError = backupError; }
    return NO;
  }
  
  
  manager = nil;
  modelName = nil;
  destinationModel = nil;
  
  destinationStoreURL = nil;
  modelName = nil;
  storeExtension = nil;
  
  sourceMetadata = nil;
  sourceModel = nil;
  
  return [self recursivelyMigrateURL:aSourceStoreURL
                           storeType:aStoreType
                             toModel:aFinalModel
                               error:aError];
  
}

/*
 @return a dictionary that contains an NSMappingModel, an NSManagedObjectModel,
 and path the model that is built by trying to contruct a mapping model from
 the model paths and the source model
 @param aModelPaths a list of model paths
 @param aSourceModel the model we are trying to migration _from_
 */
- (LjsCompatMapping *) compatibleMappingWithModelPaths:(NSArray *) aModelPaths
                                           sourceModel:(NSManagedObjectModel *) aSourceModel {
  LjsCompatMapping *mapping = nil;
  for (NSString *path in aModelPaths) {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSManagedObjectModel *destMom = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    NSString *sourceVersion = [[[aSourceModel versionIdentifiers] allObjects] first];
    NSString *targetVersion = [[[destMom versionIdentifiers] allObjects] first];
    
    if ([sourceVersion isEqualToString:targetVersion] == YES) {
      DDLogDebug(@"model versions are the same: '%@' so we skip this pair", targetVersion);
      continue;
    }
    
    if ([sourceVersion integerValue] > [targetVersion integerValue]) {
      DDLogDebug(@"source model version '%@' is > target model version '%@' so we skip this pair",
                 sourceVersion, targetVersion);
      continue;
    }
    
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                            forSourceModel:aSourceModel
                                                          destinationModel:destMom];
    if (mappingModel == nil) {
      DDLogDebug(@"no mapping model from '%@' to '%@'", sourceVersion, targetVersion);
      continue;
    }
    
    mapping = [[LjsCompatMapping alloc]
               initWithMappingModel:mappingModel
               objectModel:destMom
               modelPath:path
               sourceVersion:sourceVersion
               targetVersion:targetVersion];
    break;
    
  }
  return mapping;
}


/*
 @return a file URL to a temporary directory where the migration work will be
 done.  if there is an error, this method returns nil and attempts to populate
 the aError parameter
 @param aSourceStoreURL the original source store url
 @param aModelName the name of the model we are migrating from
 @param aStoreExtention the file extension of the store
 @param aError will be populated if there is an error and the argument is non-NULL
 */
- (NSURL *) URLforDestinationStoreWithSourceStoreURL:(NSURL *) aSourceStoreURL
                                           modelName:(NSString *) aModelName
                                      storeExtension:(NSString *) aStoreExtention
                                               error:(NSError **) aError {
  NSString *baseDirPath = [[aSourceStoreURL path] stringByDeletingLastPathComponent];
  NSString *timestampedDir = self.timestampedDirectory;
  NSString *timestampDirPath = [baseDirPath stringByAppendingPathComponent:timestampedDir];
  
  NSString *lastPathDir = [baseDirPath lastPathComponent];
  if ([lastPathDir isEqualToString:timestampedDir] == NO) {
    if ([[NSFileManager defaultManager] fileExistsAtPath:timestampDirPath] == NO) {
      if ([[NSFileManager defaultManager] createDirectoryAtPath:timestampDirPath
                                    withIntermediateDirectories:YES
                                                     attributes:nil error:aError] == NO) {
        NSString *message = [@"Could not create tmp directory "
                             stringByAppendingFormat:@"%@ at path %@",
                             timestampedDir, timestampDirPath];
        DDLogError(message);  if (aError != NULL) { *aError = [self errorWithMessage:message]; }
        return nil;
      }
    }
  }
  
  NSString *destStoreName = [NSString stringWithFormat:@"%@.%@",
                             aModelName, aStoreExtention];
  NSString *storePath = [timestampDirPath stringByAppendingPathComponent:destStoreName];
  
  return [NSURL fileURLWithPath:storePath];
}


/*
 @return YES if the swapping was success and NO otherwise.  if the swap
 fails, the aError will be populated if it is non-NULL
 @param aSourceStoreURL the source store
 @param aDestinationStoreURL the destination store
 @param aModelName the name of the model we are migrating
 @param aStoreExtension the file extension of the store
 @param aError populated when non-NULL and the swap is unsuccessful
 */
- (BOOL) swapSourceStoreURL:(NSURL *) aSourceStoreURL
    withDestinationStoreURL:(NSURL *) aDestinationStoreURL
                  modelName:(NSString *) aModelName
             storeExtension:(NSString *) aStoreExtension
                      error:(NSError **) aError {
  @synchronized(self) {
    
    NSString *storePath = [aDestinationStoreURL path];
    
    NSString *guid = [LjsUUIDGen generateUUID];
    guid = [guid stringByAppendingString:@"-ORIGINAL-"];
    guid = [guid stringByAppendingFormat:@"-%@", aModelName];
    guid = [guid stringByAppendingPathExtension:aStoreExtension];
    NSString *appSupportPath = [storePath stringByDeletingLastPathComponent];
    NSString *backupPath = [appSupportPath stringByAppendingPathComponent:guid];
    
  
    NSError *moveToBackupError = nil;
    
    if ([[NSFileManager defaultManager] moveItemAtPath:[aSourceStoreURL path]
                                                toPath:backupPath
                                                 error:&moveToBackupError] == NO) {
      DDLogError(@"could not move source store to the back up path");
      DDLogError(@"source store:  '%@'", [aSourceStoreURL path]);
      DDLogError(@" backup path:   '%@'", backupPath);
      DDLogError(@"       error: %@", [moveToBackupError localizedDescription]);
      if (aError != NULL) { *aError = moveToBackupError; }
      return NO;
    }
    
    // move the destination to the source path
    NSError *moveDestinationToSourceError = nil;
    if ([[NSFileManager defaultManager] moveItemAtPath:storePath
                                                toPath:[aSourceStoreURL path]
                                                 error:&moveDestinationToSourceError] == NO) {
      DDLogError(@"could not move destination store to the source store");
      DDLogError(@"destination store:  '%@'", storePath);
      DDLogError(@"      source path:   '%@'", [aSourceStoreURL path]);
      DDLogError(@"       error: %@", [moveDestinationToSourceError localizedDescription]);
      if (aError != NULL) { *aError = moveDestinationToSourceError; }
      
      // try to back out the source move first, no point in checking it for errors
      [[NSFileManager defaultManager] moveItemAtPath:backupPath
                                              toPath:[aSourceStoreURL path]
                                               error:nil];
      return NO;
    }
        
    return YES;
  }
}


@end
