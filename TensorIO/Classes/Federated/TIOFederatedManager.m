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

//  TODO: Re-architect to push jobs into a database backed queue (#114). keep jobs
//  independent of one instead of serially executed from a massive method.
//  communicate job triggers via notifications (would be nice to just see when
//  the db is updated directly but same effect). start all job queues when
//  checkForTasks is called. no effect on empty queue, so activities must
//  make sure to clear jobs from the queue when completed. Mappings that are
//  passed across methods, e.g. taskId=>jobId, taskId=>taskBundleURL should be
//  stored and read as needed

#import "TIOFederatedManager.h"
#import "TIOFederatedManagerDataSourceProvider.h"
#import "TIOFederatedManagerDelegate.h"
#import "TIOFederatedTaskBundle.h"
#import "TIOFleaModelIdentifier.h"
#import "TIOFleaClient.h"
#import "TIOFleaJob.h"
#import "TIOFleaTasks.h"
#import "TIOFleaTask.h"
#import "TIOFleaTaskDownload.h"
#import "TIOModelBundle.h"
#import "TIOModel.h"
#import "TIOTrainableModel.h"
#import "TIOModelTrainer.h"
#import "TIOFederatedTask.h"
#import "TIOModelTrainer+FederatedTask.h"
#import "TIOBatchDataSource.h"

#import <sys/utsname.h>

static NSString * TIOFederatedManagerErrorDomain = @"ai.doc.tensorio.federated-manager";

static NSInteger TIOFederatedManagerTaskUnzipError = 200;
static NSInteger TIOFederatedManagerTaskContentsError = 201;
static NSInteger TIOFederatedManagerFileSystemError = 202;

NSString * TIOOSVersionString() {
    NSOperatingSystemVersion osVersion = NSProcessInfo.processInfo.operatingSystemVersion;
    return [NSString stringWithFormat:@"%ld.%ld.%ld", osVersion.majorVersion, osVersion.minorVersion, osVersion.patchVersion];
}

NSString * TIODeviceInfo() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    return deviceModel;
}

NSString * TIOFrameworkVersion() {
    // TODO: Pull it from the embedded framework bundle (#118)
    return @"0.8.0";
}

// MARK: -

@implementation TIOFederatedManager

- (instancetype)initWithClient:(TIOFleaClient*)client {
    if ((self=[super init])) {
        _client = client;
    }
    return self;
}

- (instancetype)initWithClient:(TIOFleaClient*)client dataSourceProvider:(id<TIOFederatedManagerDataSourceProvider>)dataSourceProvider delegate:(nullable id<TIOFederatedManagerDelegate>)delegate {
    if ((self=[self initWithClient:client])) {
        _dataSourceProvider = dataSourceProvider;
        _delegate = delegate;
    }
    return self;
}

- (void)registerForTasksForModelWithId:(NSString*)modelId {
    // TODO: update in data store
    [[self mutableSetValueForKey:@"registeredModelIds"] addObject:modelId];
}

- (void)unregisterForTasksForModelWithId:(NSString*)modelId {
    // TODO: update in data store
    [[self mutableSetValueForKey:@"registeredModelIds"] removeObject:modelId];
}

- (void)checkForTasks {
    assert(self.dataSourceProvider != nil);
    
    // Assuming 1) The model has already been downloaded
    // Assuming 2) The model has been updated to its latest version
    
    // Note that error handling takes place in each specific method
    // For each registered model, acquire available tasks
    
    for ( NSString *modelId in self.registeredModelIds ) {
        [self tasksForModelId:modelId callback:^(TIOFleaTasks * _Nullable tasks) {
            if (tasks == nil) {
                return;
            }
            
            // For each available task, acquire information about the task
            
            for ( NSString *taskId in tasks.taskIds ) {
                
                [self taskForTaskId:taskId callback:^(TIOFleaTask * _Nullable task) {
                    if (task == nil) {
                        return;
                    }
                    
                    [self informDelegateTaskWillBeginProcessing:taskId];
                    
                    // Once we have information about the task, acquire the task bundle
                    
                    [self taskBundleForTaskId:task.taskId URL:task.link callback:^(TIOFleaTaskDownload * _Nullable taskDownload, NSURL * _Nullable bundleURL) {
                        if (taskDownload == nil) {
                            return;
                        }
                        
                        // TODO: Move the task bundle to a cached location (could take place in taskBundleForTaskId method)
                        // Once we have the task bundle, start the task
                        
                        [self startTaskWithTaskId:task.taskId callback:^(TIOFleaJob * _Nullable job) {
                            if (job == nil) {
                                return;
                            }
                            
                            // TODO: Store the job info, especially the (task id, job id, upload to) tuple
                            // Once we have a job, acquire task and model bundles and execute the task
                            
                            [self executeTaskWithTaskId:task.taskId modelId:modelId taskDownload:taskDownload job:job taskBundleURL:bundleURL callback:^(NSURL * _Nullable resultsBundleZip) {
                                if (resultsBundleZip == nil) {
                                    return;
                                }
                                
                                // Once the task has been executed, upload the results
                                
                                [self uploadJobResultsAtURL:resultsBundleZip toURL:job.uploadTo withJobId:job.jobId callback:^(BOOL success) {
                                    if (!success) {
                                        return;
                                    }
                                    
                                    // Nice job everyone!
                                    
                                    [self informDelegateTaskHasCompleted:taskId];
                                    
                                }]; // uploadJobResultsAtURL
                            }]; // executeTaskWithTaskId
                        }]; // startTaskWithTaskId
                    }]; // taskBundleForTaskId
                }]; // taskForTaskId
            } // for tasks
        }];// tasksForModelId
    } // for models
}

- (void)tasksForModelId:(NSString*)modelId callback:(void(^)(TIOFleaTasks * _Nullable tasks))callback {
    [self informDelegateActionHasBegun:TIOFederatedManagerGetTasks];
    
    TIOFleaModelIdentifier *identifier = [[TIOFleaModelIdentifier alloc] initWithBundleId:modelId];
    
    [self.client GETTasksWithModelId:identifier.modelId hyperparametersId:identifier.hyperparametersId checkpointId:identifier.checkpointId callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) {
        if (error != nil) {
            [self informDelegateOfError:error forAction:TIOFederatedManagerGetTasks];
            callback(nil);
            return;
        }
        
        callback(tasks);
    }];
}

- (void)taskForTaskId:(NSString*)taskId callback:(void(^)(TIOFleaTask * _Nullable task))callback {
    [self informDelegateActionHasBegun:TIOFederatedManagerGetTask];
    
    [self.client GETTaskWithTaskId:taskId callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        if (error != nil) {
            [self informDelegateOfError:error forAction:TIOFederatedManagerGetTask];
            callback(nil);
            return;
        }
        
        callback(task);
    }];
}

- (void)taskBundleForTaskId:(NSString*)taskId URL:(NSURL*)downloadLink callback:(void(^)(TIOFleaTaskDownload * _Nullable taskDownload, NSURL * _Nullable bundleURL))callback {
    [self informDelegateActionHasBegun:TIOFederatedManagerDownloadTaskBundle];
    
    // This method could return a bundle from local storage if we've already downloaded it
    
    [self.client downloadTaskBundleAtURL:downloadLink withTaskId:taskId callback:^(TIOFleaTaskDownload * _Nullable download, double progress, NSError * _Nullable error) {
        if (error != nil) {
            [self informDelegateOfError:error forAction:TIOFederatedManagerDownloadTaskBundle];
            callback(nil, nil);
            return;
        }
        
        [self unzipAndValidateTaskBundleAtURL:download.URL callback:^(NSURL * _Nullable bundleURL) {
            if ( bundleURL == nil ) {
                callback(nil, nil);
                return;
            }
            
            callback(download, bundleURL);
        }];
    }];
}

- (void)unzipAndValidateTaskBundleAtURL:(NSURL*)zipURL callback:(void(^)(NSURL * _Nullable bundleURL))callback {
    [self informDelegateActionHasBegun:TIOFederatedManagerUnpackageTaskBundle];
    
    // Create Temporary Directory
    // TODO: local task storage, inject location into manager
    
    NSFileManager *fm = NSFileManager.defaultManager;
    NSError *fmError;

    NSURL *temporaryDirectory = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:NSUUID.UUID.UUIDString];

    if ( ![fm createDirectoryAtURL:temporaryDirectory withIntermediateDirectories:NO attributes:nil error:&fmError] ) {
        NSError *error = [[NSError alloc] initWithDomain:TIOFederatedManagerErrorDomain code:TIOFederatedManagerFileSystemError userInfo:nil];
        [self informDelegateOfError:error forAction:TIOFederatedManagerUnpackageTaskBundle];
        callback(nil);
        return;
    }
    
    [self unzipTaskBundleAtURL:zipURL toURL:temporaryDirectory callback:^(NSURL * _Nullable bundleURL, NSError * _Nullable error) {
        if (error != nil) {
            [self informDelegateOfError:error forAction:TIOFederatedManagerUnpackageTaskBundle];
            callback(nil);
            return;
        }
        
        // TODO: validate the task bundle
        
        // TODO: if using local storage, copy the task bundle to the destination
        
        callback(bundleURL);
    }];
}

/**
 * Utility method called by unzipAndValidate to unzip task bundle contents.
 * Does not follow same conventions as other methods in the manager. It returns
 * an error and allows the calling method to inform the delegate of that error.
 */

- (void)unzipTaskBundleAtURL:(NSURL*)sourceURL toURL:(NSURL*)destinationURL callback:(void(^)(NSURL * _Nullable bundleURL, NSError * _Nullable error))callback {
    NSFileManager *fm = NSFileManager.defaultManager;
    
    [SSZipArchive unzipFileAtPath:sourceURL.path toDestination:destinationURL.path progressHandler:nil completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        
        // Report unzip errors
        
        if ( error ) {
            NSLog(@"Error unzipping task bundle: %@, to: %@ error: %@", sourceURL, destinationURL, error);
            NSError *error = [[NSError alloc] initWithDomain:TIOFederatedManagerErrorDomain code:TIOFederatedManagerTaskUnzipError userInfo:nil];
            callback(nil, error);
            return;
        }
        
        if ( ![fm fileExistsAtPath:destinationURL.path] ) {
            NSLog(@"Error unzipping task bundle: %@, to: %@ error: %@", sourceURL, destinationURL, error);
            NSError *error = [[NSError alloc] initWithDomain:TIOFederatedManagerErrorDomain code:TIOFederatedManagerTaskUnzipError userInfo:nil];
            callback(nil, error);
            return;
        }
        
        // Confirm unzipped contents are valid
        
        NSError *fmError;
        NSArray *contents = [fm contentsOfDirectoryAtPath:destinationURL.path error:&fmError];
        
        if ( contents == nil || fmError ) {
            NSLog(@"Zipped task bundle at: %@ contains no contents at: %@", sourceURL, destinationURL);
            NSError *error = [[NSError alloc] initWithDomain:TIOFederatedManagerErrorDomain code:TIOFederatedManagerTaskContentsError userInfo:nil];
            callback(nil, error);
            return;
        }
        
        if ( contents.count != 1 ) {
            NSLog(@"Zipped task bundle at: %@ contains incorrect contents at: %@, contents: %@", sourceURL, destinationURL, contents);
            NSError *error = [[NSError alloc] initWithDomain:TIOFederatedManagerErrorDomain code:TIOFederatedManagerTaskContentsError userInfo:nil];
            callback(nil, error);
            return;
        }
        
        // Append the name of the unzipped file to the destination URL and return that as the bundle URL
        
        NSURL *bundleURL = [destinationURL URLByAppendingPathComponent:contents[0]];
        callback(bundleURL, nil);
    }];
}

- (void)startTaskWithTaskId:(NSString*)taskId callback:(void(^)(TIOFleaJob * _Nullable job))callback {
    [self informDelegateActionHasBegun:TIOFederatedManagerStartTask];
    
    [self.client GETStartTaskWithTaskId:taskId callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error) {
        if (error != nil) {
            [self informDelegateOfError:error forAction:TIOFederatedManagerStartTask];
            callback(nil);
            return;
        }
        
        callback(job);
    }];
}

- (void)executeTaskWithTaskId:(NSString*)taskId modelId:(NSString*)modelId taskDownload:(TIOFleaTaskDownload*)taskDownload job:(TIOFleaJob*)job taskBundleURL:(NSURL*)taskBundleURL callback:(void(^)(NSURL * _Nullable resultsBundleZip))callback {
    [self informDelegateActionHasBegun:TIOFederatedManagerLoadTask];
    
    // Load Task
    
    TIOFederatedTaskBundle *taskBundle = [[TIOFederatedTaskBundle alloc] initWithPath:taskBundleURL.path];
    
    if (taskBundle == nil) {
        // TODO: construct error
        [self informDelegateOfError:nil forAction:TIOFederatedManagerLoadTask];
        callback(nil);
        return;
    }
    
    TIOFederatedTask *task = taskBundle.task;
    
    if (task == nil) {
        // TODO: construct error
        [self informDelegateOfError:nil forAction:TIOFederatedManagerLoadTask];
        callback(nil);
        return;
    }
    
    // Load Model
    
    [self informDelegateActionHasBegun:TIOFederatedManagerLoadModel];
    
    TIOModelBundle *modelBundle = [self modelBundleForId:modelId];
    
    if (modelBundle == nil) {
        // TODO: construct error
        [self informDelegateOfError:nil forAction:TIOFederatedManagerLoadModel];
        callback(nil);
        return;
    }
    
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)modelBundle.newModel;
    
    if (model == nil) {
        // TODO: construct error
        [self informDelegateOfError:nil forAction:TIOFederatedManagerLoadModel];
        callback(nil);
        return;
    }
    
    // Execute Task on Model
    
    [self informDelegateActionHasBegun:TIOFederatedManagerTrainModel];
    
    id<TIOBatchDataSource> dataSource = [self dataSourceForTask:task];
    
    if (dataSource == nil) {
        // TODO: construct error
        [self informDelegateOfError:nil forAction:TIOFederatedManagerTrainModel];
        callback(nil);
    }
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model task:task dataSource:dataSource];
    id<TIOData> results = [trainer train];
    
    // TODO: Save model: move to separate method
    
    NSFileManager *fm = NSFileManager.defaultManager;
    NSError *fmError;
    
    NSString *UUID = job.jobId;
    NSURL *resultsDir = [[[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:UUID] URLByAppendingPathExtension:@"tioresults"];
    NSURL *checkpointsDir = [resultsDir URLByAppendingPathComponent:@"checkpoints"];
    NSURL *resultsJSONFile = [resultsDir URLByAppendingPathComponent:@"results.json"];
    NSURL *zipFile = [resultsDir URLByAppendingPathExtension:@"zip"];
    
    [fm createDirectoryAtURL:resultsDir withIntermediateDirectories:NO attributes:nil error:&fmError];
    
    if ( fmError != nil ) {
        // TODO: handle error
    }
    
    [fm createDirectoryAtURL:checkpointsDir withIntermediateDirectories:NO attributes:nil error:&fmError];
    
    if ( fmError != nil ) {
        // TODO: handle error
    }
    
    NSError *exportError;
    [model exportTo:checkpointsDir error:&exportError];
    
    if ( exportError != nil ) {
        // TODO: handle error
    }
    
    // TODO: fucking JSON encode, fix escaped forward slashes in URL strings
    
    NSDictionary *JSON = @{
        @"taskId": taskId,
        @"numSamples": @(dataSource.numberOfItems),
        @"results": results,
        @"taskParameters": @{
            @"numEpochs": @(task.epochs),
            @"batchSize": @(task.batchSize),
            @"placeholders": task.placeholders == nil ? NSNull.null : task.placeholders
        },
        @"deviceInfo": @{
            @"deviceType": TIODeviceInfo(),
            @"osVersion": TIOOSVersionString(),
            @"tensorIOVersion": TIOFrameworkVersion()
        },
        @"profiling": @{
        
        }
    };
    
    NSError *JSONError;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:&JSONError];
    
    if ( JSONError != nil ) {
        // TODO: handle error
    }
    
    NSError *writeError;
    [JSONData writeToURL:resultsJSONFile options:NSDataWritingAtomic error:&writeError];
    
    if ( writeError != nil ) {
        // TODO: handle error
    }
    
    BOOL didZip = [SSZipArchive createZipFileAtPath:zipFile.path withContentsOfDirectory:resultsDir.path];
    
    if ( !didZip ) {
        // TODO: handle error
    }
    
    callback(zipFile);
}

- (void)uploadJobResultsAtURL:(NSURL*)sourceURL toURL:(NSURL*)destinationURL withJobId:(NSString*)jobId callback:(void(^)(BOOL success))callback {
    [self informDelegateActionHasBegun:TIOFederatedManagerUploadTaskResults];
    
    [self.client uploadJobResultsAtURL:sourceURL toURL:destinationURL withJobId:jobId callback:^(TIOFleaJobUpload * _Nullable upload, double progress, NSError * _Nullable error) {
        if (error != nil) {
            [self informDelegateOfError:error forAction:TIOFederatedManagerUploadTaskResults];
            callback(NO);
            return;
        }
        
        callback(YES);
    }];
}

// MARK: - Data Source Interactions

- (nullable TIOModelBundle*)modelBundleForId:(NSString*)modelId {
    return [self.dataSourceProvider federatedManager:self modelBundleForModelWithId:modelId];
}

- (id<TIOBatchDataSource>)dataSourceForTask:(TIOFederatedTask*)task {
    return [self.dataSourceProvider federatedManager:self dataSourceForTaskWithId:task.identifier];
}

// MARK: - Delegate Interactions

- (void)informDelegateTaskHasCompleted:(NSString*)taskId {
    if ( !self.delegate ) {
        return;
    }
    if ( ![self.delegate respondsToSelector:@selector(federatedManager:didCompleteTaskWithId:)]) {
        return;
    }
    
    [self.delegate federatedManager:self didCompleteTaskWithId:taskId];
}

- (void)informDelegateTaskWillBeginProcessing:(NSString*)taskId {
    if ( !self.delegate ) {
        return;
    }
    if ( ![self.delegate respondsToSelector:@selector(federatedManager:willBeginProcessingTaskWithId:)]) {
        return;
    }
    
    [self.delegate federatedManager:self willBeginProcessingTaskWithId:taskId];
}

- (void)informDelegateActionHasBegun:(TIOFederatedManagerAction)action {
    if ( !self.delegate ) {
        return;
    }
    if ( ![self.delegate respondsToSelector:@selector(federatedManager:didBeginAction:)]) {
        return;
    }
    
    [self.delegate federatedManager:self didBeginAction:action];
}

- (void)informDelegateOfError:(NSError*)error forAction:(TIOFederatedManagerAction)action {
     if ( !self.delegate ) {
        return;
    }
    if ( ![self.delegate respondsToSelector:@selector(federatedManager:didFailWithError:forAction:)]) {
        return;
    }
    
    [self.delegate federatedManager:self didFailWithError:error forAction:action];
}

@end
