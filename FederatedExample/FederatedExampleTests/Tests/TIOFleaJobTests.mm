//
//  TIOFleaJobTests.m
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

@interface TIOFleaJobTests : XCTestCase

@end

@implementation TIOFleaJobTests

- (void)setUp { }

- (void)tearDown { }

- (void)testGETStartTaskSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"jobId": @"job-id",
        @"status": @"APPROVED",
        @"uploadTo": @"http://goo.gl/Tx3.zip"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETStartTaskWithTaskId:@"task-id" callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(job);
        
        XCTAssertEqualObjects(job.jobId, @"job-id");
        XCTAssertEqual(job.status, TIOFleaJobStatusApproved);
        XCTAssertEqualObjects(job.uploadTo, [NSURL URLWithString:@"http://goo.gl/Tx3.zip"]);
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETStartTaskURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://foo.com"] session:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETStartTaskWithTaskId:@"task-id" callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error){}];
    
    NSURL *expectedURL = [NSURL URLWithString:@"https://foo.com/start_task/task-id"];
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

// MARK: -

- (void)testGETStartTaskWithoutStatusFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"status": @"APPROVED",
        @"uploadTo": @"http://goo.gl/Tx3.zip"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETStartTaskWithTaskId:@"task-id" callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(job);
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETStartTaskWithoutJobIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for job response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"jobId": @"job-id",
        @"uploadTo": @"http://goo.gl/Tx3.zip"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETStartTaskWithTaskId:@"task-id" callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(job);
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETStartTaskWithoutUploadToFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for job response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"jobId": @"job-id",
        @"status": @"APPROVED"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETStartTaskWithTaskId:@"task-id" callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(job);
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

// MARK: -

- (void)testGETStartTaskWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for job response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETStartTaskWithTaskId:@"task-id" callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(job);
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

@end
