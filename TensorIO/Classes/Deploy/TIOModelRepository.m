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

static NSString * TIOMRErrorDomain = @"ai.doc.tensorio.model-repo";

static NSInteger TIOMRURLSessionErrorCode = 0;
static NSInteger TIOMNoDataErrorCode = 1;
static NSInteger TIOMRJSONError = 2;

static NSInteger TIOMRHealthStatusParsingError = 100;
static NSInteger TIOMRHealthStatusNotServingError = 101;

static NSInteger TIOMRModelsParsingError = 200;
static NSInteger TIOMRModelParsingError = 300;
static NSInteger TIOMRHyperparametersParasingError = 400;
static NSInteger TIOMRHyperparameterParasingError = 500;

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
        
        if ( error != nil ) {
            NSLog(@"error");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRURLSessionErrorCode userInfo:nil]);
            return;
        }
        
        if ( data == nil ) {
            NSLog(@"no data");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMNoDataErrorCode userInfo:nil]);
            return;
        }
        
        NSError *JSONError;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        
        if ( JSONError != nil ) {
            NSLog(@"Unable to parse JSON");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRJSONError userInfo:nil]);
            return;
        }
        
        TIOMRStatus *status = [[TIOMRStatus alloc] initWithJSON:JSON];
        
        if ( status == nil ) {
            NSLog(@"Unable to parse status");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRHealthStatusParsingError userInfo:nil]);
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
        
        if ( error != nil ) {
            NSLog(@"error");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRURLSessionErrorCode userInfo:nil]);
            return;
        }
        
        if ( data == nil ) {
            NSLog(@"no data");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMNoDataErrorCode userInfo:nil]);
            return;
        }
        
        NSError *JSONError;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        
        if ( JSONError != nil ) {
            NSLog(@"Unable to parse JSON");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRJSONError userInfo:nil]);
            return;
        }
        
        TIOMRModels *models = [[TIOMRModels alloc] initWithJSON:JSON];
        
        if ( models == nil ) {
            NSLog(@"Unable to parse models");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRModelsParsingError userInfo:nil]);
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
        
        if ( error != nil ) {
            NSLog(@"error");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRURLSessionErrorCode userInfo:nil]);
            return;
        }
        
        if ( data == nil ) {
            NSLog(@"no data");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMNoDataErrorCode userInfo:nil]);
            return;
        }
        
        NSError *JSONError;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        
        if ( JSONError != nil ) {
            NSLog(@"Unable to parse JSON");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRJSONError userInfo:nil]);
            return;
        }
        
        TIOMRModel *model = [[TIOMRModel alloc] initWithJSON:JSON];
        
        if ( model == nil ) {
            NSLog(@"Unable to parse model");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRModelParsingError userInfo:nil]);
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
        
        if ( error != nil ) {
            NSLog(@"error");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRURLSessionErrorCode userInfo:nil]);
            return;
        }
        
        if ( data == nil ) {
            NSLog(@"no data");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMNoDataErrorCode userInfo:nil]);
            return;
        }
        
        NSError *JSONError;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        
        if ( JSONError != nil ) {
            NSLog(@"Unable to parse JSON");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRJSONError userInfo:nil]);
            return;
        }
        
        TIOMRHyperparameters *hyperparameters = [[TIOMRHyperparameters alloc] initWithJSON:JSON];
        
        if ( hyperparameters == nil ) {
            NSLog(@"Unable to parse hyperparameters");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRHyperparametersParasingError userInfo:nil]);
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
        
        if ( error != nil ) {
            NSLog(@"error");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRURLSessionErrorCode userInfo:nil]);
            return;
        }
        
        if ( data == nil ) {
            NSLog(@"no data");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMNoDataErrorCode userInfo:nil]);
            return;
        }
        
        NSError *JSONError;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        
        if ( JSONError != nil ) {
            NSLog(@"Unable to parse JSON");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRJSONError userInfo:nil]);
            return;
        }
        
        TIOMRHyperparameter *hyperparameter = [[TIOMRHyperparameter alloc] initWithJSON:JSON];
        
        if ( hyperparameter == nil ) {
            NSLog(@"Unable to parse hyperparameters");
            responseBlock(nil, [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRHyperparameterParasingError userInfo:nil]);
            return;
        }
        
        responseBlock(hyperparameter, nil);
    }];
    
    [task resume];
    return task;
 }

@end
