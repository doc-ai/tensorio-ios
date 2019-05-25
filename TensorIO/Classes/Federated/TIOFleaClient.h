//
//  TIOFleaClient.h
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

@class TIOFleaStatus;
@class TIOFleaTasks;
@class TIOFleaTask;
@class TIOFleaTaskDownload;
@class TIOFleaJob;
@class TIOFleaJobUpload;

/**
 * Encapsulates requests to a TensorIO Flea repository, allowing users to
 * acquire federated learning tasks associated with TensorIO models. You should
 * not need to call client methods yourself but can instead use the
 * `TIOFederatedManager` class.
 *
 * All HTTP requests are run on a background thread and execute their callbacks
 * on a background thread.
 */

@interface TIOFleaClient : NSObject

/**
 * The base URL of the model repository
 */

@property (readonly) NSURL *baseURL;

/**
 * The URL session used by the model respository
 */

@property (readonly) NSURLSession *URLSession;

/**
 * Initializes a model repository with a base URL
 *
 * You may inject your own URL Session into the model respository object for
 * custom request handling and downloads, but this behavior exists in order to
 * test the object and passing `nil` is sufficient.
 */

- (instancetype)initWithBaseURL:(NSURL*)baseURL session:(nullable NSURLSession*)URLSession NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer
 */

- (instancetype)init NS_UNAVAILABLE;

// MARK: - Primitive Repository Methods

/**
 * Checks if the repository is up and correctly running
 */

- (NSURLSessionTask*)GETHealthStatus:(void(^)(TIOFleaStatus * _Nullable status, NSError * _Nullable error))responseBlock;

/**
 * Retrieves a list of tasks ids for a (model, hyperparameters, checkpoint) tuple.
 * Any of the tuple values may be nil.
 */

- (NSURLSessionTask*)GETTasksWithModelId:(nullable NSString*)modelId hyperparametersId:(nullable NSString*)hyperparametersId checkpointId:(nullable NSString*)checkpointId callback:(void(^)(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error))responseBlock;

/**
 * Retrieves metadata for a task with id, including a link to the task bundle
 */

- (NSURLSessionTask*)GETTaskWithTaskId:(NSString*)taskId callback:(void(^)(TIOFleaTask * _Nullable task, NSError * _Nullable error))responseBlock;

/**
 * Informs the server that the client will begin working on a task
 */

 - (NSURLSessionTask*)GETStartTaskWithTaskId:(NSString*)taskId callback:(void(^)(TIOFleaJob * _Nullable job, NSError * _Nullable error))responseBlock;

/**
 * Downloads a zipped task bundle.
 *
 * The progress parameter is currently ignored and the download reports 0 or 1
 * for progress.
 */

- (NSURLSessionDownloadTask*)downloadTaskBundleAtURL:(NSURL*)URL withTaskId:(NSString*)taskId callback:(void(^)(TIOFleaTaskDownload * _Nullable download, double progress, NSError * _Nullable error))responseBlock;

/**
 * Uploads the results of a job to the server. The sourceURL should be a zipped
 * folder of the results of some federated task, for example, a training
 * checkpoint.
 *
 * The progress parameter is currently ignored and the download reports 0 or 1
 * for progress.
 *
 * Returns `nil` and executes callback with an error if the file at sourceURL
 * does not exist
 */

- (nullable NSURLSessionUploadTask*)uploadJobResultsAtURL:(NSURL*)sourceURL toURL:(NSURL*)destinationURL withJobId:(NSString*)jobId callback:(void(^)(TIOFleaJobUpload * _Nullable upload, double progress, NSError * _Nullable error))responseBlock;

@end

NS_ASSUME_NONNULL_END
