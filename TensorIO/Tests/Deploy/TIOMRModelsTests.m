//
//  TIOMRModelsTests.m
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

@interface TIOMRModelsTests : XCTestCase

@end

@implementation TIOMRModelsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: -

- (void)testGETModelsWithModelsSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for models response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelIds": @[
            @"happy-face",
            @"phenomenal-face"
        ]
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModels:^(TIOMRModels * _Nullable models, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(models);
        
        XCTAssert(models.modelIds.count == 2);
        XCTAssertEqualObjects(models.modelIds[0], @"happy-face");
        XCTAssertEqualObjects(models.modelIds[1], @"phenomenal-face");
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETModelsWithEmptyModelsSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for models response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelIds": @[]
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModels:^(TIOMRModels * _Nullable models, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(models);
        
        XCTAssert(models.modelIds.count == 0);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETModelsURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session downloadSession:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModels:^(TIOMRModels * _Nullable models, NSError * _Nonnull error) {}];
    
    NSURL *expectedURL = [[NSURL
        URLWithString:@"https://storage.googleapis.com/doc-ai-models"]
        URLByAppendingPathComponent:@"models"];
    
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

// MARK: -

- (void)testGETModelsWithoutModelsFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for models response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"foo": @[]
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModels:^(TIOMRModels * _Nullable models, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(models);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

// MARK: -

- (void)testGETModelsWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for models response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModels:^(TIOMRModels * _Nullable models, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(models);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETHealthStatusWithoutDataFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for models response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONData:[NSData data]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModels:^(TIOMRModels * _Nullable models, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(models);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

@end
