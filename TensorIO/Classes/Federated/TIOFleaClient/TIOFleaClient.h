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
 *
 * To use a client with a session delegate, which supports the use of full
 * background requests (requests that execute when the app is in the background
 * or a suspended state) as well as progress updates on the upload and download
 * methods, inject a background session configuration, client session delegate,
 * and download session into this client as follows:
 *
 * @code
 * NSURLSessionConfiguration *backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:TIOFleaClient.backgroundSessionIdentifier];
 * TIOFleaClientSessionDelegate *delegate = [[TIOFleaClientSessionDelegate alloc] init];
 * NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:delegate delegateQueue:nil];
 * @endcode
 *
 * Then, in your Application Delegate, implement the `handleEventsForBackgroundURLSession:`
 * delegate method and make the completionHandler available to the shared
 * `TIOFleaClientBackgroundSessionHandler` as follows:
 *
 * @code
 * - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)(void))completionHandler {
 *   if ([identifier isEqualToString:TIOFleaClient.backgroundSessionIdentifier]) {
 *       TIOFleaClientBackgroundSessionHandler.sharedInstance.handler = completionHandler;
 *   }
 * }
 * @endcode
 *
 * Uploads and downloads will now continue even if the user backgrounds the
 * application. Because you should be using the `TIOFederatedManager` instead of
 * this client directly, to receive upload and download progress reports,
 * implement the `federatedManager:didProgress:forAction` delegate method.
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
 * The download URL session used for model downloads, which may require different
 * headers or other session configuration.
 */

@property (readonly) NSURLSession *downloadURLSession;

/**
 * A unique ID associated with the client. Will be regenerated any time it is
 * not available, for example, if the client application is re-installed. The
 * unique ID is shared with the `TIOFleaModelRepositoryClient` in the Deploy module.
 */

 @property (readonly) NSString *clientId;

/**
 * Initializes a model repository with a base URL
 *
 * You may inject your own URL Session into the flea client object for
 * custom request handling, downloads, and uploads, and to set up authentication
 * headers, but this behavior exists in order to test the object, and passing
 * `nil` may be sufficient.
 */

- (instancetype)initWithBaseURL:(NSURL *)baseURL session:(nullable NSURLSession *)URLSession downloadSession:(nullable NSURLSession *)downloadURLSession NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * A background session identifier to be used with background session configuration
 */

+ (NSString *)backgroundSessionIdentifier;

// MARK: - Primitive Repository Methods

/**
 * Checks if the repository is up and correctly running
 */

- (NSURLSessionTask *)GETHealthStatus:(void(^)(TIOFleaStatus * _Nullable status, NSError * _Nullable error))responseBlock;

/**
 * Retrieves a list of tasks ids for a (model, hyperparameters, checkpoint) tuple.
 * Any of the tuple values may be nil.
 */

- (NSURLSessionTask *)GETTasksWithModelId:(nullable NSString *)modelId hyperparametersId:(nullable NSString *)hyperparametersId checkpointId:(nullable NSString *)checkpointId callback:(void(^)(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error))responseBlock;

/**
 * Retrieves metadata for a task with id, including a link to the task bundle
 */

- (NSURLSessionTask *)GETTaskWithTaskId:(NSString *)taskId callback:(void(^)(TIOFleaTask * _Nullable task, NSError * _Nullable error))responseBlock;

/**
 * Informs the server that the client will begin working on a task
 */

 - (NSURLSessionTask *)GETStartTaskWithTaskId:(NSString *)taskId callback:(void(^)(TIOFleaJob * _Nullable job, NSError * _Nullable error))responseBlock;

/**
 * Informs the server of an error while processing a job for a task.
 * A temporary API.
 */

- (nullable NSURLSessionTask *)POSTErrorMessage:(NSString *)errorMessage taskId:(NSString *)taskId jobId:(NSString *)jobId callback:(void(^)(BOOL success, NSError * _Nullable error))responseBlock;

/**
 * Downloads a zipped task bundle.
 *
 * The progress parameter is currently ignored and the download reports 0 or 1
 * for progress.
 */

- (NSURLSessionDownloadTask *)downloadTaskBundleAtURL:(NSURL *)URL withTaskId:(NSString *)taskId callback:(void(^)(TIOFleaTaskDownload * _Nullable download, double progress, NSError * _Nullable error))responseBlock;

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

- (nullable NSURLSessionUploadTask *)uploadJobResultsAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL withJobId:(NSString *)jobId callback:(void(^)(TIOFleaJobUpload * _Nullable upload, double progress, NSError * _Nullable error))responseBlock;

@end

NS_ASSUME_NONNULL_END
