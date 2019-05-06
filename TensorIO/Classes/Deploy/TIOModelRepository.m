//
//  TIOModelRepository.m
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

#import "TIOModelRepository.h"
#import "TIOMRStatus.h"
#import "TIOMRModels.h"
#import "TIOMRModel.h"
#import "TIOMRHyperparameters.h"
#import "TIOMRHyperparameter.h"
#import "TIOMRCheckpoints.h"

static NSString * TIOMRErrorDomain = @"ai.doc.tensorio.model-repo";

static NSInteger TIOMRURLSessionErrorCode = 0;
static NSInteger TIOMNoDataErrorCode = 1;
static NSInteger TIOMRJSONError = 2;
static NSInteger TIMORDeserializationError = 3;

static NSInteger TIOMRHealthStatusNotServingError = 100;

/**
 * Parses a JSON response from a tensorio models repository
 */

@interface TIOModelRepositoryJSONResponseParser <ParsedType> : NSObject

- (instancetype)initWithClass:(Class)klass NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property Class klass;

- (nullable ParsedType)parseData:(nullable NSData*)data response:(nullable NSURLResponse*)response requestError:(NSError*)requestError error:(NSError**)error;

@end

@implementation TIOModelRepositoryJSONResponseParser

- (instancetype)initWithClass:(Class)klass {
    if ((self=[super init])) {
        _klass = klass;
    }
    return self;
}

- (nullable id)parseData:(nullable NSData*)data response:(nullable NSURLResponse*)response requestError:(NSError*)requestError error:(NSError**)error {
    
    if ( requestError != nil ) {
        NSLog(@"Request error for request with URL: %@", response.URL);
        *error = [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRURLSessionErrorCode userInfo:nil];
        return nil;
    }
    
    if ( data == nil ) {
        NSLog(@"No data for request with URL: %@", response.URL);
        *error = [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMNoDataErrorCode userInfo:nil];
        return nil;
    }
    
    NSError *JSONError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];

    if ( JSONError != nil ) {
        NSLog(@"Unable to parse JSON for request with URL: %@", response.URL);
        *error = [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRJSONError userInfo:nil];
        return nil;
    }
    
    id object = [[_klass alloc] initWithJSON:JSON];
    
    if ( object == nil ) {
        NSLog(@"Unable to deserialize JSON for request with URL: %@, class %@", response.URL, _klass);
        *error = [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIMORDeserializationError userInfo:nil];
        return nil;
    }
    
    return object;
}

@end

// MARK: -

@interface TIOModelRepository ()

@end

@implementation TIOModelRepository : NSObject

- (instancetype)initWithBaseURL:(NSURL*)URL session:(nullable NSURLSession *)URLSession {
    if ((self=[super init])) {
        _URLSession = URLSession ? URLSession : NSURLSession.sharedSession;
        _baseURL = URL;
    }
    return self;
}

- (NSURLSessionTask*)GETHealthStatus:(void(^)(TIOMRStatus * _Nullable response, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [self.baseURL URLByAppendingPathComponent:@"healthz"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryJSONResponseParser<TIOMRStatus*> *parser = [[TIOModelRepositoryJSONResponseParser alloc] initWithClass:TIOMRStatus.class];
        TIOMRStatus *status = [parser parseData:data response:response requestError:error error:&parseError];
        
        if ( status == nil ) {
            responseBlock(nil, parseError);
            return;
        }
        
        if ( status.status != TIOMRStatusValueServing ) {
            NSLog(@"Health returned value other than serving");
            responseBlock(status, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRHealthStatusNotServingError userInfo:nil]);
            return;
        }
        
        responseBlock(status, nil);
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask*)GETModels:(void(^)(TIOMRModels * _Nullable response, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [self.baseURL
        URLByAppendingPathComponent:@"models"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryJSONResponseParser<TIOMRModels*> *parser = [[TIOModelRepositoryJSONResponseParser alloc] initWithClass:TIOMRModels.class];
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

- (NSURLSessionTask*)GETModelWithId:(NSString*)modelId callback:(void(^)(TIOMRModel * _Nullable response, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [[self.baseURL
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:modelId];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryJSONResponseParser<TIOMRModel*> *parser = [[TIOModelRepositoryJSONResponseParser alloc] initWithClass:TIOMRModel.class];
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

- (NSURLSessionTask*)GETHyperparametersForModelWithId:(NSString*)modelId callback:(void(^)(TIOMRHyperparameters * _Nullable response, NSError * _Nullable error))responseBlock {
    NSURL *endpoint = [[[self.baseURL
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:modelId]
        URLByAppendingPathComponent:@"hyperparameters"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryJSONResponseParser<TIOMRHyperparameters*> *parser = [[TIOModelRepositoryJSONResponseParser alloc] initWithClass:TIOMRHyperparameters.class];
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

 - (NSURLSessionTask*)GETHyperparameterForModelWithId:(NSString*)modelId hyperparameterId:(NSString*)hyperparameterId callback:(void(^)(TIOMRHyperparameter * _Nullable response, NSError * _Nullable error))responseBlock {
     NSURL *endpoint = [[[[self.baseURL
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:modelId]
        URLByAppendingPathComponent:@"hyperparameters"]
        URLByAppendingPathComponent:hyperparameterId];
     
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryJSONResponseParser<TIOMRHyperparameter*> *parser = [[TIOModelRepositoryJSONResponseParser alloc] initWithClass:TIOMRHyperparameter.class];
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

- (NSURLSessionTask*)GETCheckpointsForModelWithId:(NSString*)modelId hyperparameterId:(NSString*)hyperparameterId callback:(void(^)(TIOMRCheckpoints * _Nullable response, NSError * _Nullable error))responseBlock {
  
    NSURL *endpoint = [[[[[self.baseURL
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:modelId]
        URLByAppendingPathComponent:@"hyperparameters"]
        URLByAppendingPathComponent:hyperparameterId]
        URLByAppendingPathComponent:@"checkpoints"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *parseError;
        TIOModelRepositoryJSONResponseParser<TIOMRCheckpoints*> *parser = [[TIOModelRepositoryJSONResponseParser alloc] initWithClass:TIOMRCheckpoints.class];
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

@end
