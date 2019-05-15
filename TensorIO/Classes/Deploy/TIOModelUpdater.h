//
//  TIOModelUpdater.h
//  TensorIO
//
//  Created by Phil Dow on 5/13/19.
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
//  TODO: Model bundle verification


#import <Foundation/Foundation.h>
#import "TIOModelBundleValidator.h"

@class TIOModelRepository;
@class TIOModelBundle;

NS_ASSUME_NONNULL_BEGIN

/**
 * Updates a model from a given TensorIO models repository.
 */

@interface TIOModelUpdater : NSObject

/**
 * The bundle that will be updated. After the update is complete you must reload
 * this bundle to have access to the latest version of the model
 */

@property (readonly) TIOModelBundle *bundle;

/**
 * The TensorIO repository which may contain an update to the model wrapped
 * by `bundle`.
 */

@property (readonly) TIOModelRepository *repository;

/**
 * Initializes an update with a bundle and repository.
 */

- (instancetype)initWithModelBundle:(TIOModelBundle*)bundle repository:(TIOModelRepository*)repository NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Updates a model with the identifying (model, hyperparameter, checkpoint) triple,
 * derived from the bundle.id field. The method unzips the model bundle to its
 * path, replacing the previous contents of that path. After updating the model
 * you should reload the bundle at that path.
 *
 * @param customValidator A custom validation block to perform on the model, may be `nil`
 * @param callback The callback handler. The callback is called with updated = `YES`
 * and error = `nil` if the model was successfully updated. When no update is
 * available, updated = `NO` and error = `nil`. Otherwise, error will be set to some value.
 */

- (void)updateWithValidator:(_Nullable TIOModelBundleValidationBlock)customValidator callback:(void(^)(BOOL updated, NSError *error))callback;

// MARK: -

/**
 * Call updateWithValidator:callback: instead, which calls this method.
 */

- (void)updateModelWithId:(NSString*)modelId hyperparametersId:(NSString*)hyperparametersId checkpointId:(NSString*)checkpointId destination:(NSURL*)destinationURL callback:(void(^)(BOOL updated, NSError *error))responseBlock;

/**
 * Call updateWithValidator:callback: instead, which calls this method.
 */

- (BOOL)unzipModelBundleAtURL:(NSURL*)sourceURL toURL:(NSURL*)destinationURL error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
