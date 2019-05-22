//
//  TIOFederatedManager.m
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

#import "TIOFederatedManager.h"
#import "TIOFederatedManagerDataSourceProvider.h"
#import "TIOFederatedManagerDelegate.h"
#import "TIOFederatedTaskBundle.h"
#import "TIOModelBundle.h"
#import "TIOModel.h"
#import "TIOTrainableModel.h"
#import "TIOModelTrainer.h"
#import "TIOFederatedTask.h"
#import "TIOModelTrainer+FederatedTask.h"
#import "TIOBatchDataSource.h"

@implementation TIOFederatedManager

- (instancetype)initWithDataSourceProvider:(id<TIOFederatedManagerDataSourceProvider>)dataSourceProvider delegate:(nullable id<TIOFederatedManagerDelegate>)delegate {
    if ((self=[self init])) {
        _dataSourceProvider = dataSourceProvider;
        _delegate = delegate;
    }
    return self;
}

- (void)registerForTasksForModelWithId:(NSString*)modelId {
    [[self mutableArrayValueForKey:@"registeredModelIds"] addObject:modelId];
}


- (void)unregisterForTasksForModelWithId:(NSString*)modelId {
    [[self mutableArrayValueForKey:@"registeredModelIds"] removeObject:modelId];
}

- (void)checkForTasks {
    assert(self.dataSourceProvider != nil);
    
    // For each registered model id:
    
    // : Check if there are any tasks available for it
    
    // : If there are tasks, download the task bundle
    
    // : If the model is not available, download the model
    
    // : [ If the model has an update, update the model - or earlier? ]
    
    // : Given a task bundle and model bundle:
    
    // :: Request a data source from the data source provider
    
    // :: Execute the task with a trainer, model, and data source
    
    // :: Return the results of the task to the server
}

- (id<TIOData>)executeTask:(TIOFederatedTask*)task model:(id<TIOTrainableModel>)model {
    id<TIOBatchDataSource> dataSource = [self dataSourceForTask:task];
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model task:task dataSource:dataSource];
    id<TIOData> results = [trainer train];
    
    return results;
}

- (id<TIOBatchDataSource>)dataSourceForTask:(TIOFederatedTask*)task {
    return [self.dataSourceProvider dataSourceForTaskWithId:task.identifier];
}

@end
