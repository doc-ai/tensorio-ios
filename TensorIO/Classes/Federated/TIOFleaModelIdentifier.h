//
//  TIOFleaModelIdentifier.h
//  TensorIO
//
//  Created by Phil Dow on 5/15/19.
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

//  TODO: Unify handling of TIO Model Identifiers and move to core (#106)
//  This duplicates TIOMRModelIdentifier

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The canonical identification of a unique model in a TensorIO models
 * repository. A model is uniquely identified by the triple (model id,
 * hyperparameters id, checkpoint id). A model id typically identifies a
 * learning problem, a hyperparameter id a set of training parameters and
 * possibly a network structure, and checkpoint id the checkpoint for a
 * model-hyperparameter configuration at a certain point in its training.
 */

@interface TIOFleaModelIdentifier : NSObject

@property (readonly) NSString *modelId;
@property (readonly) NSString *hyperparametersId;
@property (readonly) NSString *checkpointId;

/**
 * Creates an instance with the canonical identifiers of a unique model.
 */

- (instancetype)initWithModelId:(NSString *)modelId hyperparametersId:(NSString *)hyperparametersId checkpointsId:(NSString *)checkpointId NS_DESIGNATED_INITIALIZER;

/**
 * Creates an instance from the id stored in a model bundle. Model bundle ids
 * are more flexible than model repository ids and can identify a model in an
 * arbitrary way. If a model bundle is associated with a model respository, its
 * id can be parsed into a repository triple and will have the format:
 *
 * tio:///models/<model-id>/hyperparameters/<hyperparameters-id>/checkpoints/<checkpoint-id>
 *
 * Returns `nil` if the bundle id does not match this format.
 */

- (nullable instancetype)initWithBundleId:(NSString *)bundleId;

/**
 * Use the designated initializer or one of the convenience initializers.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
