//
//  TIOFleaTaskDownloadTests.m
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

@interface TIOFleaTaskDownloadTests : XCTestCase

@end

@implementation TIOFleaTaskDownloadTests

- (void)setUp { }

- (void)tearDown { }

// MARK: -

- (void)testDownloadZippedTaskBundleWithFileSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for download response"];
    
    NSURL *testURL = [NSBundle.mainBundle URLForResource:@"test.tiotask" withExtension:@"zip"];
    MockURLSession *session = [[MockURLSession alloc] initWithDownload:testURL];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDownloadTask *task = (MockSessionDownloadTask*)[client downloadTaskBundleAtURL:testURL withTaskId:@"task-id" callback:^(TIOFleaTaskDownload * _Nullable download, double progress, NSError * _Nullable error) {
        [expectation fulfill];
    
        XCTAssertNil(error);
        XCTAssertNotNil(download);
        
        XCTAssert(progress == 1);
        XCTAssertEqualObjects(download.taskId, @"task-id");
        XCTAssert([NSFileManager.defaultManager fileExistsAtPath:download.URL.path]);
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

// MARK: -

- (void)testDownloadZippedTaskBundleWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for download response"];
    
    NSURL *testURL = [NSBundle.mainBundle URLForResource:@"upgradable-checkpoint.tiobundle" withExtension:@"zip"];
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDownloadTask *task = (MockSessionDownloadTask*)[client downloadTaskBundleAtURL:testURL withTaskId:@"task-id" callback:^(TIOFleaTaskDownload * _Nullable download, double progress, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(download);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testDownloadZippedTaskBundleWithoutLocationFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for download response"];
    
    NSURL *testURL = [NSBundle.mainBundle URLForResource:@"upgradable-checkpoint.tiobundle" withExtension:@"zip"];
    MockURLSession *session = [[MockURLSession alloc] init];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDownloadTask *task = (MockSessionDownloadTask*)[client downloadTaskBundleAtURL:testURL withTaskId:@"task-id" callback:^(TIOFleaTaskDownload * _Nullable download, double progress, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(download);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

@end
