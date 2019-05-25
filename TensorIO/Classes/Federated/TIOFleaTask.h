//
//  TIOFleaTask.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 * Encapsulates information about tasks from a TensorIO Flea server.
 */

@interface TIOFleaTask : NSObject

/**
 * The id of the model with which this task is associated
 */

@property (readonly) NSString *modelId;

/**
 * The hyperparameter id for which this task is associated
 */

@property (readonly) NSString *hyperparametersId;

/**
 * The checkpoint id for which this task is associated
 */

@property (readonly) NSString *checkpointId;

/**
 * The uniquely identifying task id
 */

@property (readonly) NSString *taskId;

/**
 * `YES` if this task is currently active, `NO` otherwise
 */

@property (readonly, getter=isActive) BOOL active;

/**
 * The end date for the task
 */

@property (readonly) NSDate *deadline;

/**
 * A link to the task bundle for this task
 */

@property (readonly) NSURL *link;

/**
 * A link to the (model, hyperparameter, checkpoint) item in a tensorio models
 * repository for this task. This is the model being targeted by the federated
 * task.
 */

@property (readonly) NSURL *checkpointLink;

/**
 * The designated initializer. You should not need to instantiate instances of
 * this class yourself.
 */

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
