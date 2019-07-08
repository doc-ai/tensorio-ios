//
//  TIOModelTrainer+FederatedTask.h
//  TensorIO
//
//  Created by Phil Dow on 5/22/19.
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
#import "TIOModelTrainer.h"

@class TIOFederatedTask;

NS_ASSUME_NONNULL_BEGIN

/**
 * Utility methods for training with federated tasks.
 */

@interface TIOModelTrainer (FederatedTask)

/**
 * A convenience initializer for instantiating a trainer from a task directly.
 *
 * @param model The model that will be trained.
 * @param task The training task.
 * @param dataSource A data source that will provide batch items.
 *
 * @warning task.placeholders is currently ignore.
 */

- (instancetype)initWithModel:(id<TIOTrainableModel>)model task:(TIOFederatedTask *)task dataSource:(id<TIOBatchDataSource>)dataSource;

@end

NS_ASSUME_NONNULL_END
