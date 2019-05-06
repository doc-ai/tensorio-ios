//
//  TIOMRModelTests.m
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

@interface TIOMRModelTests : XCTestCase

@end

@implementation TIOMRModelTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: -

- (void)testGETModelWithModelSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for model response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"model": @{
            @"modelId": @"happy-face",
            @"description": @"Accepts images of an individual's face and infers their emotion from it.",
            @"canonicalHyperparameters": @"batch-8-et-v2-140-224-ing-rate-1e-5"
        }
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable response, NSError * _Nonnull error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertEqualObjects(response.modelId, @"happy-face");
        XCTAssertEqualObjects(response.details, @"Accepts images of an individual's face and infers their emotion from it.");
        XCTAssertEqualObjects(response.canonicalHyperparameters, @"batch-8-et-v2-140-224-ing-rate-1e-5");
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETModelURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable response, NSError * _Nonnull error) {}];
    
    NSURL *expectedURL = [[[NSURL
        URLWithString:@"https://storage.googleapis.com/doc-ai-models"]
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:@"happy-face"];
    
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

// MARK: -

- (void)testGETModelWithEmptyModelFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for model response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
       @"model": @{ }
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable response, NSError * _Nonnull error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETModelWithoutModelFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for model response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
       @"foo": @{ }
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable response, NSError * _Nonnull error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

// MARK: -

- (void)testGETModelsWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for health status response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable response, NSError * _Nonnull error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHealthStatusWithoutDataFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for health status response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONData:[NSData data]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable response, NSError * _Nonnull error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

@end
