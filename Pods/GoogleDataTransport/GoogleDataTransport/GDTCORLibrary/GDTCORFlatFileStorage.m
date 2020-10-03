/*
 * Copyright 2018 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

<<<<<<< HEAD
#import "GDTCORLibrary/Private/GDTCORFlatFileStorage.h"

#import <GoogleDataTransport/GDTCORAssert.h>
#import <GoogleDataTransport/GDTCORConsoleLogger.h>
#import <GoogleDataTransport/GDTCOREvent.h>
#import <GoogleDataTransport/GDTCORLifecycle.h>
#import <GoogleDataTransport/GDTCORPrioritizer.h>

#import "GDTCORLibrary/Private/GDTCOREvent_Private.h"
#import "GDTCORLibrary/Private/GDTCORRegistrar_Private.h"
#import "GDTCORLibrary/Private/GDTCORUploadCoordinator.h"

@implementation GDTCORFlatFileStorage

+ (void)load {
  [[GDTCORRegistrar sharedInstance] registerStorage:[self sharedInstance] target:kGDTCORTargetCCT];
  [[GDTCORRegistrar sharedInstance] registerStorage:[self sharedInstance] target:kGDTCORTargetFLL];
  [[GDTCORRegistrar sharedInstance] registerStorage:[self sharedInstance] target:kGDTCORTargetCSH];

  // Sets a global translation mapping to decode GDTCORStoredEvent objects encoded as instances of
  // GDTCOREvent instead. Then we do the same thing with GDTCORStorage. This must be done in load
  // because there are no direct references to this class and the NSCoding methods won't be called
  // unless the class name is mapped early.
  [NSKeyedUnarchiver setClass:[GDTCOREvent class] forClassName:@"GDTCORStoredEvent"];
  [NSKeyedUnarchiver setClass:[GDTCORFlatFileStorage class] forClassName:@"GDTCORStorage"];
}

+ (NSString *)archivePath {
  static NSString *archivePath;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    archivePath =
        [GDTCORRootDirectory() URLByAppendingPathComponent:@"GDTCORFlatFileStorageArchive"].path;
  });
  return archivePath;
}

+ (NSString *)libraryDataPath {
  static NSString *libraryDataPath;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    libraryDataPath =
        [GDTCORRootDirectory() URLByAppendingPathComponent:NSStringFromClass([self class])
                                               isDirectory:YES]
            .path;
    libraryDataPath = [libraryDataPath stringByAppendingPathComponent:@"gdt_library_data"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:libraryDataPath isDirectory:NULL]) {
      NSError *error;
      [[NSFileManager defaultManager] createDirectoryAtPath:libraryDataPath
                                withIntermediateDirectories:YES
                                                 attributes:0
                                                      error:&error];
      GDTCORAssert(error == nil, @"Creating the library data path failed: %@", error);
    }
  });
  return libraryDataPath;
=======
#import "GoogleDataTransport/GDTCORLibrary/Private/GDTCORFlatFileStorage.h"

#import "GoogleDataTransport/GDTCORLibrary/Public/GoogleDataTransport/GDTCORAssert.h"
#import "GoogleDataTransport/GDTCORLibrary/Public/GoogleDataTransport/GDTCORConsoleLogger.h"
#import "GoogleDataTransport/GDTCORLibrary/Public/GoogleDataTransport/GDTCOREvent.h"
#import "GoogleDataTransport/GDTCORLibrary/Public/GoogleDataTransport/GDTCORLifecycle.h"
#import "GoogleDataTransport/GDTCORLibrary/Public/GoogleDataTransport/GDTCORPlatform.h"
#import "GoogleDataTransport/GDTCORLibrary/Public/GoogleDataTransport/GDTCORStorageEventSelector.h"

#import "GoogleDataTransport/GDTCORLibrary/Private/GDTCOREvent_Private.h"
#import "GoogleDataTransport/GDTCORLibrary/Private/GDTCORRegistrar_Private.h"
#import "GoogleDataTransport/GDTCORLibrary/Private/GDTCORUploadCoordinator.h"

#import "GoogleDataTransport/GDTCORLibrary/Internal/GDTCORDirectorySizeTracker.h"

NS_ASSUME_NONNULL_BEGIN

/** A library data key this class uses to track batchIDs. */
static NSString *const gBatchIDCounterKey = @"GDTCORFlatFileStorageBatchIDCounter";

/** The separator used between metadata elements in filenames. */
static NSString *const kMetadataSeparator = @"-";

NSString *const kGDTCOREventComponentsEventIDKey = @"GDTCOREventComponentsEventIDKey";

NSString *const kGDTCOREventComponentsQoSTierKey = @"GDTCOREventComponentsQoSTierKey";

NSString *const kGDTCOREventComponentsMappingIDKey = @"GDTCOREventComponentsMappingIDKey";

NSString *const kGDTCOREventComponentsExpirationKey = @"GDTCOREventComponentsExpirationKey";

NSString *const kGDTCORBatchComponentsTargetKey = @"GDTCORBatchComponentsTargetKey";

NSString *const kGDTCORBatchComponentsBatchIDKey = @"GDTCORBatchComponentsBatchIDKey";

NSString *const kGDTCORBatchComponentsExpirationKey = @"GDTCORBatchComponentsExpirationKey";

NSString *const GDTCORFlatFileStorageErrorDomain = @"GDTCORFlatFileStorage";

const uint64_t kGDTCORFlatFileStorageSizeLimit = 20 * 1000 * 1000;  // 20 MB.

@interface GDTCORFlatFileStorage ()

/** An instance of the size tracker to keep track of the disk space consumed by the storage. */
@property(nonatomic, readonly) GDTCORDirectorySizeTracker *sizeTracker;

@end

@implementation GDTCORFlatFileStorage

@synthesize sizeTracker = _sizeTracker;

+ (void)load {
#if !NDEBUG
  [[GDTCORRegistrar sharedInstance] registerStorage:[self sharedInstance] target:kGDTCORTargetTest];
#endif  // !NDEBUG
  [[GDTCORRegistrar sharedInstance] registerStorage:[self sharedInstance] target:kGDTCORTargetCCT];
  [[GDTCORRegistrar sharedInstance] registerStorage:[self sharedInstance] target:kGDTCORTargetFLL];
  [[GDTCORRegistrar sharedInstance] registerStorage:[self sharedInstance] target:kGDTCORTargetCSH];
  [[GDTCORRegistrar sharedInstance] registerStorage:[self sharedInstance] target:kGDTCORTargetINT];
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
}

+ (instancetype)sharedInstance {
  static GDTCORFlatFileStorage *sharedStorage;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedStorage = [[GDTCORFlatFileStorage alloc] init];
  });
  return sharedStorage;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _storageQueue =
        dispatch_queue_create("com.google.GDTCORFlatFileStorage", DISPATCH_QUEUE_SERIAL);
<<<<<<< HEAD
    _targetToEventSet = [[NSMutableDictionary alloc] init];
    _storedEvents = [[NSMutableDictionary alloc] init];
=======
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
    _uploadCoordinator = [GDTCORUploadCoordinator sharedInstance];
  }
  return self;
}

<<<<<<< HEAD
- (void)storeEvent:(GDTCOREvent *)event
        onComplete:(void (^_Nullable)(BOOL wasWritten, NSError *_Nullable error))completion {
  GDTCORLogDebug(@"Saving event: %@", event);
  if (event == nil) {
    GDTCORLogDebug(@"%@", @"The event was nil, so it was not saved.");
    return;
  }
  BOOL hadOriginalCompletion = completion != nil;
=======
- (GDTCORDirectorySizeTracker *)sizeTracker {
  if (_sizeTracker == nil) {
    _sizeTracker =
        [[GDTCORDirectorySizeTracker alloc] initWithDirectoryPath:GDTCORRootDirectory().path];
  }
  return _sizeTracker;
}

#pragma mark - GDTCORStorageProtocol

- (void)storeEvent:(GDTCOREvent *)event
        onComplete:(void (^_Nullable)(BOOL wasWritten, NSError *_Nullable error))completion {
  GDTCORLogDebug(@"Saving event: %@", event);
  if (event == nil || event.serializedDataObjectBytes == nil) {
    GDTCORLogDebug(@"%@", @"The event was nil, so it was not saved.");
    if (completion) {
      completion(NO, [NSError errorWithDomain:NSInternalInconsistencyException
                                         code:-1
                                     userInfo:nil]);
    }
    return;
  }
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
  if (!completion) {
    completion = ^(BOOL wasWritten, NSError *_Nullable error) {
      GDTCORLogDebug(@"event %@ stored. success:%@ error:%@", event, wasWritten ? @"YES" : @"NO",
                     error);
    };
  }

  __block GDTCORBackgroundIdentifier bgID = GDTCORBackgroundIdentifierInvalid;
  bgID = [[GDTCORApplication sharedApplication]
      beginBackgroundTaskWithName:@"GDTStorage"
                expirationHandler:^{
                  // End the background task if it's still valid.
                  [[GDTCORApplication sharedApplication] endBackgroundTask:bgID];
                  bgID = GDTCORBackgroundIdentifierInvalid;
                }];

  dispatch_async(_storageQueue, ^{
    // Check that a backend implementation is available for this target.
<<<<<<< HEAD
    NSInteger target = event.target;

    // Check that a prioritizer is available for this target.
    id<GDTCORPrioritizer> prioritizer =
        [GDTCORRegistrar sharedInstance].targetToPrioritizer[@(target)];
    GDTCORAssert(prioritizer, @"There's no prioritizer registered for the given target. Are you "
                              @"sure you've added the support library for the backend you need?");

    // Write the transport bytes to disk, get a filename.
    GDTCORAssert([event.dataObject transportBytes],
                 @"The event should have been serialized to bytes");
    NSError *error = nil;
    NSURL *eventFile = [self saveEventBytesToDisk:event eventHash:event.hash error:&error];
    if (!eventFile || error) {
      GDTCORLogError(GDTCORMCEFileWriteError, @"Event failed to save to disk: %@", error);
      completion(NO, error);
      return;
    } else {
      GDTCORLogDebug(@"Event saved to disk: %@", eventFile);
      completion(YES, error);
    }

    // Add event to tracking collections.
    [self addEventToTrackingCollections:event];

    // Have the prioritizer prioritize the event and save state if there was an onComplete block.
    [prioritizer prioritizeEvent:event];
    if (hadOriginalCompletion && [prioritizer respondsToSelector:@selector(saveState)]) {
      [prioritizer saveState];
      GDTCORLogDebug(@"Prioritizer %@ has saved state due to an event's onComplete block.",
                     prioritizer);
    }

    // Check the QoS, if it's high priority, notify the target that it has a high priority event.
    if (event.qosTier == GDTCOREventQoSFast) {
      [self.uploadCoordinator forceUploadForTarget:target];
    }

    // Write state to disk if there was an onComplete block or if we're in the background.
    if (hadOriginalCompletion || [[GDTCORApplication sharedApplication] isRunningInBackground]) {
      if (hadOriginalCompletion) {
        GDTCORLogDebug(@"%@",
                       @"Saving flat file storage state because a completion block was passed.");
      } else {
        GDTCORLogDebug(
            @"%@", @"Saving flat file storage state because the app is running in the background");
      }
      NSError *error;
      GDTCOREncodeArchive(self, [GDTCORFlatFileStorage archivePath], &error);
      if (error) {
        GDTCORLogDebug(@"Serializing GDTCORFlatFileStorage to an archive failed: %@", error);
      }
    }

    // Cancel or end the associated background task if it's still valid.
    [[GDTCORApplication sharedApplication] endBackgroundTask:bgID];
    bgID = GDTCORBackgroundIdentifierInvalid;
    GDTCORLogDebug(@"Event %@ is stored. There are %ld events stored on disk", event,
                   (unsigned long)self->_storedEvents.count);
  });
}

- (void)removeEvents:(NSSet<NSNumber *> *)eventIDs {
  NSSet<NSNumber *> *eventsToRemove = [eventIDs copy];
  dispatch_async(_storageQueue, ^{
    for (NSNumber *eventID in eventsToRemove) {
      // Remove from disk, first and foremost.
      GDTCOREvent *event = self->_storedEvents[eventID];
      if (event) {
        NSError *error;
        if (event.fileURL) {
          NSURL *fileURL = event.fileURL;
          BOOL result = [[NSFileManager defaultManager] removeItemAtPath:fileURL.path error:&error];
          if (!result || error) {
            GDTCORLogWarning(GDTCORMCWFileReadError,
                             @"There was an error removing an event file: %@", error);
          } else {
            GDTCORLogDebug(@"Removed event from disk: %@", fileURL);
          }
        }

        // Remove from the tracking collections.
        [self.storedEvents removeObjectForKey:event.eventID];
        [self.targetToEventSet[@(event.target)] removeObject:event];
      }
=======
    GDTCORTarget target = event.target;
    NSString *filePath = [GDTCORFlatFileStorage pathForTarget:target
                                                      eventID:event.eventID
                                                      qosTier:@(event.qosTier)
                                               expirationDate:event.expirationDate
                                                    mappingID:event.mappingID];
    NSError *error;
    NSData *encodedEvent = GDTCOREncodeArchive(event, nil, &error);
    if (error) {
      completion(NO, error);
      return;
    }

    // Check storage size limit before storing the event.
    uint64_t resultingStorageSize = self.sizeTracker.directoryContentSize + encodedEvent.length;
    if (resultingStorageSize > kGDTCORFlatFileStorageSizeLimit) {
      NSError *error = [NSError
          errorWithDomain:GDTCORFlatFileStorageErrorDomain
                     code:GDTCORFlatFileStorageErrorSizeLimitReached
                 userInfo:@{
                   NSLocalizedFailureReasonErrorKey : @"Storage size limit has been reached."
                 }];
      completion(NO, error);
      return;
    }

    // Write the encoded event to the file.
    BOOL writeResult = GDTCORWriteDataToFile(encodedEvent, filePath, &error);
    if (writeResult == NO || error) {
      GDTCORLogDebug(@"Attempt to write archive failed: path:%@ error:%@", filePath, error);
      completion(NO, error);
      return;
    } else {
      GDTCORLogDebug(@"Writing archive succeeded: %@", filePath);
      completion(YES, nil);
    }

    // Notify size tracker.
    [self.sizeTracker fileWasAddedAtPath:filePath withSize:encodedEvent.length];

    // Check the QoS, if it's high priority, notify the target that it has a high priority event.
    if (event.qosTier == GDTCOREventQoSFast) {
      // TODO: Remove a direct dependency on the upload coordinator.
      [self.uploadCoordinator forceUploadForTarget:target];
    }

    // Cancel or end the associated background task if it's still valid.
    [[GDTCORApplication sharedApplication] endBackgroundTask:bgID];
    bgID = GDTCORBackgroundIdentifierInvalid;
  });
}

- (void)batchWithEventSelector:(nonnull GDTCORStorageEventSelector *)eventSelector
               batchExpiration:(nonnull NSDate *)expiration
                    onComplete:
                        (nonnull void (^)(NSNumber *_Nullable batchID,
                                          NSSet<GDTCOREvent *> *_Nullable events))onComplete {
  dispatch_queue_t queue = _storageQueue;
  void (^onPathsForTargetComplete)(NSNumber *, NSSet<NSString *> *_Nonnull) = ^(
      NSNumber *batchID, NSSet<NSString *> *_Nonnull paths) {
    dispatch_async(queue, ^{
      NSMutableSet<GDTCOREvent *> *events = [[NSMutableSet alloc] init];
      for (NSString *eventPath in paths) {
        NSError *error;
        GDTCOREvent *event =
            (GDTCOREvent *)GDTCORDecodeArchive([GDTCOREvent class], eventPath, nil, &error);
        if (event == nil || error) {
          GDTCORLogDebug(@"Error deserializing event: %@", error);
          [[NSFileManager defaultManager] removeItemAtPath:eventPath error:nil];
          continue;
        } else {
          NSString *fileName = [eventPath lastPathComponent];
          NSString *batchPath =
              [GDTCORFlatFileStorage batchPathForTarget:eventSelector.selectedTarget
                                                batchID:batchID
                                         expirationDate:expiration];
          [[NSFileManager defaultManager] createDirectoryAtPath:batchPath
                                    withIntermediateDirectories:YES
                                                     attributes:nil
                                                          error:nil];
          NSString *destinationPath = [batchPath stringByAppendingPathComponent:fileName];
          error = nil;
          [[NSFileManager defaultManager] moveItemAtPath:eventPath
                                                  toPath:destinationPath
                                                   error:&error];
          if (error) {
            GDTCORLogDebug(@"An event file wasn't moveable into the batch directory: %@", error);
          }
          [events addObject:event];
        }
      }
      if (onComplete) {
        if (events.count == 0) {
          onComplete(nil, nil);
        } else {
          onComplete(batchID, events);
        }
      }
    });
  };

  void (^onBatchIDFetchComplete)(NSNumber *) = ^(NSNumber *batchID) {
    dispatch_async(queue, ^{
      if (batchID == nil) {
        if (onComplete) {
          onComplete(nil, nil);
          return;
        }
      }
      [self pathsForTarget:eventSelector.selectedTarget
                  eventIDs:eventSelector.selectedEventIDs
                  qosTiers:eventSelector.selectedQosTiers
                mappingIDs:eventSelector.selectedMappingIDs
                onComplete:^(NSSet<NSString *> *_Nonnull paths) {
                  onPathsForTargetComplete(batchID, paths);
                }];
    });
  };

  [self nextBatchID:^(NSNumber *_Nullable batchID) {
    if (batchID == nil) {
      if (onComplete) {
        onComplete(nil, nil);
      }
    } else {
      onBatchIDFetchComplete(batchID);
    }
  }];
}

- (void)removeBatchWithID:(nonnull NSNumber *)batchID
             deleteEvents:(BOOL)deleteEvents
               onComplete:(void (^_Nullable)(void))onComplete {
  dispatch_async(_storageQueue, ^{
    [self syncThreadUnsafeRemoveBatchWithID:batchID deleteEvents:deleteEvents];

    if (onComplete) {
      onComplete();
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
    }
  });
}

<<<<<<< HEAD
#pragma mark - GDTCORStorageProtocol

- (void)libraryDataForKey:(nonnull NSString *)key
               onComplete:
                   (nonnull void (^)(NSData *_Nullable, NSError *_Nullable error))onComplete {
  dispatch_async(_storageQueue, ^{
    NSString *dataPath = [[[self class] libraryDataPath] stringByAppendingPathComponent:key];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:dataPath options:0 error:&error];
    if (onComplete) {
      onComplete(data, error);
=======
- (void)batchIDsForTarget:(GDTCORTarget)target
               onComplete:(nonnull void (^)(NSSet<NSNumber *> *_Nullable))onComplete {
  dispatch_async(_storageQueue, ^{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray<NSString *> *batchPaths =
        [fileManager contentsOfDirectoryAtPath:[GDTCORFlatFileStorage batchDataStoragePath]
                                         error:&error];
    if (error || batchPaths.count == 0) {
      if (onComplete) {
        onComplete(nil);
      }
      return;
    }
    NSMutableSet<NSNumber *> *batchIDs = [[NSMutableSet alloc] init];
    for (NSString *path in batchPaths) {
      NSDictionary<NSString *, id> *components = [self batchComponentsFromFilename:path];
      NSNumber *targetNumber = components[kGDTCORBatchComponentsTargetKey];
      NSNumber *batchID = components[kGDTCORBatchComponentsBatchIDKey];
      if (targetNumber.intValue == target) {
        [batchIDs addObject:batchID];
      }
    }
    if (onComplete) {
      onComplete(batchIDs);
    }
  });
}

- (void)libraryDataForKey:(nonnull NSString *)key
          onFetchComplete:(nonnull void (^)(NSData *_Nullable, NSError *_Nullable))onFetchComplete
              setNewValue:(NSData *_Nullable (^_Nullable)(void))setValueBlock {
  dispatch_async(_storageQueue, ^{
    NSString *dataPath = [[[self class] libraryDataStoragePath] stringByAppendingPathComponent:key];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:dataPath options:0 error:&error];
    if (onFetchComplete) {
      onFetchComplete(data, error);
    }
    if (setValueBlock) {
      NSData *newValue = setValueBlock();
      // The -isKindOfClass check is necessary because without an explicit 'return nil' in the block
      // the implicit return value will be the block itself. The compiler doesn't detect this.
      if (newValue != nil && [newValue isKindOfClass:[NSData class]] && newValue.length) {
        NSError *newValueError;
        if ([newValue writeToFile:dataPath options:NSDataWritingAtomic error:&newValueError]) {
          // Update storage size.
          [self.sizeTracker fileWasRemovedAtPath:dataPath withSize:data.length];
          [self.sizeTracker fileWasAddedAtPath:dataPath withSize:newValue.length];
        } else {
          GDTCORLogDebug(@"Error writing new value in libraryDataForKey: %@", newValueError);
        }
      }
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
    }
  });
}

- (void)storeLibraryData:(NSData *)data
                  forKey:(nonnull NSString *)key
<<<<<<< HEAD
              onComplete:(nonnull void (^)(NSError *_Nullable error))onComplete {
=======
              onComplete:(nullable void (^)(NSError *_Nullable error))onComplete {
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
  if (!data || data.length <= 0) {
    if (onComplete) {
      onComplete([NSError errorWithDomain:NSInternalInconsistencyException code:-1 userInfo:nil]);
    }
    return;
  }
  dispatch_async(_storageQueue, ^{
    NSError *error;
<<<<<<< HEAD
    NSString *dataPath = [[[self class] libraryDataPath] stringByAppendingPathComponent:key];
    [data writeToFile:dataPath options:NSDataWritingAtomic error:&error];
=======
    NSString *dataPath = [[[self class] libraryDataStoragePath] stringByAppendingPathComponent:key];
    if ([data writeToFile:dataPath options:NSDataWritingAtomic error:&error]) {
      [self.sizeTracker fileWasAddedAtPath:dataPath withSize:data.length];
    }
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
    if (onComplete) {
      onComplete(error);
    }
  });
}

- (void)removeLibraryDataForKey:(nonnull NSString *)key
                     onComplete:(nonnull void (^)(NSError *_Nullable error))onComplete {
  dispatch_async(_storageQueue, ^{
    NSError *error;
<<<<<<< HEAD
    NSString *dataPath = [[[self class] libraryDataPath] stringByAppendingPathComponent:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
      [[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error];
=======
    NSString *dataPath = [[[self class] libraryDataStoragePath] stringByAppendingPathComponent:key];
    GDTCORStorageSizeBytes fileSize =
        [self.sizeTracker fileSizeAtURL:[NSURL fileURLWithPath:dataPath]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
      if ([[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error]) {
        [self.sizeTracker fileWasRemovedAtPath:dataPath withSize:fileSize];
      }
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
      if (onComplete) {
        onComplete(error);
      }
    }
  });
}

<<<<<<< HEAD
#pragma mark - Private helper methods

/** Saves the event's dataObject to a file using NSData mechanisms.
 *
 * @note This method should only be called from a method within a block on _storageQueue to maintain
 * thread safety.
 *
 * @param event The event.
 * @param eventHash The hash value of the event.
 * @return The filename
 */
- (NSURL *)saveEventBytesToDisk:(GDTCOREvent *)event
                      eventHash:(NSUInteger)eventHash
                          error:(NSError **)error {
  NSString *eventFileName = [NSString stringWithFormat:@"event-%lu", (unsigned long)eventHash];
  NSError *writingError;
  [event writeToGDTPath:eventFileName error:&writingError];
  if (writingError) {
    GDTCORLogDebug(@"There was an error saving an event to disk: %@", writingError);
  }
  return event.fileURL;
}

/** Adds the event to internal tracking collections.
 *
 * @note This method should only be called from a method within a block on _storageQueue to maintain
 * thread safety.
 *
 * @param event The event to track.
 */
- (void)addEventToTrackingCollections:(GDTCOREvent *)event {
  _storedEvents[event.eventID] = event;
  NSNumber *target = @(event.target);
  NSMutableSet<GDTCOREvent *> *events = self.targetToEventSet[target];
  events = events ? events : [[NSMutableSet alloc] init];
  [events addObject:event];
  _targetToEventSet[target] = events;
}

#pragma mark - GDTCORLifecycleProtocol

- (void)appWillForeground:(GDTCORApplication *)app {
  dispatch_async(_storageQueue, ^{
    NSError *error;
    GDTCORDecodeArchive([GDTCORFlatFileStorage class], [GDTCORFlatFileStorage archivePath], nil,
                        &error);
    if (error) {
      GDTCORLogDebug(@"Deserializing GDTCORFlatFileStorage from an archive failed: %@", error);
    }
  });
}

- (void)appWillBackground:(GDTCORApplication *)app {
  dispatch_async(_storageQueue, ^{
    // Immediately request a background task to run until the end of the current queue of work, and
    // cancel it once the work is done.
    __block GDTCORBackgroundIdentifier bgID =
        [app beginBackgroundTaskWithName:@"GDTStorage"
                       expirationHandler:^{
                         [app endBackgroundTask:bgID];
                         bgID = GDTCORBackgroundIdentifierInvalid;
                       }];
    NSError *error;
    GDTCOREncodeArchive(self, [GDTCORFlatFileStorage archivePath], &error);
    if (error) {
      GDTCORLogDebug(@"Serializing GDTCORFlatFileStorage to an archive failed: %@", error);
    } else {
      GDTCORLogDebug(@"Serialized GDTCORFlatFileStorage to %@",
                     [GDTCORFlatFileStorage archivePath]);
    }

    // End the background task if it's still valid.
    [app endBackgroundTask:bgID];
    bgID = GDTCORBackgroundIdentifierInvalid;
  });
}

- (void)appWillTerminate:(GDTCORApplication *)application {
  dispatch_sync(_storageQueue, ^{
    NSError *error;
    GDTCOREncodeArchive(self, [GDTCORFlatFileStorage archivePath], &error);
    if (error) {
      GDTCORLogDebug(@"Serializing GDTCORFlatFileStorage to an archive failed: %@", error);
    } else {
      GDTCORLogDebug(@"Serialized GDTCORFlatFileStorage to %@",
                     [GDTCORFlatFileStorage archivePath]);
    }
  });
}

#pragma mark - NSSecureCoding

/** The NSKeyedCoder key for the storedEvents property. */
static NSString *const kGDTCORFlatFileStorageStoredEventsKey = @"GDTCORStorageStoredEventsKey";

/** The NSKeyedCoder key for the targetToEventSet property. */
static NSString *const kGDTCORFlatFileStorageTargetToEventSetKey =
    @"GDTCORStorageTargetToEventSetKey";

/** The NSKeyedCoder key for the uploadCoordinator property. */
static NSString *const kGDTCORFlatFileStorageUploadCoordinatorKey =
    @"GDTCORStorageUploadCoordinatorKey";

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  // Create the singleton and populate its ivars.
  GDTCORFlatFileStorage *sharedInstance = [self.class sharedInstance];
  NSSet *classes = [NSSet setWithObjects:[NSMutableOrderedSet class], [NSMutableDictionary class],
                                         [GDTCOREvent class], nil];
  id storedEvents = [aDecoder decodeObjectOfClasses:classes
                                             forKey:kGDTCORFlatFileStorageStoredEventsKey];
  NSMutableDictionary<NSNumber *, GDTCOREvent *> *events = [[NSMutableDictionary alloc] init];
  if ([storedEvents isKindOfClass:[NSMutableOrderedSet class]]) {
    [(NSMutableOrderedSet *)storedEvents
        enumerateObjectsUsingBlock:^(GDTCOREvent *_Nonnull obj, NSUInteger idx,
                                     BOOL *_Nonnull stop) {
          events[obj.eventID] = obj;
        }];
  } else if ([storedEvents isKindOfClass:[NSMutableDictionary class]]) {
    events = (NSMutableDictionary *)storedEvents;
  }
  sharedInstance->_storedEvents = events;
  classes = [NSSet
      setWithObjects:[NSMutableDictionary class], [NSMutableSet class], [GDTCOREvent class], nil];
  sharedInstance->_targetToEventSet =
      [aDecoder decodeObjectOfClasses:classes forKey:kGDTCORFlatFileStorageTargetToEventSetKey];
  sharedInstance->_uploadCoordinator =
      [aDecoder decodeObjectOfClass:[GDTCORUploadCoordinator class]
                             forKey:kGDTCORFlatFileStorageUploadCoordinatorKey];
  return sharedInstance;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  GDTCORFlatFileStorage *sharedInstance = [self.class sharedInstance];
  NSMutableDictionary<NSNumber *, GDTCOREvent *> *storedEvents = sharedInstance->_storedEvents;
  if (storedEvents) {
    [aCoder encodeObject:storedEvents forKey:kGDTCORFlatFileStorageStoredEventsKey];
  }
  NSMutableDictionary<NSNumber *, NSMutableSet<GDTCOREvent *> *> *targetToEventSet =
      sharedInstance->_targetToEventSet;
  if (targetToEventSet) {
    [aCoder encodeObject:targetToEventSet forKey:kGDTCORFlatFileStorageTargetToEventSetKey];
  }
  GDTCORUploadCoordinator *uploadCoordinator = sharedInstance->_uploadCoordinator;
  if (uploadCoordinator) {
    [aCoder encodeObject:uploadCoordinator forKey:kGDTCORFlatFileStorageUploadCoordinatorKey];
  }
}

@end
=======
- (void)hasEventsForTarget:(GDTCORTarget)target onComplete:(void (^)(BOOL hasEvents))onComplete {
  dispatch_async(_storageQueue, ^{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *targetPath = [NSString
        stringWithFormat:@"%@/%ld", [GDTCORFlatFileStorage eventDataStoragePath], (long)target];
    [fileManager createDirectoryAtPath:targetPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:targetPath];
    BOOL hasEventAtLeastOneEvent = [enumerator nextObject] != nil;
    if (onComplete) {
      onComplete(hasEventAtLeastOneEvent);
    }
  });
}

- (void)checkForExpirations {
  dispatch_async(_storageQueue, ^{
    GDTCORLogDebug(@"%@", @"Checking for expired events and batches");
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // TODO: Storage may not have enough context to remove batches because a batch may be being
    // uploaded but the storage has not context of it.

    // Find expired batches and move their events back to the main storage.
    // If a batch contains expired events they are expected to be removed further in the method
    // together with other expired events in the main storage.
    NSString *batchDataPath = [GDTCORFlatFileStorage batchDataStoragePath];
    NSArray<NSString *> *batchDataPaths = [fileManager contentsOfDirectoryAtPath:batchDataPath
                                                                           error:nil];
    for (NSString *path in batchDataPaths) {
      NSString *fileName = [path lastPathComponent];
      NSDictionary<NSString *, id> *batchComponents = [self batchComponentsFromFilename:fileName];
      NSDate *expirationDate = batchComponents[kGDTCORBatchComponentsExpirationKey];
      NSNumber *batchID = batchComponents[kGDTCORBatchComponentsBatchIDKey];
      if (expirationDate != nil && expirationDate.timeIntervalSince1970 < now && batchID != nil) {
        NSNumber *batchID = batchComponents[kGDTCORBatchComponentsBatchIDKey];
        // Move all events from the expired batch back to the main storage.
        [self syncThreadUnsafeRemoveBatchWithID:batchID deleteEvents:NO];
      }
    }

    // Find expired events and remove them from the storage.
    NSString *eventDataPath = [GDTCORFlatFileStorage eventDataStoragePath];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:eventDataPath];
    NSString *path;
    while ((path = [enumerator nextObject])) {
      NSString *fileName = [path lastPathComponent];
      NSDictionary<NSString *, id> *eventComponents = [self eventComponentsFromFilename:fileName];
      NSDate *expirationDate = eventComponents[kGDTCOREventComponentsExpirationKey];
      if (expirationDate != nil && expirationDate.timeIntervalSince1970 < now) {
        NSString *pathToDelete = [eventDataPath stringByAppendingPathComponent:path];
        NSError *error;
        [fileManager removeItemAtPath:pathToDelete error:&error];
        if (error != nil) {
          GDTCORLogDebug(@"There was an error deleting an expired item: %@", error);
        } else {
          GDTCORLogDebug(@"Item deleted because it expired: %@", pathToDelete);
        }
      }
    }

    [self.sizeTracker resetCachedSize];
  });
}

- (void)storageSizeWithCallback:(void (^)(uint64_t storageSize))onComplete {
  if (!onComplete) {
    return;
  }

  dispatch_async(_storageQueue, ^{
    onComplete([self.sizeTracker directoryContentSize]);
  });
}

#pragma mark - Private not thread safe methods
/** Looks for directory paths containing events for a batch with the specified ID.
 * @param batchID A batch ID.
 * @param outError A pointer to `NSError *` to assign as possible error to.
 * @return An array of an array of paths to directories for event batches with a specified batch ID
 * or `nil` in the case of an error. Usually returns a single path but potentially return more in
 * cases when the app is terminated while uploading a batch.
 */
- (nullable NSArray<NSString *> *)batchDirPathsForBatchID:(NSNumber *)batchID
                                                    error:(NSError **)outError {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error;
  NSArray<NSString *> *batches =
      [fileManager contentsOfDirectoryAtPath:[GDTCORFlatFileStorage batchDataStoragePath]
                                       error:&error];
  if (batches == nil) {
    *outError = error;
    GDTCORLogDebug(@"Failed to find event file paths for batchID: %@, error: %@", batchID, error);
    return nil;
  }

  NSMutableArray<NSString *> *batchDirPaths = [NSMutableArray array];
  for (NSString *path in batches) {
    NSDictionary<NSString *, id> *components = [self batchComponentsFromFilename:path];
    NSNumber *pathBatchID = components[kGDTCORBatchComponentsBatchIDKey];
    if ([pathBatchID isEqual:batchID]) {
      NSString *batchDirPath =
          [[GDTCORFlatFileStorage batchDataStoragePath] stringByAppendingPathComponent:path];
      [batchDirPaths addObject:batchDirPath];
    }
  }

  return [batchDirPaths copy];
}

/** Makes a copy of the contents of a directory to a directory at the specified path.*/
- (BOOL)moveContentsOfDirectoryAtPath:(NSString *)sourcePath
                                   to:(NSString *)destinationPath
                                error:(NSError **)outError {
  NSFileManager *fileManager = [NSFileManager defaultManager];

  NSError *error;
  NSArray<NSString *> *contentsPaths = [fileManager contentsOfDirectoryAtPath:sourcePath
                                                                        error:&error];
  if (contentsPaths == nil) {
    *outError = error;
    return NO;
  }

  NSMutableArray<NSError *> *errors = [NSMutableArray array];
  for (NSString *path in contentsPaths) {
    NSString *contentDestinationPath = [destinationPath stringByAppendingPathComponent:path];
    NSString *contentSourcePath = [sourcePath stringByAppendingPathComponent:path];

    NSError *moveError;
    if (![fileManager moveItemAtPath:contentSourcePath
                              toPath:contentDestinationPath
                               error:&moveError] &&
        moveError) {
      [errors addObject:moveError];
    }
  }

  if (errors.count == 0) {
    return YES;
  } else {
    NSError *combinedError = [NSError errorWithDomain:@"GDTCORFlatFileStorage"
                                                 code:-1
                                             userInfo:@{NSUnderlyingErrorKey : errors}];
    *outError = combinedError;
    return NO;
  }
}

- (void)syncThreadUnsafeRemoveBatchWithID:(nonnull NSNumber *)batchID
                             deleteEvents:(BOOL)deleteEvents {
  NSError *error;
  NSArray<NSString *> *batchDirPaths = [self batchDirPathsForBatchID:batchID error:&error];

  if (batchDirPaths == nil) {
    return;
  }

  NSFileManager *fileManager = [NSFileManager defaultManager];

  void (^removeBatchDir)(NSString *batchDirPath) = ^(NSString *batchDirPath) {
    NSError *error;
    if ([fileManager removeItemAtPath:batchDirPath error:&error]) {
      GDTCORLogDebug(@"Batch removed at path: %@", batchDirPath);
    } else {
      GDTCORLogDebug(@"Failed to remove batch at path: %@", batchDirPath);
    }
  };

  for (NSString *batchDirPath in batchDirPaths) {
    if (deleteEvents) {
      removeBatchDir(batchDirPath);
    } else {
      NSString *batchDirName = [batchDirPath lastPathComponent];
      NSDictionary<NSString *, id> *components = [self batchComponentsFromFilename:batchDirName];
      NSNumber *target = components[kGDTCORBatchComponentsTargetKey];
      NSString *destinationPath = [[GDTCORFlatFileStorage eventDataStoragePath]
          stringByAppendingPathComponent:target.stringValue];

      // `- [NSFileManager moveItemAtPath:toPath:error:]` method fails if an item by the
      // destination path already exists (which usually is the case for the current method). Move
      // the events one by one instead.
      if ([self moveContentsOfDirectoryAtPath:batchDirPath to:destinationPath error:&error]) {
        GDTCORLogDebug(@"Batched events at path: %@ moved back to the storage: %@", batchDirPath,
                       destinationPath);
      } else {
        GDTCORLogDebug(@"Error encountered whilst moving events back: %@", error);
      }

      // Even if not all events where moved back to the storage, there is not much can be done at
      // this point, so cleanup batch directory now to avoid clattering.
      removeBatchDir(batchDirPath);
    }
  }

  [self.sizeTracker resetCachedSize];
}

#pragma mark - Private helper methods

+ (NSString *)eventDataStoragePath {
  static NSString *eventDataPath;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    eventDataPath = [NSString stringWithFormat:@"%@/%@/gdt_event_data", GDTCORRootDirectory().path,
                                               NSStringFromClass([self class])];
  });
  NSError *error;
  [[NSFileManager defaultManager] createDirectoryAtPath:eventDataPath
                            withIntermediateDirectories:YES
                                             attributes:0
                                                  error:&error];
  GDTCORAssert(error == nil, @"Creating the library data path failed: %@", error);
  return eventDataPath;
}

+ (NSString *)batchDataStoragePath {
  static NSString *batchDataPath;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    batchDataPath = [NSString stringWithFormat:@"%@/%@/gdt_batch_data", GDTCORRootDirectory().path,
                                               NSStringFromClass([self class])];
  });
  NSError *error;
  [[NSFileManager defaultManager] createDirectoryAtPath:batchDataPath
                            withIntermediateDirectories:YES
                                             attributes:0
                                                  error:&error];
  GDTCORAssert(error == nil, @"Creating the batch data path failed: %@", error);
  return batchDataPath;
}

+ (NSString *)libraryDataStoragePath {
  static NSString *libraryDataPath;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    libraryDataPath =
        [NSString stringWithFormat:@"%@/%@/gdt_library_data", GDTCORRootDirectory().path,
                                   NSStringFromClass([self class])];
  });
  NSError *error;
  [[NSFileManager defaultManager] createDirectoryAtPath:libraryDataPath
                            withIntermediateDirectories:YES
                                             attributes:0
                                                  error:&error];
  GDTCORAssert(error == nil, @"Creating the library data path failed: %@", error);
  return libraryDataPath;
}

+ (NSString *)batchPathForTarget:(GDTCORTarget)target
                         batchID:(NSNumber *)batchID
                  expirationDate:(NSDate *)expirationDate {
  return
      [NSString stringWithFormat:@"%@/%ld%@%@%@%llu", [GDTCORFlatFileStorage batchDataStoragePath],
                                 (long)target, kMetadataSeparator, batchID, kMetadataSeparator,
                                 ((uint64_t)expirationDate.timeIntervalSince1970)];
}

+ (NSString *)pathForTarget:(GDTCORTarget)target
                    eventID:(NSString *)eventID
                    qosTier:(NSNumber *)qosTier
             expirationDate:(NSDate *)expirationDate
                  mappingID:(NSString *)mappingID {
  NSMutableCharacterSet *allowedChars = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
  [allowedChars addCharactersInString:kMetadataSeparator];
  mappingID = [mappingID stringByAddingPercentEncodingWithAllowedCharacters:allowedChars];
  return [NSString stringWithFormat:@"%@/%ld/%@%@%@%@%llu%@%@",
                                    [GDTCORFlatFileStorage eventDataStoragePath], (long)target,
                                    eventID, kMetadataSeparator, qosTier, kMetadataSeparator,
                                    ((uint64_t)expirationDate.timeIntervalSince1970),
                                    kMetadataSeparator, mappingID];
}

- (void)pathsForTarget:(GDTCORTarget)target
              eventIDs:(nullable NSSet<NSString *> *)eventIDs
              qosTiers:(nullable NSSet<NSNumber *> *)qosTiers
            mappingIDs:(nullable NSSet<NSString *> *)mappingIDs
            onComplete:(void (^)(NSSet<NSString *> *paths))onComplete {
  void (^completion)(NSSet<NSString *> *) = onComplete == nil ? ^(NSSet<NSString *> *paths){} : onComplete;
  dispatch_async(_storageQueue, ^{
    NSMutableSet<NSString *> *paths = [[NSMutableSet alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *targetPath = [NSString
        stringWithFormat:@"%@/%ld", [GDTCORFlatFileStorage eventDataStoragePath], (long)target];
    [fileManager createDirectoryAtPath:targetPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    NSError *error;
    NSArray<NSString *> *dirPaths = [fileManager contentsOfDirectoryAtPath:targetPath error:&error];
    if (error) {
      GDTCORLogDebug(@"There was an error reading the contents of the target path: %@", error);
      completion(paths);
      return;
    }
    BOOL checkingIDs = eventIDs.count > 0;
    BOOL checkingQosTiers = qosTiers.count > 0;
    BOOL checkingMappingIDs = mappingIDs.count > 0;
    BOOL checkingAnything = checkingIDs == NO && checkingQosTiers == NO && checkingMappingIDs == NO;
    for (NSString *path in dirPaths) {
      // Skip hidden files that are created as part of atomic file creation.
      if ([path hasPrefix:@"."]) {
        continue;
      }
      NSString *filePath = [targetPath stringByAppendingPathComponent:path];
      if (checkingAnything) {
        [paths addObject:filePath];
        continue;
      }
      NSString *filename = [path lastPathComponent];
      NSDictionary<NSString *, id> *eventComponents = [self eventComponentsFromFilename:filename];
      if (!eventComponents) {
        GDTCORLogDebug(@"There was an error reading the filename components: %@", eventComponents);
        continue;
      }
      NSString *eventID = eventComponents[kGDTCOREventComponentsEventIDKey];
      NSNumber *qosTier = eventComponents[kGDTCOREventComponentsQoSTierKey];
      NSString *mappingID = eventComponents[kGDTCOREventComponentsMappingIDKey];

      NSNumber *eventIDMatch = checkingIDs ? @([eventIDs containsObject:eventID]) : nil;
      NSNumber *qosTierMatch = checkingQosTiers ? @([qosTiers containsObject:qosTier]) : nil;
      NSNumber *mappingIDMatch =
          checkingMappingIDs
              ? @([mappingIDs containsObject:[mappingID stringByRemovingPercentEncoding]])
              : nil;
      if ((eventIDMatch == nil || eventIDMatch.boolValue) &&
          (qosTierMatch == nil || qosTierMatch.boolValue) &&
          (mappingIDMatch == nil || mappingIDMatch.boolValue)) {
        [paths addObject:filePath];
      }
    }
    completion(paths);
  });
}

- (void)nextBatchID:(void (^)(NSNumber *_Nullable batchID))nextBatchID {
  __block int32_t lastBatchID = -1;
  [self libraryDataForKey:gBatchIDCounterKey
      onFetchComplete:^(NSData *_Nullable data, NSError *_Nullable getValueError) {
        if (!getValueError) {
          [data getBytes:(void *)&lastBatchID length:sizeof(int32_t)];
        }
        if (data == nil) {
          lastBatchID = 0;
        }
        if (nextBatchID) {
          nextBatchID(@(lastBatchID));
        }
      }
      setNewValue:^NSData *_Nullable(void) {
        if (lastBatchID != -1) {
          int32_t incrementedValue = lastBatchID + 1;
          return [NSData dataWithBytes:&incrementedValue length:sizeof(int32_t)];
        }
        return nil;
      }];
}

- (nullable NSDictionary<NSString *, id> *)eventComponentsFromFilename:(NSString *)fileName {
  NSArray<NSString *> *components = [fileName componentsSeparatedByString:kMetadataSeparator];
  if (components.count >= 4) {
    NSString *eventID = components[0];
    NSNumber *qosTier = @(components[1].integerValue);
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:components[2].longLongValue];
    NSString *mappingID = [[components subarrayWithRange:NSMakeRange(3, components.count - 3)]
        componentsJoinedByString:kMetadataSeparator];
    if (eventID == nil || qosTier == nil || mappingID == nil || expirationDate == nil) {
      GDTCORLogDebug(@"There was an error parsing the event filename components: %@", components);
      return nil;
    }
    return @{
      kGDTCOREventComponentsEventIDKey : eventID,
      kGDTCOREventComponentsQoSTierKey : qosTier,
      kGDTCOREventComponentsExpirationKey : expirationDate,
      kGDTCOREventComponentsMappingIDKey : mappingID
    };
  }
  GDTCORLogDebug(@"The event filename could not be split: %@", fileName);
  return nil;
}

- (nullable NSDictionary<NSString *, id> *)batchComponentsFromFilename:(NSString *)fileName {
  NSArray<NSString *> *components = [fileName componentsSeparatedByString:kMetadataSeparator];
  if (components.count == 3) {
    NSNumber *target = @(components[0].integerValue);
    NSNumber *batchID = @(components[1].integerValue);
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:components[2].doubleValue];
    if (target == nil || batchID == nil || expirationDate == nil) {
      GDTCORLogDebug(@"There was an error parsing the batch filename components: %@", components);
      return nil;
    }
    return @{
      kGDTCORBatchComponentsTargetKey : target,
      kGDTCORBatchComponentsBatchIDKey : batchID,
      kGDTCORBatchComponentsExpirationKey : expirationDate
    };
  }
  GDTCORLogDebug(@"The batch filename could not be split: %@", fileName);
  return nil;
}

#pragma mark - GDTCORLifecycleProtocol

- (void)appWillBackground:(GDTCORApplication *)app {
  dispatch_async(_storageQueue, ^{
    // Immediately request a background task to run until the end of the current queue of work,
    // and cancel it once the work is done.
    __block GDTCORBackgroundIdentifier bgID =
        [app beginBackgroundTaskWithName:@"GDTStorage"
                       expirationHandler:^{
                         [app endBackgroundTask:bgID];
                         bgID = GDTCORBackgroundIdentifierInvalid;
                       }];
    // End the background task if it's still valid.
    [app endBackgroundTask:bgID];
    bgID = GDTCORBackgroundIdentifierInvalid;
  });
}

- (void)appWillTerminate:(GDTCORApplication *)application {
  dispatch_sync(_storageQueue, ^{
                });
}

@end

NS_ASSUME_NONNULL_END
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
