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

- (NSURLSessionTask*)GETHealthStatus:(void(^)(TIOFleaStatus * _Nullable status, NSError * _Nullable error))responseBlock;

@end

NS_ASSUME_NONNULL_END
