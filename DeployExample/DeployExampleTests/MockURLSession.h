//
//  MockURLSession.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MockSessionDataTask: NSURLSessionDataTask

@property (readonly) BOOL calledResume;

@end

@interface MockSessionDownloadTask: NSURLSessionDownloadTask

@property (readonly) BOOL calledResume;

@end

// MARK: -

@interface MockURLSession: NSURLSession

@property (readonly) NSDictionary *JSONResponse;
@property (readonly) NSData *JSONData;
@property (readonly) NSURL *download;
@property (readonly) NSError *error;

/**
 * Prepare for a `NSURLSessionDataTask` with JSON
 */

- (instancetype)initWithJSONResponse:(NSDictionary*)JSON;

/**
 * Prepare for a `NSURLSessionDataTask` with JSON data
 */

- (instancetype)initWithJSONData:(NSData*)JSONData;

/**
 * Prepare for a `NSURLSessionDownloadTask` with a file URL
 */

- (instancetype)initWithDownload:(NSURL*)download;

/**
 * Prepare for a `NSURLSessionDataTask` or `NSURLSessionDownloadTask` with an
 * error
 */

- (instancetype)initWithError:(NSError*)error;

/**
 * Mocks a NSURLSessionDataTask with JSON, JSON data, or an error
 */

- (NSURLSessionDataTask*)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler;

/**
 * Mocks a NSURLSessionDownloadTask with a file URL or an error
 */

- (NSURLSessionDownloadTask*)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
