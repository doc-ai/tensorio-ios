//
//  TIOMRCheckpointsTests.m
//  DeployExampleTests
//
//  Created by Phil Dow on 5/6/19.
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
//  TODO: Test URL

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>
#import "MockURLSession.h"

@interface TIOMRCheckpointsTests : XCTestCase

@end

@implementation TIOMRCheckpointsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGETCheckpointsWithCheckpointPropertiesSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoints response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparameterId": @"batch-9-2-0-1-5",
        @"checkpointIds": @[
            @"model.ckpt-321312",
            @"model.ckpt-320210",
            @"model.ckpt-319117"
        ]
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointsForModelWithId:@"happy-face" hyperparameterId:@"batch-9-2-0-1-5" callback:^(TIOMRCheckpoints * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertEqualObjects(response.modelId, @"happy-face");
        XCTAssertEqualObjects(response.hyperparameterId, @"batch-9-2-0-1-5");
        XCTAssertEqualObjects(response.checkpointIds, (@[
            @"model.ckpt-321312",
            @"model.ckpt-320210",
            @"model.ckpt-319117"
        ]));
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointsWithoutCheckpointIdsFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoints response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparameterId": @"batch-9-2-0-1-5"
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointsForModelWithId:@"happy-face" hyperparameterId:@"batch-9-2-0-1-5" callback:^(TIOMRCheckpoints * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointsWithoutModelIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoints response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"hyperparameterId": @"batch-9-2-0-1-5",
        @"checkpointIds": @[
            @"model.ckpt-321312",
            @"model.ckpt-320210",
            @"model.ckpt-319117"
        ]
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointsForModelWithId:@"happy-face" hyperparameterId:@"batch-9-2-0-1-5" callback:^(TIOMRCheckpoints * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointsWithoutHyperparameterIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoints response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"checkpointIds": @[
            @"model.ckpt-321312",
            @"model.ckpt-320210",
            @"model.ckpt-319117"
        ]
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointsForModelWithId:@"happy-face" hyperparameterId:@"batch-9-2-0-1-5" callback:^(TIOMRCheckpoints * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointsWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameters response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointsForModelWithId:@"happy-face" hyperparameterId:@"batch-9-2-0-1-5" callback:^(TIOMRCheckpoints * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointsWithoutDataFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameters response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONData:[NSData data]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointsForModelWithId:@"happy-face" hyperparameterId:@"batch-9-2-0-1-5" callback:^(TIOMRCheckpoints * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

@end
