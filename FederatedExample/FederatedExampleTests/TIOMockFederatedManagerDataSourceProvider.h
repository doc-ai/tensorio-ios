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

NS_ASSUME_NONNULL_BEGIN

/**
 * Vends mock data sources to a federated manager and tracks how often requests
 * for a data source for a task are requested.
 */

@interface TIOMockFederatedManagerDataSourceProvider : NSObject <TIOFederatedManagerDataSourceProvider>

@property NSDictionary<NSString*,TIOMockBatchDataSource*> *dataSources;

- (instancetype)initWithDataSource:(TIOMockBatchDataSource*)dataSource taskIdentifier:(NSString*)tastaskIdentifierkId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)addDataSource:(TIOMockBatchDataSource*)dataSource forTaskId:(NSString*)taskId;
- (void)removeDataSource:(TIOMockBatchDataSource*)dataSource forTaskId:(NSString*)taskId;

@end

NS_ASSUME_NONNULL_END
