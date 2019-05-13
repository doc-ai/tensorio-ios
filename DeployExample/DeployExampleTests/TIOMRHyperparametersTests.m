//
//  TIOMRHyperparametersTests.m
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

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>
#import "MockURLSession.h"

@interface TIOMRHyperparametersTests : XCTestCase

@end

@implementation TIOMRHyperparametersTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: -

- (void)testGETHyperparametersWithHyperparametersSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameters response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersIds": @[
            @"batch-9-2-0-1-5",
            @"batch-9-2-0-1-0",
            @"batch-9-2-0-0-5"
        ]
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparametersForModelWithId:@"happy-face" callback:^(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(hyperparameters);
        XCTAssertEqualObjects(hyperparameters.modelId, @"happy-face");
        XCTAssertEqualObjects(hyperparameters.hyperparametersIds, (@[
            @"batch-9-2-0-1-5",
            @"batch-9-2-0-1-0",
            @"batch-9-2-0-0-5"
        ]));
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparametersWithEmptyhyperparametersIdsSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameters response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersIds": @[]
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparametersForModelWithId:@"happy-face" callback:^(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(hyperparameters);
        XCTAssertEqualObjects(hyperparameters.modelId, @"happy-face");
        XCTAssertEqualObjects(hyperparameters.hyperparametersIds, (@[]));
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparametersURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparametersForModelWithId:@"happy-face" callback:^(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error) {}];
    
    NSURL *expectedURL = [[[[NSURL
        URLWithString:@"https://storage.googleapis.com/doc-ai-models"]
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:@"happy-face"]
        URLByAppendingPathComponent:@"hyperparameters"];
    
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

// MARK: -

- (void)testGETHyperparametersWithoutHyperparametersFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameters response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face"
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparametersForModelWithId:@"happy-face" callback:^(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(hyperparameters);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparametersWithoutModelIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameters response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"hyperparametersIds": @[
            @"batch-9-2-0-1-5",
            @"batch-9-2-0-1-0",
            @"batch-9-2-0-0-5"
        ]
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparametersForModelWithId:@"happy-face" callback:^(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(hyperparameters);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

// MARK: -

- (void)testGETHyperparametersWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameters response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparametersForModelWithId:@"happy-face" callback:^(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(hyperparameters);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparametersWithoutDataFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameters response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONData:[NSData data]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparametersForModelWithId:@"happy-face" callback:^(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(hyperparameters);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

@end
