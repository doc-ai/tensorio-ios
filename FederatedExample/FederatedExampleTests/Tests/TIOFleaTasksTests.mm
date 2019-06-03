//
//  TIOFleaTasksTests.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/23/19.
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

@interface TIOFleaTasksTests : XCTestCase

@end

@implementation TIOFleaTasksTests

- (void)setUp { }

- (void)tearDown { }

// MARK: -

- (void)testGETTasksSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for tasks response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"startTaskId": @"taskid-1",
        @"maxItems": @(2),
        @"taskIds": @[
            @"taskid-1",
            @"taskid-2"
        ]
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:nil hyperparametersId:nil checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(tasks);
        
        XCTAssert(tasks.taskIds.count == 2);
        XCTAssertEqualObjects(tasks.taskIds, (@[
            @"taskid-1",
            @"taskid-2"
        ]));
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

// MARK: -

- (void)testGETTasksURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session downloadSession:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:nil hyperparametersId:nil checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) { }];
    
    NSURL *expectedURL = [NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models/tasks"];
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

- (void)testGETTasksURLWithModelId {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session downloadSession:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:@"model-foo" hyperparametersId:nil checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) { }];
    
    NSURL *expectedURL = [NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models/tasks?modelId=model-foo"];
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

- (void)testGETTasksURLWithHyperparametersId {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session downloadSession:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:nil hyperparametersId:@"hyperparameters-foo" checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) { }];
    
    NSURL *expectedURL = [NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models/tasks?hyperparametersId=hyperparameters-foo"];
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

- (void)testGETTasksURLWithCheckpointId {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session downloadSession:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:nil hyperparametersId:nil checkpointId:@"checkpoint-foo" callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) { }];
    
    NSURL *expectedURL = [NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models/tasks?checkpointId=checkpoint-foo"];
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

- (void)testGETTasksURLWithAllIds {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session downloadSession:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:@"model-foo" hyperparametersId:@"hyperparameters-foo" checkpointId:@"checkpoint-foo" callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) { }];
    
    NSURL *expectedURL = [NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models/tasks?modelId=model-foo&hyperparametersId=hyperparameters-foo&checkpointId=checkpoint-foo"];
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

// MARK: -

- (void)testGETTasksWithoutStartTaskIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for tasks response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"maxItems": @(2),
        @"taskIds": @[
            @"taskid-1",
            @"taskid-2"
        ]
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:nil hyperparametersId:nil checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(tasks);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTasksWithoutMaxItemsFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for tasks response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"startTaskId": @"taskid-1",
        @"taskIds": @[
            @"taskid-1",
            @"taskid-2"
        ]
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:nil hyperparametersId:nil checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(tasks);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTasksWithoutTaskIdsFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for tasks response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"startTaskId": @"taskid-1",
        @"maxItems": @(2)
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:nil hyperparametersId:nil checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(tasks);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

// MARK: -

- (void)testGETTasksWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for tasks response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTasksWithModelId:nil hyperparametersId:nil checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(tasks);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

@end
