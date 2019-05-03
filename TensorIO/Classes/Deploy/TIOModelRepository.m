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

- (NSURLSessionTask*)GETHealthStatus:(void(^)(TIOMRStatus * _Nullable response, NSError *error))responseBlock {
    NSURL *endpoint = [self.baseURL URLByAppendingPathComponent:@"healthz"];
    
    NSURLSessionDataTask *task = [self.URLSession dataTaskWithURL:endpoint completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( error != nil ) {
            NSLog(@"error");
            responseBlock(nil, nil);
            // TODO: add error
        }
        
        if ( data == nil ) {
            NSLog(@"no data");
            responseBlock(nil, nil);
            // TODO: add error
        }
        
        NSError *JSONError;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        
        if ( JSONError != nil ) {
            NSLog(@"Unable to parse JSON");
            responseBlock(nil, nil);
            // TODO: add error
        }
        
        TIOMRStatus *status = [[TIOMRStatus alloc] initWithJSON:JSON];
        
        if ( status.status != TIOMRStatusValueServing ) {
            NSLog(@"Health returned value other than serving");
            responseBlock(nil, nil);
            // TODO: add error
        }
        
        responseBlock(status, nil);
    }];
    
    [task resume];
    return task;
}

@end
