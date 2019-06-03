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
        @"modelId": @"happy-face",
        @"details": @"Accepts images of an individual's face and infers their emotion from it.",
        @"canonicalHyperparameters": @"batch-8-et-v2-140-224-ing-rate-1e-5"
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(model);
        
        XCTAssertEqualObjects(model.modelId, @"happy-face");
        XCTAssertEqualObjects(model.details, @"Accepts images of an individual's face and infers their emotion from it.");
        XCTAssertEqualObjects(model.canonicalHyperparameters, @"batch-8-et-v2-140-224-ing-rate-1e-5");
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETModelWithoutModelIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for model response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"details": @"Accepts images of an individual's face and infers their emotion from it.",
        @"canonicalHyperparameters": @"batch-8-et-v2-140-224-ing-rate-1e-5"
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(model);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETModelWithoutModelDetailsFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for model response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"canonicalHyperparameters": @"batch-8-et-v2-140-224-ing-rate-1e-5"
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(model);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETModelWithoutCanonicalHyperparametersSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for model response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"details": @"Accepts images of an individual's face and infers their emotion from it."
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(model);
        
        XCTAssertEqualObjects(model.modelId, @"happy-face");
        XCTAssertEqualObjects(model.details, @"Accepts images of an individual's face and infers their emotion from it.");
        XCTAssertNil(model.canonicalHyperparameters);
    }];
    
    XCTAssert(task.calledResume);
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETModelWithEmptyCanonicalHyperparametersStringSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for model response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"details": @"Accepts images of an individual's face and infers their emotion from it.",
        @"canonicalHyperparameters": @""
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(model);
        
        XCTAssertEqualObjects(model.modelId, @"happy-face");
        XCTAssertEqualObjects(model.details, @"Accepts images of an individual's face and infers their emotion from it.");
        XCTAssertNil(model.canonicalHyperparameters);
    }];
    
    XCTAssert(task.calledResume);
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETModelURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session downloadSession:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {}];
    
    NSURL *expectedURL = [[[NSURL
        URLWithString:@"https://storage.googleapis.com/doc-ai-models"]
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:@"happy-face"];
    
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

// MARK: -

- (void)testGETModelWithEmptyModelFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for model response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{ }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(model);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETModelWithoutModelFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for model response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
       @"foo": @{ }
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(model);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

// MARK: -

- (void)testGETModelsWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for health status response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(model);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

- (void)testGETHealthStatusWithoutDataFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for health status response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONData:[NSData data]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETModelWithId:@"happy-face" callback:^(TIOMRModel * _Nullable model, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(model);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

@end
