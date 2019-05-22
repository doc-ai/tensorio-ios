//
//  TIOMockFederatedManagerDataSourceProvider.mm
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

#import "TIOFederatedManagerDataSourceProvider.h"

@implementation TIOFederatedManagerDataSourceProvider

- (id)initWithDataSource:(TIOMockBatchDataSource*)dataSource taskIdentifier:(NSString*)taskIdentifier {
    if ((self=[super init])) {
        _dataSources = NSMutableDictionary.dictionary;
        ((NSMutableDictionary*)_dataSources)[taskIdentifier] = dataSource;
    }
    return self;
}

- (void)addDataSource:(TIOMockBatchDataSource*)dataSource forTaskId:(NSString*)taskIdentifier {
    ((NSMutableDictionary*)_dataSources)[taskIdentifier] = dataSource;
}

- (void)removeDataSource:(TIOMockBatchDataSource*)dataSource forTaskId:(NSString*)taskIdentifier {
    [(NSMutableDictionary*)_dataSources removeObjectForKey:taskIdentifier];
}

// MARK: -

- (id<TIOBatchDataSource>)dataSourceForTaskWithId:(NSString*)taskIdentifier {
    return self.dataSources[taskIdentifier];
}

@end
