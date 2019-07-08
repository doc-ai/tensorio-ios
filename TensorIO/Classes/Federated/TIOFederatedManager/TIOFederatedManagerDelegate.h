//
//  TIOFederatedManagerDelegate.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 * Actions taken by the federated manager. The manager will inform the delegate
 * any time it begins one of these actions or encounters an error during one
 * of them
 */

typedef enum : NSUInteger {
    TIOFederatedManagerGetTasks,
    TIOFederatedManagerGetTask,
    TIOFederatedManagerDownloadTaskBundle,
    TIOFederatedManagerUnpackageTaskBundle,
    TIOFederatedManagerStartTask,
    TIOFederatedManagerLoadTask,
    TIOFederatedManagerLoadModel,
    TIOFederatedManagerTrainModel,
    TIOFederatedManagerUploadTaskResults
} TIOFederatedManagerAction;

@class TIOFederatedManager;

@protocol TIOFederatedManagerDelegate <NSObject>

@optional

/**
 * Informs the delegate that it has begun some action. This method is optional.
 * This method will be called on the main thread.
 */

// TODO: Make sure the taskId is passed to the delegate as well, if available

- (void)federatedManager:(TIOFederatedManager *)manager didBeginAction:(TIOFederatedManagerAction)action;

/**
 * Informs the delegate that the manager will begin processing a task. This
 * method is optional. This method will be called on the main thread.
 */

- (void)federatedManager:(TIOFederatedManager *)manager willBeginProcessingTaskWithId:(NSString *)taskId;

/**
 * Informs the delegate that the manager has successfully finished processing
 * a task. This method is optional. This method will be called on the main thread.
 */

- (void)federatedManager:(TIOFederatedManager *)manager didCompleteTaskWithId:(NSString *)taskId;

/**
 * Informs the delegate that some error occurred. This method is optional.
 * This method will be called on the main thread
 */

// TODO: Make sure the taskId is passed to the delegate as well, if available

- (void)federatedManager:(TIOFederatedManager *)manager didFailWithError:(NSError *)error forAction:(TIOFederatedManagerAction)action;

/**
 * Informs the delegate that some amount of progress has been made for an action
 * specifically for `TIOFederatedManagerDownloadTaskBundle` and `TIOFederatedManagerUploadTaskResults`.
 *
 * Progress will be a value between 0 and 1. This method will only be called
 * to indicate progress when you use a `TIOFleaClientSessionDelegate` with the
 * `TIOFleaClient` that is injected into a federated manager. Refer to additional
 * instructions for `TIOFleaClient`.
 */

- (void)federatedManager:(TIOFederatedManager *)manager didProgress:(float)progress forAction:(TIOFederatedManagerAction)action;

@end

NS_ASSUME_NONNULL_END
