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
#import <SSZipArchive/SSZipArchive.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TIOFederatedManagerDataSourceProvider;
@protocol TIOFederatedManagerDelegate;

@class TIOFleaClient;

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
 * The designated initializer. You must also set a dataSourceProvider prior to
 * registering for or checking for tasks with manager.
 */

- (instancetype)initWithClient:(TIOFleaClient*)client NS_DESIGNATED_INITIALIZER;

/**
 * A convenience initializer for instantiating a federated manager with a data
 * source provider and delegate as well as the required client.
 */

- (instancetype)initWithClient:(TIOFleaClient*)client dataSourceProvider:(id<TIOFederatedManagerDataSourceProvider>)dataSourceProvider delegate:(nullable id<TIOFederatedManagerDelegate>)delegate;

/**
 * Use the designated initializer or one of the convenience initializers.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * The Flea (Federated Learning) client responsible for the underlying
 * client-server communications.
 */

@property (readonly) TIOFleaClient *client;

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

@property (readonly) NSSet<NSString*> *registeredModelIds;

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
 * Checks if there are any tasks available for any of the models registered with
 * the manager.
 */

- (void)checkIfTasksAvailable:(void(^)(BOOL tasksAvailable, NSError * _Nullable error))responseBlock;

/**
 * Begins the process of requesting tasks for the registered models from a
 * TensorIO-Flea server.
 *
 * This will set off a chain of network calls on a background
 * thread that may include API requests, downloading model updates and task
 * bundles, and finally sending the results of a task back to the Flea server.
 * Data will be provided to the manager via the data source provider and the
 * manager will inform the delegate of status updates.
 */

- (void)checkForTasks;

@end

NS_ASSUME_NONNULL_END
