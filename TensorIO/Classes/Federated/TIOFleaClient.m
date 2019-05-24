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
#import "TIOFleaTaskDownload.h"

static NSString *TIOFleaErrorDomain = @"ai.doc.tensorio.flea";

static NSInteger TIOFleaURLSessionErrorCode = 0;
static NSInteger TIOFleaNoDataErrorCode = 1;
static NSInteger TIOFleaJSONError = 2;
static NSInteger TIOFleaDeserializationError = 3;

static NSInteger TIOFleaHealthStatusNotServingError = 100;
static NSInteger TIOFleaDownloadError = 200;

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
        *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaURLSessionErrorCode userInfo:nil];
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
    
    id object = [[_klass alloc] initWithJSON:JSON];
    
    if ( object == nil ) {
        NSLog(@"Unable to deserialize JSON for request with URL: %@, class %@", response.URL, _klass);
        *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaDeserializationError userInfo:nil];
        return nil;
    }
    
    return object;
}

@end

// MARK: -

@implementation TIOFleaClient

- (instancetype)initWithBaseURL:(NSURL*)URL session:(nullable NSURLSession *)URLSession {
    if ((self=[super init])) {
        _URLSession = URLSession ? URLSession : NSURLSession.sharedSession;
        _baseURL = URL;
    }
    return self;
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

- (NSURLSessionDownloadTask*)downloadTaskBundleAtURL:(NSURL*)URL withTaskId:(NSString*)taskId callback:(void(^)(TIOFleaTaskDownload * _Nullable download, double progress, NSError * _Nullable error))responseBlock {
    
    NSURLSessionDownloadTask *task = [self.URLSession downloadTaskWithURL:URL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable requestError) {
        
        if ( requestError != nil ) {
            NSLog(@"Request error for request with URL: %@", response.URL);
            NSError *error = [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaDownloadError userInfo:nil];
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

@end
