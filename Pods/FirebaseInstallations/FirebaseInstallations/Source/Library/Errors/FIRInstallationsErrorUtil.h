/*
 * Copyright 2019 Google
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

#import <Foundation/Foundation.h>

<<<<<<< HEAD
#import <FirebaseInstallations/FIRInstallationsErrors.h>

@class FIRInstallationsHTTPError;
=======
#import "FirebaseInstallations/Source/Library/Public/FirebaseInstallations/FIRInstallationsErrors.h"

@class FIRInstallationsHTTPError;
@class FBLPromise<ResultType>;
>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3

NS_ASSUME_NONNULL_BEGIN

void FIRInstallationsItemSetErrorToPointer(NSError *error, NSError **pointer);

@interface FIRInstallationsErrorUtil : NSObject

+ (NSError *)keyedArchiverErrorWithException:(NSException *)exception;
+ (NSError *)keyedArchiverErrorWithError:(NSError *)error;

+ (NSError *)keychainErrorWithFunction:(NSString *)keychainFunction status:(OSStatus)status;

+ (NSError *)installationItemNotFoundForAppID:(NSString *)appID appName:(NSString *)appName;

+ (NSError *)JSONSerializationError:(NSError *)error;

+ (NSError *)networkErrorWithError:(NSError *)error;

+ (NSError *)FIDRegistrationErrorWithResponseMissingField:(NSString *)missingFieldName;

+ (NSError *)corruptedIIDTokenData;

+ (FIRInstallationsHTTPError *)APIErrorWithHTTPResponse:(NSHTTPURLResponse *)HTTPResponse
                                                   data:(nullable NSData *)data;
+ (BOOL)isAPIError:(NSError *)error withHTTPCode:(NSInteger)HTTPCode;

<<<<<<< HEAD
=======
+ (NSError *)backoffIntervalWaitError;

>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
/**
 * Returns the passed error if it is already in the public domain or a new error with the passed
 * error at `NSUnderlyingErrorKey`.
 */
+ (NSError *)publicDomainErrorWithError:(NSError *)error;

<<<<<<< HEAD
=======
+ (FBLPromise *)rejectedPromiseWithError:(NSError *)error;

>>>>>>> 6003df508faf8985a6bf077aee5b922b16b948e3
@end

NS_ASSUME_NONNULL_END
