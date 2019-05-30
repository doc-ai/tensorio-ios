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

#import <Foundation/Foundation.h>
#import <SSZipArchive/SSZipArchive.h>

#import "TIOModelBundleValidator.h"

@class TIOModelRepositoryClient;
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

@property (readonly) TIOModelRepositoryClient *repository;

/**
 * Initializes an update with a bundle and repository.
 */

- (instancetype)initWithModelBundle:(TIOModelBundle*)bundle repository:(TIOModelRepositoryClient*)repository NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Checks to see if an update is available for a model. A model has an update
 * if a new model with a newer checkpoint is available or there is one with a
 * new set of hyperparameters.
 *
 * @param callback The callbak handler. The callback is called with
 *  updateAvalable = `YES` and error = `nil` if an update is available. If
 *  there was an error, updateAvalable will be set to `NO`.
 */

- (void)checkForUpdate:(void(^)(BOOL updateAvailable, NSError * _Nullable error))callback;

/**
 * Updates a model with the identifying (model, hyperparameter, checkpoint) triple,
 * derived from the bundle.id field. The method unzips the model bundle to its
 * path, replacing the previous contents of that path. After updating the model
 * you should reload the bundle at that path.
 *
 * @param customValidator A custom validation block to perform on the model, may be `nil`
 * @param callback The callback handler. The callback is called with updated = `YES`
 *  and error = `nil` if the model was successfully updated. When no update is
 *  available, updated = `NO` and error = `nil`. Otherwise, error will be set to some value.
 */

- (void)updateWithValidator:(_Nullable TIOModelBundleValidationBlock)customValidator callback:(void(^)(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
