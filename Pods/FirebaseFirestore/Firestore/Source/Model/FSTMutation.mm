/*
 * Copyright 2017 Google
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

#import "Firestore/Source/Model/FSTMutation.h"

#include <memory>
#include <string>
#include <utility>
#include <vector>

#import "FIRTimestamp.h"

#import "Firestore/Source/Model/FSTDocument.h"
#import "Firestore/Source/Model/FSTFieldValue.h"
#import "Firestore/Source/Util/FSTClasses.h"

#include "Firestore/core/src/firebase/firestore/model/document_key.h"
#include "Firestore/core/src/firebase/firestore/model/field_mask.h"
#include "Firestore/core/src/firebase/firestore/model/field_path.h"
#include "Firestore/core/src/firebase/firestore/model/field_transform.h"
#include "Firestore/core/src/firebase/firestore/model/precondition.h"
#include "Firestore/core/src/firebase/firestore/model/transform_operations.h"
#include "Firestore/core/src/firebase/firestore/util/hard_assert.h"

using firebase::firestore::model::ArrayTransform;
using firebase::firestore::model::DocumentKey;
using firebase::firestore::model::FieldMask;
using firebase::firestore::model::FieldPath;
using firebase::firestore::model::FieldTransform;
using firebase::firestore::model::Precondition;
using firebase::firestore::model::ServerTimestampTransform;
using firebase::firestore::model::SnapshotVersion;
using firebase::firestore::model::TransformOperation;
using firebase::firestore::util::Hash;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FSTMutationResult

@implementation FSTMutationResult {
  SnapshotVersion _version;
}

- (instancetype)initWithVersion:(SnapshotVersion)version
               transformResults:(nullable NSArray<FSTFieldValue *> *)transformResults {
  if (self = [super init]) {
    _version = std::move(version);
    _transformResults = transformResults;
  }
  return self;
}

- (const SnapshotVersion &)version {
  return _version;
}

@end

#pragma mark - FSTMutation

@implementation FSTMutation {
  DocumentKey _key;
  Precondition _precondition;
}

- (instancetype)initWithKey:(DocumentKey)key precondition:(Precondition)precondition {
  if (self = [super init]) {
    _key = std::move(key);
    _precondition = std::move(precondition);
  }
  return self;
}

- (nullable FSTMaybeDocument *)applyToRemoteDocument:(nullable FSTMaybeDocument *)maybeDoc
                                      mutationResult:(FSTMutationResult *)mutationResult {
  @throw FSTAbstractMethodException();  // NOLINT
}

- (nullable FSTMaybeDocument *)applyToLocalDocument:(nullable FSTMaybeDocument *)maybeDoc
                                       baseDocument:(nullable FSTMaybeDocument *)baseDoc
                                     localWriteTime:(FIRTimestamp *)localWriteTime {
  @throw FSTAbstractMethodException();  // NOLINT
}

- (const DocumentKey &)key {
  return _key;
}

- (const firebase::firestore::model::Precondition &)precondition {
  return _precondition;
}

@end

#pragma mark - FSTSetMutation

@implementation FSTSetMutation

- (instancetype)initWithKey:(DocumentKey)key
                      value:(FSTObjectValue *)value
               precondition:(Precondition)precondition {
  if (self = [super initWithKey:std::move(key) precondition:std::move(precondition)]) {
    _value = value;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<FSTSetMutation key=%s value=%@ precondition=%@>",
                                    self.key.ToString().c_str(), self.value,
                                    self.precondition.description()];
}

- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[FSTSetMutation class]]) {
    return NO;
  }

  FSTSetMutation *otherMutation = (FSTSetMutation *)other;
  return self.key == otherMutation.key && [self.value isEqual:otherMutation.value] &&
         self.precondition == otherMutation.precondition;
}

- (NSUInteger)hash {
  return Hash(self.key, self.precondition, [self.value hash]);
}

- (nullable FSTMaybeDocument *)applyToLocalDocument:(nullable FSTMaybeDocument *)maybeDoc
                                       baseDocument:(nullable FSTMaybeDocument *)baseDoc
                                     localWriteTime:(FIRTimestamp *)localWriteTime {
  if (!self.precondition.IsValidFor(maybeDoc)) {
    return maybeDoc;
  }

  if (!maybeDoc || [maybeDoc isMemberOfClass:[FSTDeletedDocument class]]) {
    // If the document didn't exist before, create it.
    return [FSTDocument documentWithData:self.value
                                     key:self.key
                                 version:SnapshotVersion::None()
                       hasLocalMutations:YES];
  }

  HARD_ASSERT([maybeDoc isMemberOfClass:[FSTDocument class]], "Unknown MaybeDocument type %s",
              [maybeDoc class]);
  FSTDocument *doc = (FSTDocument *)maybeDoc;

  HARD_ASSERT(doc.key == self.key, "Can only set a document with the same key");
  return [FSTDocument documentWithData:self.value
                                   key:doc.key
                               version:doc.version
                     hasLocalMutations:YES];
}

- (nullable FSTMaybeDocument *)applyToRemoteDocument:(nullable FSTMaybeDocument *)maybeDoc
                                      mutationResult:(FSTMutationResult *)mutationResult {
  if (mutationResult) {
    HARD_ASSERT(!mutationResult.transformResults, "Transform results received by FSTSetMutation.");
  }

  if (!self.precondition.IsValidFor(maybeDoc)) {
    return maybeDoc;
  }

  if (!maybeDoc || [maybeDoc isMemberOfClass:[FSTDeletedDocument class]]) {
    // If the document didn't exist before, create it.
    return [FSTDocument documentWithData:self.value
                                     key:self.key
                                 version:SnapshotVersion::None()
                       hasLocalMutations:NO];
  }

  HARD_ASSERT([maybeDoc isMemberOfClass:[FSTDocument class]], "Unknown MaybeDocument type %s",
              [maybeDoc class]);
  FSTDocument *doc = (FSTDocument *)maybeDoc;

  HARD_ASSERT(doc.key == self.key, "Can only set a document with the same key");
  return [FSTDocument documentWithData:self.value
                                   key:doc.key
                               version:doc.version
                     hasLocalMutations:NO];
}
@end

#pragma mark - FSTPatchMutation

@implementation FSTPatchMutation {
  FieldMask _fieldMask;
}

- (instancetype)initWithKey:(DocumentKey)key
                  fieldMask:(FieldMask)fieldMask
                      value:(FSTObjectValue *)value
               precondition:(Precondition)precondition {
  self = [super initWithKey:std::move(key) precondition:std::move(precondition)];
  if (self) {
    _fieldMask = std::move(fieldMask);
    _value = value;
  }
  return self;
}

- (const firebase::firestore::model::FieldMask &)fieldMask {
  return _fieldMask;
}

- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[FSTPatchMutation class]]) {
    return NO;
  }

  FSTPatchMutation *otherMutation = (FSTPatchMutation *)other;
  return self.key == otherMutation.key && self.fieldMask == otherMutation.fieldMask &&
         [self.value isEqual:otherMutation.value] &&
         self.precondition == otherMutation.precondition;
}

- (NSUInteger)hash {
  return Hash(self.key, self.precondition, self.fieldMask, [self.value hash]);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<FSTPatchMutation key=%s mask=%s value=%@ precondition=%@>",
                                    self.key.ToString().c_str(), self.fieldMask.ToString().c_str(),
                                    self.value, self.precondition.description()];
}

- (nullable FSTMaybeDocument *)applyToLocalDocument:(nullable FSTMaybeDocument *)maybeDoc
                                       baseDocument:(nullable FSTMaybeDocument *)baseDoc
                                     localWriteTime:(FIRTimestamp *)localWriteTime {
  if (!self.precondition.IsValidFor(maybeDoc)) {
    return maybeDoc;
  }

  if (!maybeDoc || [maybeDoc isMemberOfClass:[FSTDeletedDocument class]]) {
    // Precondition applied, so create the document if necessary
    const DocumentKey &key = maybeDoc ? maybeDoc.key : self.key;
    SnapshotVersion version = maybeDoc ? maybeDoc.version : SnapshotVersion::None();
    maybeDoc = [FSTDocument documentWithData:[FSTObjectValue objectValue]
                                         key:key
                                     version:std::move(version)
                           hasLocalMutations:YES];
  }

  HARD_ASSERT([maybeDoc isMemberOfClass:[FSTDocument class]], "Unknown MaybeDocument type %s",
              [maybeDoc class]);
  FSTDocument *doc = (FSTDocument *)maybeDoc;

  HARD_ASSERT(doc.key == self.key, "Can only patch a document with the same key");

  FSTObjectValue *newData = [self patchObjectValue:doc.data];
  return
      [FSTDocument documentWithData:newData key:doc.key version:doc.version hasLocalMutations:YES];
}

- (nullable FSTMaybeDocument *)applyToRemoteDocument:(nullable FSTMaybeDocument *)maybeDoc
                                      mutationResult:(FSTMutationResult *)mutationResult {
  HARD_ASSERT(!mutationResult.transformResults, "Transform results received by FSTPatchMutation.");

  if (!self.precondition.IsValidFor(maybeDoc)) {
    return maybeDoc;
  }

  BOOL hasLocalMutations = (mutationResult == nil);
  if (!maybeDoc || [maybeDoc isMemberOfClass:[FSTDeletedDocument class]]) {
    // Precondition applied, so create the document if necessary
    const DocumentKey &key = maybeDoc ? maybeDoc.key : self.key;
    SnapshotVersion version = maybeDoc ? maybeDoc.version : SnapshotVersion::None();
    maybeDoc = [FSTDocument documentWithData:[FSTObjectValue objectValue]
                                         key:key
                                     version:std::move(version)
                           hasLocalMutations:hasLocalMutations];
  }

  HARD_ASSERT([maybeDoc isMemberOfClass:[FSTDocument class]], "Unknown MaybeDocument type %s",
              [maybeDoc class]);
  FSTDocument *doc = (FSTDocument *)maybeDoc;

  HARD_ASSERT(doc.key == self.key, "Can only patch a document with the same key");

  FSTObjectValue *newData = [self patchObjectValue:doc.data];
  return [FSTDocument documentWithData:newData
                                   key:doc.key
                               version:doc.version
                     hasLocalMutations:hasLocalMutations];
}

- (FSTObjectValue *)patchObjectValue:(FSTObjectValue *)objectValue {
  FSTObjectValue *result = objectValue;
  for (const FieldPath &fieldPath : self.fieldMask) {
    if (!fieldPath.empty()) {
      FSTFieldValue *newValue = [self.value valueForPath:fieldPath];
      if (newValue) {
        result = [result objectBySettingValue:newValue forPath:fieldPath];
      } else {
        result = [result objectByDeletingPath:fieldPath];
      }
    }
  }
  return result;
}

@end

@implementation FSTTransformMutation {
  /** The field transforms to use when transforming the document. */
  std::vector<FieldTransform> _fieldTransforms;
}

- (instancetype)initWithKey:(DocumentKey)key
            fieldTransforms:(std::vector<FieldTransform>)fieldTransforms {
  // NOTE: We set a precondition of exists: true as a safety-check, since we always combine
  // FSTTransformMutations with a FSTSetMutation or FSTPatchMutation which (if successful) should
  // end up with an existing document.
  if (self = [super initWithKey:std::move(key) precondition:Precondition::Exists(true)]) {
    _fieldTransforms = std::move(fieldTransforms);
  }
  return self;
}

- (const std::vector<FieldTransform> &)fieldTransforms {
  return _fieldTransforms;
}

- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[FSTTransformMutation class]]) {
    return NO;
  }

  FSTTransformMutation *otherMutation = (FSTTransformMutation *)other;
  return self.key == otherMutation.key && self.fieldTransforms == otherMutation.fieldTransforms &&
         self.precondition == otherMutation.precondition;
}

- (NSUInteger)hash {
  NSUInteger result = self.key.Hash();
  result = 31 * result + self.precondition.Hash();
  for (const auto &transform : self.fieldTransforms) {
    result = 31 * result + transform.Hash();
  }
  return result;
}

- (NSString *)description {
  std::string fieldTransforms;
  for (const auto &transform : self.fieldTransforms) {
    fieldTransforms += " " + transform.path().CanonicalString();
  }
  return [NSString stringWithFormat:@"<FSTTransformMutation key=%s transforms=%s precondition=%@>",
                                    self.key.ToString().c_str(), fieldTransforms.c_str(),
                                    self.precondition.description()];
}

- (nullable FSTMaybeDocument *)applyToLocalDocument:(nullable FSTMaybeDocument *)maybeDoc
                                       baseDocument:(nullable FSTMaybeDocument *)baseDoc
                                     localWriteTime:(FIRTimestamp *)localWriteTime {
  if (!self.precondition.IsValidFor(maybeDoc)) {
    return maybeDoc;
  }

  // We only support transforms with precondition exists, so we can only apply it to an existing
  // document
  HARD_ASSERT([maybeDoc isMemberOfClass:[FSTDocument class]], "Unknown MaybeDocument type %s",
              [maybeDoc class]);
  FSTDocument *doc = (FSTDocument *)maybeDoc;

  HARD_ASSERT(doc.key == self.key, "Can only transform a document with the same key");

  NSArray<FSTFieldValue *> *transformResults =
      [self localTransformResultsWithBaseDocument:baseDoc writeTime:localWriteTime];
  FSTObjectValue *newData = [self transformObject:doc.data transformResults:transformResults];
  return
      [FSTDocument documentWithData:newData key:doc.key version:doc.version hasLocalMutations:YES];
}

- (nullable FSTMaybeDocument *)applyToRemoteDocument:(nullable FSTMaybeDocument *)maybeDoc
                                      mutationResult:(FSTMutationResult *)mutationResult {
  HARD_ASSERT(mutationResult.transformResults,
              "Transform results missing for FSTTransformMutation.");

  if (!self.precondition.IsValidFor(maybeDoc)) {
    return maybeDoc;
  }

  // We only support transforms with precondition exists, so we can only apply it to an existing
  // document
  HARD_ASSERT([maybeDoc isMemberOfClass:[FSTDocument class]], "Unknown MaybeDocument type %s",
              [maybeDoc class]);
  FSTDocument *doc = (FSTDocument *)maybeDoc;

  HARD_ASSERT(doc.key == self.key, "Can only transform a document with the same key");

  NSArray<FSTFieldValue *> *transformResults =
      [self serverTransformResultsWithBaseDocument:maybeDoc
                            serverTransformResults:mutationResult.transformResults];

  FSTObjectValue *newData = [self transformObject:doc.data transformResults:transformResults];
  return
      [FSTDocument documentWithData:newData key:doc.key version:doc.version hasLocalMutations:NO];
}

/**
 * Creates an array of "transform results" (a transform result is a field value representing the
 * result of applying a transform) for use after a FSTTransformMutation has been acknowledged by
 * the server.
 *
 * @param baseDocument The document prior to applying this mutation batch.
 * @param serverTransformResults The transform results received by the server.
 * @return The transform results array.
 */
- (NSArray<FSTFieldValue *> *)
    serverTransformResultsWithBaseDocument:(nullable FSTMaybeDocument *)baseDocument
                    serverTransformResults:(NSArray<FSTFieldValue *> *)serverTransformResults {
  NSMutableArray<FSTFieldValue *> *transformResults = [NSMutableArray array];
  HARD_ASSERT(self.fieldTransforms.size() == serverTransformResults.count,
              "server transform result count (%s) should match field transforms count (%s)",
              (unsigned long)serverTransformResults.count, self.fieldTransforms.size());

  for (NSUInteger i = 0; i < serverTransformResults.count; i++) {
    const FieldTransform &fieldTransform = self.fieldTransforms[i];
    const TransformOperation &transform = fieldTransform.transformation();

    FSTFieldValue *previousValue = nil;
    if ([baseDocument isMemberOfClass:[FSTDocument class]]) {
      previousValue = [((FSTDocument *)baseDocument) fieldForPath:fieldTransform.path()];
    }

    [transformResults
        addObject:transform.ApplyToRemoteDocument(previousValue, serverTransformResults[i])];
  }
  return transformResults;
}

/**
 * Creates an array of "transform results" (a transform result is a field value representing the
 * result of applying a transform) for use when applying an FSTTransformMutation locally.
 *
 * @param baseDocument The document prior to applying this mutation batch.
 * @param localWriteTime The local time of the transform mutation (used to generate
 * FSTServerTimestampValues).
 * @return The transform results array.
 */
- (NSArray<FSTFieldValue *> *)localTransformResultsWithBaseDocument:
                                  (nullable FSTMaybeDocument *)baseDocument
                                                          writeTime:(FIRTimestamp *)localWriteTime {
  NSMutableArray<FSTFieldValue *> *transformResults = [NSMutableArray array];
  for (const FieldTransform &fieldTransform : self.fieldTransforms) {
    const TransformOperation &transform = fieldTransform.transformation();

    FSTFieldValue *previousValue = nil;
    if ([baseDocument isMemberOfClass:[FSTDocument class]]) {
      previousValue = [((FSTDocument *)baseDocument) fieldForPath:fieldTransform.path()];
    }

    [transformResults addObject:transform.ApplyToLocalView(previousValue, localWriteTime)];
  }
  return transformResults;
}

- (FSTObjectValue *)transformObject:(FSTObjectValue *)objectValue
                   transformResults:(NSArray<FSTFieldValue *> *)transformResults {
  HARD_ASSERT(transformResults.count == self.fieldTransforms.size(),
              "Transform results length mismatch.");

  for (size_t i = 0; i < self.fieldTransforms.size(); i++) {
    const FieldTransform &fieldTransform = self.fieldTransforms[i];
    const FieldPath &fieldPath = fieldTransform.path();
    objectValue = [objectValue objectBySettingValue:transformResults[i] forPath:fieldPath];
  }
  return objectValue;
}

@end

#pragma mark - FSTDeleteMutation

@implementation FSTDeleteMutation

- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[FSTDeleteMutation class]]) {
    return NO;
  }

  FSTDeleteMutation *otherMutation = (FSTDeleteMutation *)other;
  return self.key == otherMutation.key && self.precondition == otherMutation.precondition;
}

- (NSUInteger)hash {
  return Hash(self.key, self.precondition);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<FSTDeleteMutation key=%s precondition=%@>",
                                    self.key.ToString().c_str(), self.precondition.description()];
}

- (nullable FSTMaybeDocument *)applyToLocalDocument:(nullable FSTMaybeDocument *)maybeDoc
                                       baseDocument:(nullable FSTMaybeDocument *)baseDoc
                                     localWriteTime:(FIRTimestamp *)localWriteTime {
  if (!self.precondition.IsValidFor(maybeDoc)) {
    return maybeDoc;
  }

  if (maybeDoc) {
    HARD_ASSERT(maybeDoc.key == self.key, "Can only delete a document with the same key");
  }

  return [FSTDeletedDocument documentWithKey:self.key version:SnapshotVersion::None()];
}

- (nullable FSTMaybeDocument *)applyToRemoteDocument:(nullable FSTMaybeDocument *)maybeDoc
                                      mutationResult:(FSTMutationResult *)mutationResult {
  if (mutationResult) {
    HARD_ASSERT(!mutationResult.transformResults,
                "Transform results received by FSTDeleteMutation.");
  }

  if (!self.precondition.IsValidFor(maybeDoc)) {
    return maybeDoc;
  }

  if (maybeDoc) {
    HARD_ASSERT(maybeDoc.key == self.key, "Can only delete a document with the same key");
  }

  return [FSTDeletedDocument documentWithKey:self.key version:SnapshotVersion::None()];
}

@end

NS_ASSUME_NONNULL_END
