//
//  TIOFederatedTask.h
//  TensorIO
//
//  Created by Phil Dow on 5/18/19.
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
#import "TIOLayerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TIOData;
@class TIOModelIOList;
@class TIOTaskIO;

/**
 * A federated task represents a federated learning task for a specific
 * TensorIO model. You should not need to instantiate this class directly.
 * Instead load a task from a bundle with `TIOFederatedTaskBundle`.
 *
 * With respect to placeholders, information encapsulated in a placeholder
 * dictionary other than the name and value, such are ignored here but the
 * description must match the placeholder description in the target model .
 * These are verifed when a `TIOModelTrainer` is instantiated with a federated
 * task.
 */

@interface TIOFederatedTask : NSObject

/**
 * The task's unique identifier.
 */

@property (readonly) NSString *identifier;

/**
 * Human readable name of the task.
 */

@property (readonly) NSString *name;

/**
 * Additional information about the task represented.
 */

@property (readonly) NSString *details;

/**
 * The unique identifier of the model to which this task will be applied.
 */

@property (readonly) NSString *modelIdentifier;

/**
 * The number of training epochs for this task.
 */

@property (readonly) NSUInteger epochs;

/**
 * The batch size to use for each training pass for this task.
 */

@property (readonly) NSUInteger batchSize;

/**
 * `YES` if batch items should be shuffled, `NO` otherwise
 */

@property (readonly) BOOL shuffle;

/**
 * Encapsulates information about the task's placeholders, e.g. hyperparameters.
 * May be empty and must match the placeholder descriptions of the model this
 * task targets.
 *
 * @code
 * io.placeholders[0]
 * io.placeholders[@"label"]
 * @endcode
 */

@property (readonly) TIOTaskIO *io;

/**
 * The actual placeholder values, e.g. hyperparameters, to be injected into the
 * model when executing the task. May be `nil`.
 */

@property (nullable, readonly) NSDictionary<NSString*, id<TIOData>> *placeholders;

/**
 * Designated initializer.
 *
 * @param JSON Previously validated JSON that describes a federated learning task
 *
 * @return An instance of a `TIOFederatedTask`.
 */

- (nullable instancetype)initWithJSON:(NSDictionary *)JSON NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

// MARK: -

/**
 * Encapsulates information about the placeholders supported by a task.
 *
 * Equivalent to the `TIOModelIO` object that encapsulates information about a
 * model's inputs, outputs, and placeholders, and is used to compare placeholder
 * descriptions between a model and a task.
 */

@interface TIOTaskIO : NSObject

/**
 * Initializes an instance with and placeholder interfaces.
 */

- (instancetype)initWithPlaceholderInterfaces:(nullable NSArray<TIOLayerInterface*> *)placeholderInterfaces;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * The placeholders list. May be `nil`. Access the values in this list using
 * indexed subscripting by name or by key.
 *
 * @code
 * placeholders[0]
 * placeholders[@"label"]
 * @endcode
 */

@property (nullable, readonly) TIOModelIOList *placeholders;

@end

NS_ASSUME_NONNULL_END
