//
//  TIOFleaJobUploadTests.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/24/19.
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

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>
#import "MockURLSession.h"

@interface TIOFleaJobUploadTests : XCTestCase

@end

@implementation TIOFleaJobUploadTests

- (void)setUp { }

- (void)tearDown { }

- (void)testUploadJobResultWithFileSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for upload response"];
    
    NSURL *sourceURL = [NSBundle.mainBundle URLForResource:@"test-job-results" withExtension:@"zip"];
    NSURL *destinationURL = [NSURL URLWithString:@"http://foo.com/upload.zip"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithUpload:sourceURL];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDownloadTask *task = (MockSessionDownloadTask*)[client uploadJobResultsAtURL:sourceURL toURL:destinationURL withJobId:@"job-id" callback:^(TIOFleaJobUpload * _Nullable upload, double progress, NSError * _Nullable error) {
        [expectation fulfill];
    
        XCTAssertNil(error);
        XCTAssertNotNil(upload);
        
        XCTAssert(progress == 1);
        XCTAssert(upload.status == TIOFleaJobUploadStatusSuccess);
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testUploadJobResultWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for upload response"];
    
    NSURL *sourceURL = [NSBundle.mainBundle URLForResource:@"test-job-results" withExtension:@"zip"];
    NSURL *destinationURL = [NSURL URLWithString:@"http://foo.com/upload.zip"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDownloadTask *task = (MockSessionDownloadTask*)[client uploadJobResultsAtURL:sourceURL toURL:destinationURL withJobId:@"job-id" callback:^(TIOFleaJobUpload * _Nullable upload, double progress, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(upload);
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testUploadJobResultWithoutValidSourceFileFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for upload response"];

    NSURL *sourceURL = [NSBundle.mainBundle URLForResource:@"doesnotexist" withExtension:@"zip"];
    NSURL *destinationURL = [NSURL URLWithString:@"http://foo.com/upload.zip"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithUpload:sourceURL];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDownloadTask *task = (MockSessionDownloadTask*)[client uploadJobResultsAtURL:sourceURL toURL:destinationURL withJobId:@"job-id" callback:^(TIOFleaJobUpload * _Nullable upload, double progress, NSError * _Nullable error) {
        [expectation fulfill];
    
        XCTAssertNotNil(error);
        XCTAssertNil(upload);
    }];
    
    XCTAssertNil(task);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

@end
