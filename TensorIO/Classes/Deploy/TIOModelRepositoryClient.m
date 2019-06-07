//
//  TIOModelRepositoryClient.m
//  TensorIO
//
//  Created by Philip Dow on 7/6/18.
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

#import "TIOModelRepositoryClient.h"
#import "TIOMRStatus.h"
#import "TIOMRModels.h"
#import "TIOMRModel.h"
#import "TIOMRHyperparameters.h"
#import "TIOMRHyperparameter.h"
#import "TIOMRCheckpoints.h"
#import "TIOMRCheckpoint.h"
#import "TIOMRDownload.h"
#import "TIOMRErrors.h"
#import "TIOErrorHandling.h"
#import "TIOMRClientSessionDelegate.h"
#import "TIOMRClientBackgroundSessionHandler.h"

static NSString * const TIOUserDefaultsClientIdKey = @"TIOClientId";

typedef void (^TIOMRClientDownloadTaskCallbackBlock)
(NSURL * _Nullable location, double progress, NSURLResponse * _Nullable response, NSError * _Nullable error);

// MARK: -

/**
 * Parses a JSON response from a tensorio models repository
 */

@interface TIOModelRepositoryClientJSONResponseParser <ParsedType> : NSObject

- (instancetype)initWithClass:(Class)klass NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property Class klass;

- (nullable ParsedType)parseData:(nullable NSData*)data response:(nullable NSURLResponse*)response requestError:(NSError*)requestError error:(NSError**)error;

@end

@implementation TIOModelRepositoryClientJSONResponseParser

- (instancetype)initWithClass:(Class)klass {
    if ((self=[super init])) {
        _klass = klass;
    }
    return self;
}

- (nullable id)parseData:(nullable NSData*)data response:(nullable NSURLResponse*)response requestError:(NSError*)requestError error:(NSError**)error {
    
    if ( requestError != nil ) {
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"Request error for request with URL: %@", response.URL]),
            TIOMRErrorDomain,
            TIOMRURLRequestErrorCode,
            *error);
        return nil;
    }
    
    if ( ((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299 ) {
        NSString *responseDescription = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, responseDescription]),
            TIOMRErrorDomain,
            TIOMRURLResponseErrorCode,
            *error);
        return nil;
    }
    
    if ( data == nil ) {
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"No data for request with URL: %@", response.URL]),
            TIOMRErrorDomain,
            TIOMRNoDataErrorCode,
            *error);
        return nil;
    }
    
    NSError *JSONError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];

    if ( JSONError != nil ) {
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"Unable to parse JSON for request with URL: %@, error: %@", response.URL, JSONError]),
            TIOMRErrorDomain,
            TIOMRJSONError,
            *error);
        return nil;
    }
    
    NSError *parseError;
    id object = [[_klass alloc] initWithJSON:JSON error:&parseError];
    
    if ( object == nil ) {
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"Unable to deserialize JSON for request with URL: %@, class %@", response.URL, _klass]),
            TIOMRErrorDomain,
            TIOMRDeserializationError,
            *error);
        if ( parseError != nil ) {
            *error = parseError;
        }
        return nil;
    }
    
    return object;
}

@end

// MARK: -

@interface TIOModelRepositoryClient () <NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>

@property (readonly) TIOMRClientSessionDelegate *downloadSessionDelegate;
@property (readonly) NSMutableDictionary<NSURL*, TIOMRClientDownloadTaskCallbackBlock> *downloadTaskCallbacks;

@end

@implementation TIOModelRepositoryClient

+ (NSString*)backgroundSessionIdentifier {
    return @"TIO_MR_CLIENT";
}

- (instancetype)initWithBaseURL:(NSURL*)URL session:(nullable NSURLSession *)URLSession downloadSession:(nullable NSURLSession *)downloadURLSession {
    if ((self=[super init])) {
        [self acquireClientId];
        _URLSession = URLSession ? URLSession : NSURLSession.sharedSession;
        _downloadURLSession = downloadURLSession ? downloadURLSession : NSURLSession.sharedSession;
        _baseURL = URL;
        
        if ( [_downloadURLSession.delegate isKindOfClass:TIOMRClientSessionDelegate.class] ) {
            _downloadTaskCallbacks = NSMutableDictionary.dictionary;
            _downloadSessionDelegate = (TIOMRClientSessionDelegate *)downloadURLSession.delegate;
            _downloadSessionDelegate.client = self;
        }
    }
    return self;
}

- (void)acquireClientId {
    _clientId = [NSUserDefaults.standardUserDefaults stringForKey:TIOUserDefaultsClientIdKey];
    
    if ( _clientId == nil ) {
        _clientId = NSUUID.UUID.UUIDString;
        [NSUserDefaults.standardUserDefaults setObject:_clientId forKey:TIOUserDefaultsClientIdKey];
    }
}

- (BOOL)usesDownloadDelegate {
    return self.downloadSessionDelegate != nil;
}

// MARK: - Base API

- (NSURLSessionTask*)GETHealthStatus:(void(^)(TIOMRStatus * _Nullable status, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [self.baseURL URLByAppendingPathComponent:@"healthz"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryClientJSONResponseParser<TIOMRStatus*> *parser = [[TIOModelRepositoryClientJSONResponseParser alloc] initWithClass:TIOMRStatus.class];
        TIOMRStatus *status = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( status == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        if ( status.status != TIOMRStatusValueServing ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Health returned value other than serving: %@", status]),
                TIOMRErrorDomain,
                TIOMRHealthStatusNotServingError,
                error);
            responseBlock(status, error);
            return;
        }
        
        responseBlock(status, nil);
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask*)GETModels:(void(^)(TIOMRModels * _Nullable models, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [self.baseURL
        URLByAppendingPathComponent:@"models"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryClientJSONResponseParser<TIOMRModels*> *parser = [[TIOModelRepositoryClientJSONResponseParser alloc] initWithClass:TIOMRModels.class];
        TIOMRModels *models = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( models == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        responseBlock(models, nil);
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask*)GETModelWithId:(NSString*)modelId callback:(void(^)(TIOMRModel * _Nullable model, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [[self.baseURL
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:modelId];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryClientJSONResponseParser<TIOMRModel*> *parser = [[TIOModelRepositoryClientJSONResponseParser alloc] initWithClass:TIOMRModel.class];
        TIOMRModel *model = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( model == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        responseBlock(model, nil);
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask*)GETHyperparametersForModelWithId:(NSString*)modelId callback:(void(^)(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [[[self.baseURL
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:modelId]
        URLByAppendingPathComponent:@"hyperparameters"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryClientJSONResponseParser<TIOMRHyperparameters*> *parser = [[TIOModelRepositoryClientJSONResponseParser alloc] initWithClass:TIOMRHyperparameters.class];
        TIOMRHyperparameters *hyperparameters = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( hyperparameters == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        responseBlock(hyperparameters, nil);
    }];
    
    [task resume];
    return task;
}

 - (NSURLSessionTask*)GETHyperparameterForModelWithId:(NSString*)modelId hyperparametersId:(NSString*)hyperparametersId callback:(void(^)(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error))responseBlock {
     NSURL *endpoint = [[[[self.baseURL
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:modelId]
        URLByAppendingPathComponent:@"hyperparameters"]
        URLByAppendingPathComponent:hyperparametersId];
     
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryClientJSONResponseParser<TIOMRHyperparameter*> *parser = [[TIOModelRepositoryClientJSONResponseParser alloc] initWithClass:TIOMRHyperparameter.class];
        TIOMRHyperparameter *hyperparameter = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( hyperparameter == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        responseBlock(hyperparameter, nil);
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask*)GETCheckpointsForModelWithId:(NSString*)modelId hyperparametersId:(NSString*)hyperparametersId callback:(void(^)(TIOMRCheckpoints * _Nullable checkpoints, NSError * _Nullable error))responseBlock {
  
    NSURL *endpoint = [[[[[self.baseURL
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:modelId]
        URLByAppendingPathComponent:@"hyperparameters"]
        URLByAppendingPathComponent:hyperparametersId]
        URLByAppendingPathComponent:@"checkpoints"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryClientJSONResponseParser<TIOMRCheckpoints*> *parser = [[TIOModelRepositoryClientJSONResponseParser alloc] initWithClass:TIOMRCheckpoints.class];
        TIOMRCheckpoints *checkpoints = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( checkpoints == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        responseBlock(checkpoints, nil);
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask*)GETCheckpointForModelWithId:(NSString*)modelId hyperparametersId:(NSString*)hyperparametersId checkpointId:(NSString*)checkpointId callback:(void(^)(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error))responseBlock {
    
    NSURL *endpoint = [[[[[[self.baseURL
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:modelId]
        URLByAppendingPathComponent:@"hyperparameters"]
        URLByAppendingPathComponent:hyperparametersId]
        URLByAppendingPathComponent:@"checkpoints"]
        URLByAppendingPathComponent:checkpointId];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryClientJSONResponseParser<TIOMRCheckpoint*> *parser = [[TIOModelRepositoryClientJSONResponseParser alloc] initWithClass:TIOMRCheckpoint.class];
        TIOMRCheckpoint *checkpoint = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( checkpoint == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        responseBlock(checkpoint, nil);
    }];
    
    [task resume];
    return task;
}

// MARK: - Downloads

- (NSURLSessionDownloadTask*)downloadModelBundleAtURL:(NSURL*)URL withModelId:(NSString*)modelId hyperparametersId:(NSString*)hyperparametersId checkpointId:(NSString*)checkpointId callback:(void(^)(TIOMRDownload * _Nullable download, double progress, NSError * _Nullable error))responseBlock {
    
    // SUCCESS
    // URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:
    // URLSession:downloadTask:didFinishDownloadingToURL:
    // URLSession:task:didCompleteWithError:
    
    // ERROR
    // URLSession:task:didCompleteWithError:
    
    NSURLSessionDownloadTask *task;
    
    TIOMRClientDownloadTaskCallbackBlock callback =
    ^(NSURL * _Nullable location, double progress, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Handle request or response error
        
        if ( error != nil ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Error for request with URL: %@", response.URL]),
                TIOMRErrorDomain,
                TIOMRDownloadError,
                error);
            responseBlock(nil, 0, error);
            return;
        }
        
        // Handle bad HTTP response
        
        if ( response && (((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299) ) {
            NSString *responseDescription = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"HTTP Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, responseDescription]),
                TIOMRErrorDomain,
                TIOMRDownloadError,
                error);
            responseBlock(nil, 0, error);
            return;
        }
        
        // Handle error when task completes but there is no location
        
        if ( progress >= 1 && location == nil ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"File error for request with URL: %@", response.URL]),
                TIOMRErrorDomain,
                TIOMRDownloadError,
                error);
            responseBlock(nil, 0, error);
            return;
        }
        
        // No errors, download is in progress; progress >= 1 and location will be set if completed
        
        if ( location != nil ) {
            TIOMRDownload *download = [[TIOMRDownload alloc] initWithURL:location modelId:modelId hyperparametereId:hyperparametersId checkpointId:checkpointId];
            responseBlock(download, 1, nil);
        } else {
            responseBlock(nil, progress, nil);
        }
        
        // If completed, clean callback
        
        if (progress >= 1) {
            self.downloadTaskCallbacks[URL] = nil;
        }
        
    };
    
    // Handle both delegated and undelegated download sessions
    
    if (self.usesDownloadDelegate) {
        task = [self.downloadURLSession downloadTaskWithURL:URL];
        self.downloadTaskCallbacks[URL] = callback;
    } else {
        task = [self.downloadURLSession downloadTaskWithURL:URL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable requestError) {
            callback(location, 1, response, requestError);
        }];
    }
    
    [task resume];
    return task;
}

// MARK: - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        TIOMRClientBackgroundCompletionHandler handler = TIOMRClientBackgroundSessionHandler.sharedInstance.handler;
        if ( handler == nil ) {
            return;
        }
        handler();
        TIOMRClientBackgroundSessionHandler.sharedInstance.handler = nil;
    });
}

// MARK: - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // Is always called download and upload delegate callbacks are handled differently
    
    if ( [task isKindOfClass:NSURLSessionDownloadTask.class] ) {
        [self _URLSession:session downloadTask:(NSURLSessionDownloadTask *)task didCompleteWithError:error];
        NSLog(@"download task");
        return;
    }
    
    NSLog(@"Unknown task, always handle");
    
    TIOMRClientDownloadTaskCallbackBlock downloadCallback = self.downloadTaskCallbacks[task.originalRequest.URL];
    if (downloadCallback) {
        downloadCallback(nil, 0, task.response, error);
    }
}

- (void)_URLSession:(NSURLSession *)session downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // Is always called, only respond to errors, let success methods handle successes
    
    if (!error) {
        return;
    }
    
    TIOMRClientDownloadTaskCallbackBlock callback = self.downloadTaskCallbacks[task.originalRequest.URL];
    
    if (!callback) {
        return;
    }
    
    callback(nil, 0, task.response, error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    // UPLOAD PROGRESS is called
    ;
}

// MARK: - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    // Is called on success
    
    TIOMRClientDownloadTaskCallbackBlock callback = self.downloadTaskCallbacks[downloadTask.originalRequest.URL];
    
    if (!callback) {
        return;
    }
    
    callback(location, 1, downloadTask.response, nil);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    ;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // DOWNLOAD PROGRESS Is Called
    
    TIOMRClientDownloadTaskCallbackBlock callback = self.downloadTaskCallbacks[downloadTask.originalRequest.URL];
    
    if (!callback) {
        return;
    }
    
    float progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    callback(nil, progress, downloadTask.response, nil);
}

@end
