//
//  TIOFederatedTaskBundleValidator.h
//  TensorIO
//
//  Created by Phil Dow on 5/21/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A validation block that allows clients of the validator to add custom
 * validation as a final step.
 *
 * @param path The path to the task bundle.
 * @param JSON The JSON loaded from task.json in the task bundle.
 * @param error A pointer to an error object that the custom validator can set
 *  if validation fails.
 *
 * @return BOOL `YES` if the custom validation passed, `NO` otherwise.
 */

typedef BOOL (^TIOFederatedTaskBundleValidationBlock)(NSString *path, NSDictionary *JSON, NSError **error);

/**
 * Validates a Federated Task bundle.
 */

@interface TIOFederatedTaskBundleValidator : NSObject

/**
 * Instantiates a bundle validator with a federated task bundle.
 *
 * @param path A path to the .tiotask folder that will be validated.
 *
 * @return instancetype A validator instance.
 */

- (instancetype)initWithModelBundleAtPath:(NSString*)path NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * The path to the task bundle which is being evaluated.
 */

@property(readonly) NSString *path;

/**
 * The JSON in the task.json file for which the bundle is being evaluated
 */

@property(readonly) NSDictionary *JSON;

// MARK: - Validation

/**
 * Validates the bundle which was provided at initialization. Use this method to
 * validate task.
 *
 * @param customValidator A custom validation block for application specific
 *  validation
 * @param error Pointer to an `NSError` that will be set if the bundle could not
 *  be validated.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

- (BOOL)validate:(_Nullable TIOFederatedTaskBundleValidationBlock)customValidator error:(NSError**)error;

/**
 * A convenience method for validating the bundle when no custom validation is
 * needed.
 *
 * @param error Pointer to an `NSError` that will be set if the bundle could not
 *  be validated.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

- (BOOL)validate:(NSError**)error;

/**
 * Executes a custom validator. Called by `validate:error:`
 *
 * The `validate:error:` function passes the custom validator provided there to
 * this function.
 *
 * @param JSON The bundle properties loaded from a task.json file.
 * @param customValidator The custom validator provided to the `validate:error:`
 *  function.
 * @param error Pointer to an `NSError` that will be set if the custom validator
 *  fails. It will be set to the error passed back by the validator.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

- (BOOL)validateCustomValidator:(NSDictionary*)JSON validator:(TIOFederatedTaskBundleValidationBlock)customValidator error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
