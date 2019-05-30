//
//  TIOMRCheckpoint.h
//  TensorIO
//
//  Created by Phil Dow on 5/6/19.
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
 * Encpasulates information about a (model, hyperparemeters, checkpoint) triple,
 * including a link to the `TIOModel` bundle trained with these properties.
 *
 * You should not need to instantiate instances of this class yourself. They
 * are retured by requests to a `TIOModelRepositoryClient`.
 */

@interface TIOMRCheckpoint : NSObject

/**
 * The id of the model with which this checkpoint is associated
 */

@property (readonly) NSString *modelId;

/**
 * The hyperparameter id for which this checkpoint is associated
 */

@property (readonly) NSString *hyperparametersId;

/**
 * The checkpoint id
 */

@property (readonly) NSString *checkpointId;

/**
 * The date of creation of this checkpoint
 */

@property (readonly) NSDate *createdAt;

/**
 * Additional information about this checkpoint
 */

@property (readonly) NSDictionary<NSString*,NSString*> *info;

/**
 * A URL to the `TIOModel` bundle that contains the model trained with this
 * (model, hyperparameters, checkpoint) triple
 */

@property (readonly) NSURL *link;

/**
 * The designated initializer. You should not need to instantiate instances of
 * this class yourself.
 */

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON error:(NSError**)error NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
