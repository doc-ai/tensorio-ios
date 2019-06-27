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

// MARK: Mock Session Responses

@protocol MockSessionResponse <NSObject>
@end

@interface NSDictionary (MockSessionResponse) <MockSessionResponse>
@end

@interface NSData (MockSessionResponse) <MockSessionResponse>
@end

@interface NSURL (MockSessionResponse) <MockSessionResponse>
@end

@interface NSError (MockSessionResponse) <MockSessionResponse>
@end

// MARK: - Mock Session Tasks

@interface MockSessionDataTask: NSURLSessionDataTask

- (instancetype)initWithMockURLRequest:(NSURLRequest*)mockRequest;
@property (readonly) BOOL calledResume;

@end

@interface MockSessionDownloadTask: NSURLSessionDownloadTask

- (instancetype)initWithMockURLRequest:(NSURLRequest*)mockRequest;
@property (readonly) BOOL calledResume;

@end

@interface MockSessionUploadTask: NSURLSessionUploadTask

- (instancetype)initWithMockURLRequest:(NSURLRequest*)mockRequest;
@property (readonly) BOOL calledResume;

@end

// MARK: - Mock Session

@interface MockURLSession: NSURLSession

// A list of responses that will be returned in order
@property (readonly) NSArray<id<MockSessionResponse>> *responses;

// The next response that will be returned
@property (readonly) NSDictionary *JSONResponse;
@property (readonly) NSData *JSONData;
@property (readonly) NSURL *download;
@property (readonly) NSURL *upload;
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
 * Prepare for a `NSURLSessionUploadTask` with a file URL
 */

- (instancetype)initWithUpload:(NSURL*)upload;

/**
 * Prepare for a `NSURLSessionDataTask`. `NSURLSessionDownloadTask` or
 * `NSURLSessionUploadTask` with an error
 */

- (instancetype)initWithError:(NSError*)error;

/**
 * Prepares a session with mulitple response for multiple expected tasks
 */

- (instancetype)initWithResponses:(NSArray<id<MockSessionResponse>>*)responses;

/**
 * Mocks an NSURLSessionDataTask with JSON, JSON data, or an error
 */

- (NSURLSessionDataTask*)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler;

/**
 * Mocks an NSURLSessionDownloadTask with a file URL or an error
 */

- (NSURLSessionDownloadTask*)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler;

/**
 * Mocks an NSURLSessionUploadTask with data or an error
 */

- (NSURLSessionUploadTask*)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler;

/**
 * Mock delegate is always nil
 */

- (nullable id)delegate;

@end

NS_ASSUME_NONNULL_END
