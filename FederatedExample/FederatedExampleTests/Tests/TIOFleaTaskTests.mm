//
//  TIOFleaTaskTests.m
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

@interface TIOFleaTaskTests : XCTestCase

@end

@implementation TIOFleaTaskTests

+ (NSDateFormatter*)JSONDateFormatter {
    static NSDateFormatter *RFC3339DateFormatter;
    
    if (RFC3339DateFormatter == nil) {
        RFC3339DateFormatter = [[NSDateFormatter alloc] init];
        RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    
    return RFC3339DateFormatter;
}

// MARK: -

- (void)setUp { }

- (void)tearDown { }

// MARK: -

- (void)testGETTask  {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    NSDate *date = [TIOFleaTaskTests.JSONDateFormatter dateFromString:@"2019-04-20T16:20:00.000+0000"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"model-id",
        @"hyperparametersId": @"hyperparameters-id",
        @"checkpointId": @"checkpoint-id",
        @"taskId": @"task-id",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"active": @(YES),
        @"link": @"http://goo.gl/Tx3.zip",
        @"checkpointLink": @"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(task);
        
        XCTAssertEqualObjects(task.modelId, @"model-id");
        XCTAssertEqualObjects(task.hyperparametersId, @"hyperparameters-id");
        XCTAssertEqualObjects(task.checkpointId, @"checkpoint-id");
        XCTAssertEqualObjects(task.taskId, @"task-id");
        XCTAssertEqualObjects(task.deadline, date);
        XCTAssertTrue(task.active);
        XCTAssertEqualObjects(task.link, [NSURL URLWithString:@"http://goo.gl/Tx3.zip"]);
        XCTAssertEqualObjects(task.checkpointLink, [NSURL URLWithString:@"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"]);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTaskURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://foo.com"] session:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) { }];
    
    NSURL *expectedURL = [NSURL URLWithString:@"https://foo.com/tasks/task-id"];
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

// MARK: -

- (void)testGETTaskWithoutModelIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"hyperparametersId": @"hyperparameters-id",
        @"checkpointId": @"checkpoint-id",
        @"taskId": @"task-id",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"active": @(YES),
        @"link": @"http://goo.gl/Tx3.zip",
        @"checkpointLink": @"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTaskWithoutHyperparametersIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"model-id",
        @"checkpointId": @"checkpoint-id",
        @"taskId": @"task-id",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"active": @(YES),
        @"link": @"http://goo.gl/Tx3.zip",
        @"checkpointLink": @"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTaskWithoutCheckpointIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"model-id",
        @"hyperparametersId": @"hyperparameters-id",
        @"taskId": @"task-id",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"active": @(YES),
        @"link": @"http://goo.gl/Tx3.zip",
        @"checkpointLink": @"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTaskWithoutTaskIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"model-id",
        @"hyperparametersId": @"hyperparameters-id",
        @"checkpointId": @"checkpoint-id",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"active": @(YES),
        @"link": @"http://goo.gl/Tx3.zip",
        @"checkpointLink": @"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTaskWithoutDeadlineIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"model-id",
        @"hyperparametersId": @"hyperparameters-id",
        @"checkpointId": @"checkpoint-id",
        @"taskId": @"task-id",
        @"active": @(YES),
        @"link": @"http://goo.gl/Tx3.zip",
        @"checkpointLink": @"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTaskWithoutActiveFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"model-id",
        @"hyperparametersId": @"hyperparameters-id",
        @"checkpointId": @"checkpoint-id",
        @"taskId": @"task-id",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"link": @"http://goo.gl/Tx3.zip",
        @"checkpointLink": @"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTaskWithoutLinkFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"model-id",
        @"hyperparametersId": @"hyperparameters-id",
        @"checkpointId": @"checkpoint-id",
        @"taskId": @"task-id",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"active": @(YES),
        @"checkpointLink": @"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETTaskWithoutCheckpointLinkFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"model-id",
        @"hyperparametersId": @"hyperparameters-id",
        @"checkpointId": @"checkpoint-id",
        @"taskId": @"task-id",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"active": @(YES),
        @"link": @"http://goo.gl/Tx3.zip",
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

// MARK: -

- (void)testGETTaskWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

@end
