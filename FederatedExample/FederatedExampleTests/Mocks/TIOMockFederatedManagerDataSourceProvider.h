//
//  TIOMockFederatedManagerDataSourceProvider.h
//  FederatedExampleTests
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
#import <TensorIO/TensorIO-umbrella.h>
#import "TIOMockBatchDataSource.h"
#import "TIOMockModelBundle.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Vends mock data sources and model bundles to a federated manager and tracks
 * how often requests for a data source or bundle are requested.
 */

@interface TIOMockFederatedManagerDataSourceProvider : NSObject <TIOFederatedManagerDataSourceProvider>

@property (readonly) NSDictionary<NSString*,TIOMockBatchDataSource*> *dataSources;
@property (readonly) NSDictionary<NSString*,TIOMockModelBundle*> *modelBundles;

/**
 * Tracks number of times federatedManager:dataSourceForTaskWithId: has been called for a
 * particular task.
 */

@property (readonly) NSDictionary<NSString*,NSNumber*> *dataSourceForTaskWithIdCount;
- (NSUInteger)dataSourceForTaskWithIdCountForTaskId:(NSString*)taskIdentifier;

/**
 * Tracks the number of times federatedManager:modelBundleForId: has been called
 * for a particular model bundle.
 */

@property (readonly) NSDictionary<NSString*,NSNumber*> *modelBundleForModelWithIdCount;
- (NSUInteger)modelBundleForModelWithIdCountForModelId:(NSString*)modelIdentifier;

/**
 * Sets and remove data sources
 */

- (void)setDataSource:(TIOMockBatchDataSource*)dataSource forTaskId:(NSString*)taskId;
- (void)removeDataSourceForTaskId:(NSString*)taskId;

/**
 * Sets and removes model bundles
 */

- (void)setModelBundle:(TIOMockModelBundle*)modelBundel forModelId:(NSString*)modelId;
- (void)removeModelBundleForModelId:(NSString*)modelId;

@end

NS_ASSUME_NONNULL_END
