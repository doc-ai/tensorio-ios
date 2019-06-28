//
//  TIOFederatedTaskBundle.h
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

@class TIOFederatedTask;

/**
 * The file extension used to identify a Federated Task bundle, currently '.tiotask'.
 */

extern NSString * const TIOFederatedTaskBundleExtension;

/**
 * The name of the file inside a Federated Task bundle that contains the task
 * description, currently 'task.json'.
 */

extern NSString * const TIOTaskInfoFile;

/**
 * Encapsulates information about a Federated Task and any assets required for
 * it. Currently the bundle only contains a task.json file describing the task,
 * but it may include additional information or assets at a later date.
 *
 * It is unlikely you will need to use this class directly, as it is instantiated
 * from bundles returned by a `TIOFleaClient`.
 */

@interface TIOFederatedTaskBundle : NSObject

/**
 * The full path to the federated task bundle.
 */

@property (readonly) NSString *path;

/**
 * The federated task encapsulated by this bundle
 */

@property (readonly) TIOFederatedTask *task;

/**
 * The designated initializer.
 *
 * @param path Fully qualified path to the federated task bundle.
 *
 * @return An instance of a `TIOFederatedTaskBundle` or `nil` if no bundle could be loaded at that path.
 */

- (nullable instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
