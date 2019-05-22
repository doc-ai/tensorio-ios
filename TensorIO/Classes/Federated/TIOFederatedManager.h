//
//  TIOFederatedManager.h
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

@protocol TIOFederatedManagerDataSourceProvider;
@protocol TIOFederatedManagerDelegate;

/**
 * Allows users to register for or request federated tasks from a TensorIO Flea
 * server and provide data to the model for those task. The
 * `TIOFederatedManager` coordinates between learning tasks, client-server
 * interactions, and actually executing training on a model.
 *
 * You must set a data source provider prior to registering for or requesting new
 * tasks. The data source provider vends instances of `TIOBatchDataSource` to
 * the manager, which are themselves responsible for providing batch data for
 * a task. You may return the data source provider itself if it also knows how
 * to vend data, but it is then that classes responsibility to only vend the
 * correct data for a specific task.
 */

@interface TIOFederatedManager : NSObject

/**
 * A convenience initializer for instantiating a federated manager with a data
 * source provider and delegate;
 */

- (instancetype)initWithDataSourceProvider:(id<TIOFederatedManagerDataSourceProvider>)dataSourceProvider delegate:(nullable id<TIOFederatedManagerDelegate>)delegate;

/**
 * The data source provider is responsible for vending instances of
 * `TIOBatchDataSource` to the manager for the specified tasks. It may be the
 * provider itself.
 */

@property (weak, readwrite) id<TIOFederatedManagerDataSourceProvider> dataSourceProvider;

/**
 * The delegate will be notified of federated task events as they occur.
 */

@property (weak, nullable, readwrite) id<TIOFederatedManagerDelegate> delegate;

/**
 * The model ids that are being tracked for tasks against a TensorIO-Flea repository
 */

@property (readonly) NSArray<NSString*> *registeredModelIds;

/**
 * Informs the manager to check for tasks for a model with a given id whenever
 * `checkForTasks:` is called. You must call that method in addition to registering
 * specific models.
 */

- (void)registerForTasksForModelWithId:(NSString*)modelId;

/**
 * Unregisters a model id with the manager.
 */

- (void)unregisterForTasksForModelWithId:(NSString*)modelId;

/**
 * Begins the process of requesting tasks for the registered models from a
 * TensorIO-Flea server. This will set of a chain of network calls on a background
 * threat that may include API requests, downloading model updates and task
 * bundles, and finally sending the results of a task back to the Flea server.
 */

- (void)checkForTasks;

@end

NS_ASSUME_NONNULL_END
