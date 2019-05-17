//
//  TIOMRHyperparameterTests.m
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

@interface TIOMRHyperparameterTests : XCTestCase

@end

@implementation TIOMRHyperparameterTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: -

- (void)testGETHyperparameterWithHyperparameterPropertiesSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameter response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"upgradeTo": @"batch-9-2-0-1-6", // or null
        @"hyperparameters": @{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        },
        @"canonicalCheckpoint": @"model.ckpt-321312"
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(hyperparameter);
        XCTAssertEqualObjects(hyperparameter.modelId, @"happy-face");
        XCTAssertEqualObjects(hyperparameter.hyperparametersId, @"batch-9-2-0-1-5");
        XCTAssertEqualObjects(hyperparameter.upgradeTo, @"batch-9-2-0-1-6");
        XCTAssertEqualObjects(hyperparameter.hyperparameters,(@{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        }));
        XCTAssertEqualObjects(hyperparameter.canonicalCheckpoint, @"model.ckpt-321312");
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparameterURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {}];
    
    NSURL *expectedURL = [[[[[NSURL
        URLWithString:@"https://storage.googleapis.com/doc-ai-models"]
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:@"happy-face"]
        URLByAppendingPathComponent:@"hyperparameters"]
        URLByAppendingPathComponent:@"batch-9-2-0-1-5"];
    
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

// MARK: -

- (void)testGETHyperparameterWithHyperparameterPropertiesNullUpgradeToSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameter response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"upgradeTo": [NSNull null],
        @"hyperparameters": @{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        },
        @"canonicalCheckpoint": @"model.ckpt-321312"
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(hyperparameter);
        XCTAssertEqualObjects(hyperparameter.modelId, @"happy-face");
        XCTAssertEqualObjects(hyperparameter.hyperparametersId, @"batch-9-2-0-1-5");
        XCTAssertNil(hyperparameter.upgradeTo);
        XCTAssertEqualObjects(hyperparameter.hyperparameters,(@{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        }));
        XCTAssertEqualObjects(hyperparameter.canonicalCheckpoint, @"model.ckpt-321312");
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparameterWithoutModelIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameter response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"upgradeTo": [NSNull null],
        @"hyperparameters": @{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        },
        @"canonicalCheckpoint": @"model.ckpt-321312"
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(hyperparameter);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparameterWithouthyperparametersIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameter response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"upgradeTo": [NSNull null],
        @"hyperparameters": @{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        },
        @"canonicalCheckpoint": @"model.ckpt-321312"
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(hyperparameter);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparameterWithoutUpgradeToSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameter response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"hyperparameters": @{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        },
        @"canonicalCheckpoint": @"model.ckpt-321312"
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(hyperparameter);
        XCTAssertEqualObjects(hyperparameter.modelId, @"happy-face");
        XCTAssertEqualObjects(hyperparameter.hyperparametersId, @"batch-9-2-0-1-5");
        XCTAssertNil(hyperparameter.upgradeTo);
        XCTAssertEqualObjects(hyperparameter.hyperparameters,(@{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        }));
        XCTAssertEqualObjects(hyperparameter.canonicalCheckpoint, @"model.ckpt-321312");
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparameterWithoutHyperparametersFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameter response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"upgradeTo": [NSNull null],
        @"canonicalCheckpoint": @"model.ckpt-321312"
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(hyperparameter);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparameterWithoutCanonicalCheckpointSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameter response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"upgradeTo": @"batch-9-2-0-1-6",
        @"hyperparameters": @{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        },
    }];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(hyperparameter);
        XCTAssertEqualObjects(hyperparameter.modelId, @"happy-face");
        XCTAssertEqualObjects(hyperparameter.hyperparametersId, @"batch-9-2-0-1-5");
        XCTAssertEqualObjects(hyperparameter.upgradeTo, @"batch-9-2-0-1-6");
        XCTAssertEqualObjects(hyperparameter.hyperparameters,(@{
            @"architecture": @"inception-resnet-v3",
            @"batch": @"9",
            @"training-set-entropy-cutoff": @"2.0",
            @"evaluation-set-entropy-cutoff": @"2.0"
        }));
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

// MARK: -

- (void)testGETHyperparameterWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameter response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(hyperparameter);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETHyperparameterWithoutDataFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for hyperparameter response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONData:[NSData data]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETHyperparameterForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(hyperparameter);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

// MARK: -

- (void)testJSONNilUpgradeToResolvesToNilProperty {
    NSDictionary *JSON = @{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"upgradeTo": NSNull.null,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": @"model.ckpt-321312"
    };
    
    TIOMRHyperparameter *hyperparameter = [[TIOMRHyperparameter alloc] initWithJSON:JSON];
    XCTAssertNil(hyperparameter.upgradeTo);
}

@end
