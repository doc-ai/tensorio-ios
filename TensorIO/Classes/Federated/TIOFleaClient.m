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

static NSString * const TIOUserDefaultsClientIdKey = @"TIOClientId";

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
        NSLog(@"Request error for request with URL: %@", response.URL);
        *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaURLRequestErrorCode userInfo:nil];
        return nil;
    }
    
    if ( ((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299 ) {
        NSString *description = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
        NSLog(@"Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, description);
        *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaURLResponseErrorCode userInfo:nil];
        return nil;
    }
    
    if ( data == nil ) {
        NSLog(@"No data for request with URL: %@", response.URL);
        *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaNoDataErrorCode userInfo:nil];
        return nil;
    }
    
    NSError *JSONError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];

    if ( JSONError != nil ) {
        NSLog(@"Unable to parse JSON for request with URL: %@", response.URL);
        *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaJSONError userInfo:nil];
        return nil;
    }
    
    NSError *parseError;
    id object = [[_klass alloc] initWithJSON:JSON error:&parseError];
    
    if ( object == nil ) {
        NSLog(@"Unable to deserialize JSON for request with URL: %@, class %@", response.URL, _klass);
        if ( parseError != nil ) {
            *error = parseError;
        } else {
            *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaDeserializationError userInfo:nil];
        }
        return nil;
    }
    
    return object;
}

@end

// MARK: -

@implementation TIOFleaClient

- (instancetype)initWithBaseURL:(NSURL*)URL session:(nullable NSURLSession *)URLSession downloadSession:(nullable NSURLSession *)downloadURLSession {
    if ((self=[super init])) {
        [self acquireClientId];
         _URLSession = URLSession ? URLSession : NSURLSession.sharedSession;
         _downloadURLSession = downloadURLSession ? downloadURLSession : NSURLSession.sharedSession;
        _baseURL = URL;
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

// MARK: -

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
            NSLog(@"Health returned value other than serving");
            responseBlock(status, [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaHealthStatusNotServingError userInfo:nil]);
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
            NSLog(@"Start task returned value other than approved");
            responseBlock(job, [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaJobStatusNotApprovedError userInfo:nil]);
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
        NSLog(@"Error encoding JSON to send to job error endpoing");
        responseBlock(NO, JSONError);
        return nil;
    }
    
    NSURLSessionUploadTask *task = [self.URLSession uploadTaskWithRequest:request fromData:JSONData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable requestError) {
        
        if ( requestError != nil ) {
            NSLog(@"Request error for request with URL: %@", response.URL);
            NSError *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaUploadError userInfo:nil];
            responseBlock(NO, error);
            return;
        }
        
        if ( ((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299 ) {
            NSString *description = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
            NSLog(@"Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, description);
            NSError *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaURLResponseErrorCode userInfo:nil];
            responseBlock(NO, error);
            return;
        }
        
        responseBlock(YES, nil);
    }];
    
    [task resume];
    return task;
}

// MARK: -

- (NSURLSessionDownloadTask*)downloadTaskBundleAtURL:(NSURL*)URL withTaskId:(NSString*)taskId callback:(void(^)(TIOFleaTaskDownload * _Nullable download, double progress, NSError * _Nullable error))responseBlock {
    
    NSURLSessionDownloadTask *task = [self.downloadURLSession downloadTaskWithURL:URL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable requestError) {
        
        if ( requestError != nil ) {
            NSLog(@"Request error for request with URL: %@", response.URL);
            NSError *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaDownloadError userInfo:nil];
            responseBlock(nil, 0, error);
            return;
        }
        
        if ( ((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299 ) {
            NSString *description = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
            NSLog(@"Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, description);
            NSError *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaURLResponseErrorCode userInfo:nil];
            responseBlock(nil, 0, error);
            return;
        }
        
        if ( location == nil ) {
            NSLog(@"File error for request with URL: %@", response.URL);
            NSError *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaDownloadError userInfo:nil];
            responseBlock(nil, 0, error);
            return;
        }
        
        TIOFleaTaskDownload *download = [[TIOFleaTaskDownload alloc] initWithURL:location taskId:taskId];
        responseBlock(download, 1, nil);
    }];
    
    [task resume];
    return task;
}

- (nullable NSURLSessionUploadTask*)uploadJobResultsAtURL:(NSURL*)sourceURL toURL:(NSURL*)destinationURL withJobId:(NSString*)jobId callback:(void(^)(TIOFleaJobUpload * _Nullable upload, double progress, NSError * _Nullable error))responseBlock {
    
    if ( ![NSFileManager.defaultManager fileExistsAtPath:sourceURL.path] ) {
        NSLog(@"No file at source URL: %@", sourceURL);
        NSError *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaUploadSourceDoesNotExistsError userInfo:nil];
        responseBlock(nil, 0, error);
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:destinationURL];
    [request addValue:@"application/zip" forHTTPHeaderField:@"Content-type"];
    request.HTTPMethod = @"PUT";
    
    NSURLSessionUploadTask *task = [self.downloadURLSession uploadTaskWithRequest:request fromFile:sourceURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable requestError) {
        
        if ( requestError != nil ) {
            NSLog(@"Request error for request with URL: %@", response.URL);
            NSError *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaUploadError userInfo:nil];
            responseBlock(nil, 0, error);
            return;
        }
        
        if ( ((NSHTTPURLResponse*)response).statusCode < 200 || ((NSHTTPURLResponse*)response).statusCode > 299 ) {
            NSString *description = [NSHTTPURLResponse localizedStringForStatusCode:((NSHTTPURLResponse*)response).statusCode];
            NSLog(@"Response error, status code not 200 OK: %ld, %@", ((NSHTTPURLResponse*)response).statusCode, description);
            NSError *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaURLResponseErrorCode userInfo:nil];
            responseBlock(nil, 0, error);
            return;
        }
        
        TIOFleaJobUpload *upload = [[TIOFleaJobUpload alloc] init];
        responseBlock(upload, 1, nil);
    }];
    
    [task resume];
    return task;
}

@end
