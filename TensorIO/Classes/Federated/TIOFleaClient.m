//
//  TIOFleaClient.m
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

#import "TIOFleaClient.h"
#import "TIOFleaStatus.h"
#import "TIOFleaTasks.h"
#import "TIOFleaTask.h"
#import "TIOFleaJob.h"
#import "TIOFleaTaskDownload.h"
#import "TIOFleaJobUpload.h"
#import "TIOFleaErrors.h"
#import "TIOErrorHandling.h"
#import "TIOFleaClientSessionDelegate.h"
#import "TIOFleaClientBackgroundSessionHandler.h"

static NSString * const TIOUserDefaultsClientIdKey = @"TIOClientId";

typedef void (^TIOFleaClientDownloadTaskCallbackBlock)
(NSURL * _Nullable location, double progress, NSURLResponse * _Nullable response, NSError * _Nullable error);

typedef void (^TIOFleaClientUploadTaskCallbackBlock)
(double progress, NSURLResponse * _Nullable response, NSError * _Nullable error);

// MARK: -

/**
 * Parses a JSON response from a tensorio flea repository
 */

@interface TIOFleaJSONResponseParser <ParsedType> : NSObject

- (instancetype)initWithClass:(Class)klass NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property Class klass;

- (nullable ParsedType)parseData:(nullable NSData*)data response:(nullable NSURLResponse*)response requestError:(NSError*)requestError error:(NSError**)error;

@end

@implementation TIOFleaJSONResponseParser

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
            TIOFleaErrorDomain,
            TIOFleaURLRequestErrorCode,
            *error);
        return nil;
    }
    
    if ( ((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299 ) {
        NSString *responseDescription = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, responseDescription]),
            TIOFleaErrorDomain,
            TIOFleaURLResponseErrorCode,
            *error);
        return nil;
    }
    
    if ( data == nil ) {
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"No data for request with URL: %@", response.URL]),
            TIOFleaErrorDomain,
            TIOFleaNoDataErrorCode,
            *error);
        return nil;
    }
    
    NSError *JSONError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];

    if ( JSONError != nil ) {
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"Unable to parse JSON for request with URL: %@, error: %@", response.URL, JSONError]),
            TIOFleaErrorDomain,
            TIOFleaJSONError,
            *error);
        return nil;
    }
    
    NSError *parseError;
    id object = [[_klass alloc] initWithJSON:JSON error:&parseError];
    
    if ( object == nil ) {
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"Unable to deserialize JSON for request with URL: %@, class %@", response.URL, _klass]),
            TIOFleaErrorDomain,
            TIOFleaDeserializationError,
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

@interface TIOFleaClient() <NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>

@property (readonly) TIOFleaClientSessionDelegate *downloadSessionDelegate;
@property (readonly) NSMutableDictionary<NSURL*, TIOFleaClientDownloadTaskCallbackBlock> *downloadTaskCallbacks;
@property (readonly) NSMutableDictionary<NSURL*, TIOFleaClientUploadTaskCallbackBlock> *uploadTaskCallbacks;

@end

@implementation TIOFleaClient

+ (NSString*)backgroundSessionIdentifier {
    return @"TIO_FLEA_CLIENT";
}

- (instancetype)initWithBaseURL:(NSURL*)URL session:(nullable NSURLSession *)URLSession downloadSession:(nullable NSURLSession *)downloadURLSession {
    if ((self=[super init])) {
        [self acquireClientId];
         _URLSession = URLSession ? URLSession : NSURLSession.sharedSession;
         _downloadURLSession = downloadURLSession ? downloadURLSession : NSURLSession.sharedSession;
        _baseURL = URL;
        
        if ( [_downloadURLSession.delegate isKindOfClass:TIOFleaClientSessionDelegate.class] ) {
            _downloadTaskCallbacks = NSMutableDictionary.dictionary;
            _uploadTaskCallbacks = NSMutableDictionary.dictionary;
            _downloadSessionDelegate = (TIOFleaClientSessionDelegate *)downloadURLSession.delegate;
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

// MARK: - API Requests

- (NSURLSessionTask*)GETHealthStatus:(void(^)(TIOFleaStatus * _Nullable status, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [self.baseURL URLByAppendingPathComponent:@"healthz"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOFleaJSONResponseParser<TIOFleaStatus*> *parser = [[TIOFleaJSONResponseParser alloc] initWithClass:TIOFleaStatus.class];
        TIOFleaStatus *status = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( status == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        if ( status.status != TIOFleaStatusValueServing ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Health returned value other than serving: %@", status]),
                TIOFleaErrorDomain,
                TIOFleaHealthStatusNotServingError,
                error);
            responseBlock(status, error);
            return;
        }
        
        responseBlock(status, nil);
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask*)GETTasksWithModelId:(nullable NSString*)modelId hyperparametersId:(nullable NSString*)hyperparametersId checkpointId:(nullable NSString*)checkpointId callback:(void(^)(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [self.baseURL URLByAppendingPathComponent:@"tasks"];
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:endpoint resolvingAgainstBaseURL:NO];
    NSMutableArray<NSURLQueryItem*> *queryItems = NSMutableArray.array;
    
    if (modelId != nil) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"modelId" value:modelId]];
    }
    if (hyperparametersId != nil) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"hyperparametersId" value:hyperparametersId]];
    }
    if (checkpointId != nil) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"checkpointId" value:checkpointId]];
    }
    
    if (queryItems.count > 0) {
        components.queryItems = queryItems;
    }
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:components.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOFleaJSONResponseParser<TIOFleaTasks*> *parser = [[TIOFleaJSONResponseParser alloc] initWithClass:TIOFleaTasks.class];
        TIOFleaTasks *tasks = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( tasks == nil ) {
            responseBlock(nil, parseError);
            return;
        }
    
        responseBlock(tasks, nil);
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask*)GETTaskWithTaskId:(NSString*)taskId callback:(void(^)(TIOFleaTask * _Nullable task, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [[self.baseURL
        URLByAppendingPathComponent:@"tasks"]
        URLByAppendingPathComponent:taskId];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOFleaJSONResponseParser<TIOFleaTask*> *parser = [[TIOFleaJSONResponseParser alloc] initWithClass:TIOFleaTask.class];
        TIOFleaTask *task = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( task == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        responseBlock(task, nil);
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask*)GETStartTaskWithTaskId:(NSString*)taskId callback:(void(^)(TIOFleaJob * _Nullable job, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [[self.baseURL
        URLByAppendingPathComponent:@"start_task"]
        URLByAppendingPathComponent:taskId];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOFleaJSONResponseParser<TIOFleaJob*> *parser = [[TIOFleaJSONResponseParser alloc] initWithClass:TIOFleaJob.class];
        TIOFleaJob *job = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( job == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        if ( job.status != TIOFleaJobStatusApproved ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Start task returned value other than approved: %@", job]),
                TIOFleaErrorDomain,
                TIOFleaJobStatusNotApprovedError,
                error);
            responseBlock(job, error);
            return;
        }
        
        responseBlock(job, nil);
    }];
    
    [task resume];
    return task;
}

- (nullable NSURLSessionTask*)POSTErrorMessage:(NSString*)errorMessage taskId:(NSString*)taskId jobId:(NSString*)jobId callback:(void(^)(BOOL success, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [[[self.baseURL
        URLByAppendingPathComponent:@"job_error"]
        URLByAppendingPathComponent:taskId]
        URLByAppendingPathComponent:jobId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpoint];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    request.HTTPMethod = @"POST";
    
    NSDictionary *JSON = @{
        @"errorMessage": errorMessage,
        @"clientId": self.clientId
    };
   
    NSError *JSONError;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:&JSONError];
    
    if ( JSONError != nil ) {
        NSLog(@"Error encoding JSON to send to job error endpoint");
        responseBlock(NO, JSONError);
        return nil;
    }
    
    NSURLSessionUploadTask *task = [self.URLSession uploadTaskWithRequest:request fromData:JSONData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable requestError) {
        
        if ( requestError != nil ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Request error for request with URL: %@", response.URL]),
                TIOFleaErrorDomain,
                TIOFleaUploadError,
                error);
            responseBlock(NO, error);
            return;
        }
        
        if ( ((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299 ) {
            NSString *responseDescription = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, responseDescription]),
                TIOFleaErrorDomain,
                TIOFleaURLResponseErrorCode,
                error);
            responseBlock(NO, error);
            return;
        }
        
        responseBlock(YES, nil);
    }];
    
    [task resume];
    return task;
}

// MARK: - Download and Upload

- (NSURLSessionDownloadTask*)downloadTaskBundleAtURL:(NSURL*)URL withTaskId:(NSString*)taskId callback:(void(^)(TIOFleaTaskDownload * _Nullable download, double progress, NSError * _Nullable error))responseBlock {
    
    // SUCCESS
    // URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:
    // URLSession:downloadTask:didFinishDownloadingToURL:
    // URLSession:task:didCompleteWithError:
    
    // ERROR
    // URLSession:task:didCompleteWithError:
    
    NSURLSessionDownloadTask *task;
    
    TIOFleaClientDownloadTaskCallbackBlock callback =
    ^void(NSURL * _Nullable location, double progress, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Handle request or response error
        
        if ( error != nil ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Error for request with URL: %@", response.URL]),
                TIOFleaErrorDomain,
                TIOFleaDownloadError,
                error);
            self.downloadTaskCallbacks[URL] = nil;
            responseBlock(nil, 0, error);
            return;
        }
        
        // Handle bad HTTP response
        
        if ( response && (((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299) ) {
            NSString *responseDescription = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"HTTP Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, responseDescription]),
                TIOFleaErrorDomain,
                TIOFleaURLResponseErrorCode,
                error);
            self.downloadTaskCallbacks[URL] = nil;
            responseBlock(nil, 0, error);
            return;
        }
        
        // Handle error when task completes but there is no location
        
        if ( progress >= 1 && location == nil ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"File error for request with URL: %@", response.URL]),
                TIOFleaErrorDomain,
                TIOFleaDownloadError,
                error);
            self.downloadTaskCallbacks[URL] = nil;
            responseBlock(nil, 0, error);
            return;
        }
        
        // No errors, download is in progress; progress >= 1 and location will be set if completed
        
        if ( location != nil ) {
            TIOFleaTaskDownload *download = [[TIOFleaTaskDownload alloc] initWithURL:location taskId:taskId];
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

- (nullable NSURLSessionUploadTask*)uploadJobResultsAtURL:(NSURL*)sourceURL toURL:(NSURL*)destinationURL withJobId:(NSString*)jobId callback:(void(^)(TIOFleaJobUpload * _Nullable upload, double progress, NSError * _Nullable error))responseBlock {
    
    // SUCCESS
    // URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:
    // URLSession:task:didCompleteWithError:
    
    // ERROR
    // URLSession:task:didCompleteWithError:
    
    // Ensure the upload file exists
    
    if ( ![NSFileManager.defaultManager fileExistsAtPath:sourceURL.path] ) {
        NSError *error;
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"No file at source URL: %@", sourceURL]),
            TIOFleaErrorDomain,
            TIOFleaUploadSourceDoesNotExistsError,
            error);
        responseBlock(nil, 0, error);
        return nil;
    }
    
    // Prepare a PUT request
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:destinationURL];
    [request addValue:@"application/zip" forHTTPHeaderField:@"Content-type"];
    request.HTTPMethod = @"PUT";
    
    NSURLSessionUploadTask *task;
    
    TIOFleaClientUploadTaskCallbackBlock callback =
    ^(double progress, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Handle request or response error
        
        if ( error != nil ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Error for request with URL: %@", response.URL]),
                TIOFleaErrorDomain,
                TIOFleaUploadError,
                error);
            self.uploadTaskCallbacks[destinationURL] = nil;
            responseBlock(nil, 0, error);
            return;
        }
        
        // Handle bad HTTP response
        
        if ( response && (((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299) ) {
            NSString *responseDescription = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"HTTP Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, responseDescription]),
                TIOFleaErrorDomain,
                TIOFleaURLResponseErrorCode,
                error);
            self.uploadTaskCallbacks[destinationURL] = nil;
            responseBlock(nil, 0, error);
            return;
        }
        
        // No errors, upload is in progress; progress >= 1 if completed
        
        if ( progress >= 1 ) {
            TIOFleaJobUpload *upload = [[TIOFleaJobUpload alloc] init];
            responseBlock(upload, 1, nil);
        } else {
            responseBlock(nil, progress, nil);
        }
        
        // If completed, clean callback
        
        if ( progress >= 1 ) {
            NSLog(@"**** RELEASING CALLBACK ****");
            self.uploadTaskCallbacks[destinationURL] = nil;
        }
    };
    
    // Handle both delegated and undelegated download sessions
    
    if (self.usesDownloadDelegate) {
        task = [self.downloadURLSession uploadTaskWithRequest:request fromFile:sourceURL];
        self.uploadTaskCallbacks[destinationURL] = callback;
    } else {
         task = [self.downloadURLSession uploadTaskWithRequest:request fromFile:sourceURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable requestError) {
            callback(1, response, requestError);
         }];
    }
    
    [task resume];
    return task;
}

// MARK: - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    // We're pretty deep in here, really get it from the app?
    dispatch_async(dispatch_get_main_queue(), ^{
        TIOFleaClientBackgroundCompletionHandler handler = TIOFleaClientBackgroundSessionHandler.sharedInstance.handler;
        if ( handler == nil ) {
            return;
        }
        handler();
        TIOFleaClientBackgroundSessionHandler.sharedInstance.handler = nil;
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
    
    if ( [task isKindOfClass:NSURLSessionUploadTask.class] ) {
        [self _URLSession:session uploadTask:(NSURLSessionUploadTask *)task didCompleteWithError:error];
        NSLog(@"upload task");
        return;
    }
    
    NSLog(@"Unknown task, always handle both cases");
    
    TIOFleaClientDownloadTaskCallbackBlock downloadCallback = self.downloadTaskCallbacks[task.originalRequest.URL];
    if (downloadCallback) {
        downloadCallback(nil, 0, task.response, error);
    }
    
    TIOFleaClientUploadTaskCallbackBlock uploadCallback = self.uploadTaskCallbacks[task.originalRequest.URL];
    if (uploadCallback) {
        uploadCallback(0, task.response, error);
    }
}

- (void)_URLSession:(NSURLSession *)session downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // Is always called, only respond to errors, let success methods handle successes
    
    if (!error) {
        return;
    }
    
    TIOFleaClientDownloadTaskCallbackBlock callback = self.downloadTaskCallbacks[task.originalRequest.URL];
    
    if (!callback) {
        return;
    }
    
    callback(nil, 0, task.response, error);
}

- (void)_URLSession:(NSURLSession *)session uploadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // Is always called, there is no completion delegate method for success, so respond to everything
    
    TIOFleaClientUploadTaskCallbackBlock callback = self.uploadTaskCallbacks[task.originalRequest.URL];
    float progress = error == nil ? 1 : 0;
    
    if (!callback) {
        return;
    }
    
    callback(progress, task.response, error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    // UPLOAD PROGRESS is called
    
    TIOFleaClientUploadTaskCallbackBlock callback = self.uploadTaskCallbacks[task.originalRequest.URL];
    
    if (!callback) {
        return;
    }
    
    float progress = (float)totalBytesSent/(float)totalBytesExpectedToSend;
    callback(progress, task.response, nil);
}

// MARK: - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    // Is called on success
    
    TIOFleaClientDownloadTaskCallbackBlock callback = self.downloadTaskCallbacks[downloadTask.originalRequest.URL];
    
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
    
    TIOFleaClientDownloadTaskCallbackBlock callback = self.downloadTaskCallbacks[downloadTask.originalRequest.URL];
    
    if (!callback) {
        return;
    }
    
    float progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    callback(nil, progress, downloadTask.response, nil);
}

@end
