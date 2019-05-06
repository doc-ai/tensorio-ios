//
//  MockURLSession.m
//  DeployExampleTests
//
//  Created by Phil Dow on 5/3/19.
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
#import "MockURLSession.h"

@implementation MockSessionDataTask {
    NSURLRequest *_mockRequest;
}

- (instancetype)initWithMockURLRequest:(NSURLRequest*)mockRequest {
    if ((self=[super init])) {
        _mockRequest = mockRequest;
    }
    return self;
}

- (void)resume {
    _calledResume = YES;
}

- (NSURLRequest*)originalRequest {
    return _mockRequest;
}

- (NSURLRequest*)currentRequest {
    return _mockRequest;
}

@end

@implementation MockSessionDownloadTask {
    NSURLRequest *_mockRequest;
}

- (instancetype)initWithMockURLRequest:(NSURLRequest*)mockRequest {
    if ((self=[super init])) {
        _mockRequest = mockRequest;
    }
    return self;
}

- (void)resume {
    _calledResume = YES;
}

- (NSURLRequest*)originalRequest {
    return _mockRequest;
}

- (NSURLRequest*)currentRequest {
    return _mockRequest;
}

@end

// MARK: -

@implementation MockURLSession

- (instancetype)initWithJSONResponse:(NSDictionary*)JSON {
    if ((self=[super init])) {
        _JSONResponse = JSON;
        _JSONData = [NSJSONSerialization dataWithJSONObject:JSON options:0 error:nil];
        if (_JSONData == nil) {
            NSLog(@"Unable to serialize JSON");
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithJSONData:(NSData*)JSONData {
    if ((self=[super init])) {
        _JSONData = JSONData;
    }
    return self;
}

- (instancetype)initWithDownload:(NSURL*)download {
    if ((self=[super init])) {
        _download = download;
    }
    return self;
}

- (instancetype)initWithError:(NSError*)error {
    if ((self=[super init])) {
        _error = error;
    }
    return self;
}

- (NSURLSessionDataTask*)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:url];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.error) {
            completionHandler(nil, nil, self.error);
        }
        else if (self.JSONData) {
            completionHandler(self.JSONData, nil, nil);
        }
        else {
            completionHandler(nil, nil, nil);
        }
    });
    
    return [[MockSessionDataTask alloc] initWithMockURLRequest:URLRequest];
}

- (NSURLSessionDownloadTask*)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:url];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.error) {
            completionHandler(nil, nil, self.error);
        }
        else if (self.download) {
            NSURL *copiedURL = [self copyToTemporaryDirectory:url];
            completionHandler(copiedURL, nil, nil);
        }
        else {
            completionHandler(nil, nil, nil);
        }
    });
    
    return [[MockSessionDownloadTask alloc] initWithMockURLRequest:URLRequest];
}

- (nullable NSURL*)copyToTemporaryDirectory:(NSURL*)URL {
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *destURL = [tempDir URLByAppendingPathComponent:URL.lastPathComponent];
    
    NSError *fileError;
    [NSFileManager.defaultManager removeItemAtURL:destURL error:&fileError];
    [NSFileManager.defaultManager copyItemAtURL:URL toURL:destURL error:&fileError];
    
    if ( fileError != nil ) {
        NSLog(@"Copy Error");
        return nil;
    }
    
    return destURL;
}

@end
