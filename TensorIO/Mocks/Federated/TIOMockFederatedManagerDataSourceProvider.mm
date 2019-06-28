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

#import "TIOMockFederatedManagerDataSourceProvider.h"

@interface TIOMockFederatedManagerDataSourceProvider ()

@property (readwrite) NSDictionary<NSString*,TIOMockBatchDataSource*> *dataSources;
@property (readwrite) NSDictionary<NSString*,TIOMockModelBundle*> *modelBundles;

@property (readwrite) NSDictionary<NSString*,NSNumber*> *dataSourceForTaskWithIdCount;
@property (readwrite) NSDictionary<NSString*,NSNumber*> *modelBundleForModelWithIdCount;

@end

@implementation TIOMockFederatedManagerDataSourceProvider

- (id)init {
    if ((self=[super init])) {
        _dataSources = NSMutableDictionary.dictionary;
        _dataSourceForTaskWithIdCount = NSMutableDictionary.dictionary;
        
        _modelBundles = NSMutableDictionary.dictionary;
        _modelBundleForModelWithIdCount = NSMutableDictionary.dictionary;
    }
    return self;
}

// MARK: - Data Sources

- (void)setDataSource:(TIOMockBatchDataSource *)dataSource forTaskId:(NSString *)taskIdentifier {
    ((NSMutableDictionary *)_dataSources)[taskIdentifier] = dataSource;
    ((NSMutableDictionary *)_dataSourceForTaskWithIdCount)[taskIdentifier] = @(0);
}

- (void)removeDataSourceForTaskId:(NSString *)taskIdentifier {
    [(NSMutableDictionary *)_dataSources removeObjectForKey:taskIdentifier];
    [(NSMutableDictionary *)_dataSourceForTaskWithIdCount removeObjectForKey:taskIdentifier];
}

- (NSUInteger)dataSourceForTaskWithIdCountForTaskId:(NSString *)taskIdentifier {
    return _dataSourceForTaskWithIdCount[taskIdentifier].unsignedIntegerValue;
}

// MARK: - Model Bundles

- (void)setModelBundle:(TIOMockModelBundle *)modelBundel forModelId:(NSString *)modelIdentifier {
    ((NSMutableDictionary *)_modelBundles)[modelIdentifier] = modelBundel;
    ((NSMutableDictionary *)_modelBundleForModelWithIdCount)[modelIdentifier] = @(0);
}

- (void)removeModelBundleForModelId:(NSString *)modelIdentifier {
    [(NSMutableDictionary *)_modelBundles removeObjectForKey:modelIdentifier];
    [(NSMutableDictionary *)_modelBundleForModelWithIdCount removeObjectForKey:modelIdentifier];
}

- (NSUInteger)modelBundleForModelWithIdCountForModelId:(NSString *)modelIdentifier {
    return _modelBundleForModelWithIdCount[modelIdentifier].unsignedIntegerValue;
}

// MARK: -

- (id<TIOBatchDataSource>)federatedManager:(TIOFederatedManager *)manager dataSourceForTaskWithId:(NSString *)taskIdentifier {
    if ( _dataSourceForTaskWithIdCount[taskIdentifier] == nil ) {
        return nil;
    }
    
    ((NSMutableDictionary *)_dataSourceForTaskWithIdCount)[taskIdentifier] = @(_dataSourceForTaskWithIdCount[taskIdentifier].unsignedIntegerValue+1);
    return self.dataSources[taskIdentifier];
}

- (nullable TIOModelBundle *)federatedManager:(TIOFederatedManager *)manager modelBundleForModelWithId:(NSString *)modelIdentifier {
    if ( _modelBundleForModelWithIdCount[modelIdentifier] == nil ) {
        return nil;
    }
    
    ((NSMutableDictionary *)_modelBundleForModelWithIdCount)[modelIdentifier] = @(_modelBundleForModelWithIdCount[modelIdentifier].unsignedIntegerValue+1);
    return self.modelBundles[modelIdentifier];
}

@end
