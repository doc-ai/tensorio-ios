//
//  TIOMRUpdateTests.m
//  DeployExampleTests
//
//  Created by Phil Dow on 5/10/19.
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

@interface TIOMRUpdateTests : XCTestCase

@property NSString *modelId;
@property NSString *hyperparametersId;
@property NSString *checkpointId;

@property NSString *upgradeTo;
@property NSString *canonicalCheckpoint;

@property NSURL *download;
@property NSURL *destination;
@property TIOModelBundle *upgradableBundle;

@end

@implementation TIOMRUpdateTests

- (void)setUp {
    // taken from bundle.id: tio:///models/happy-face/hyperparameters/batch-9-2-0-1-5/checkpoints/model.ckpt-321312
   
    self.modelId = @"happy-face";
    self.hyperparametersId = @"batch-9-2-0-1-5";
    self.checkpointId = @"model.ckpt-321312";
    
    // response constructed in test methods
    
    self.upgradeTo = @"batch-9-2-0-1-6";
    self.canonicalCheckpoint = @"model.ckpt-329117";
    
    self.download = [NSBundle.mainBundle URLForResource:@"testbundle" withExtension:@"zip"];
    self.upgradableBundle = [[TIOModelBundle alloc] initWithPath:[NSBundle.mainBundle URLForResource:@"upgradable" withExtension:@"tiobundle"].path];
    self.destination = [NSURL URLWithString:@""];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: -

- (void)test1 {
    // GET Hyperparameter -> Error
    // Error, No Update
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSError *GETHyperParameterResponse = [[NSError alloc] init];
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse
    ]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        XCTAssert(session.responses.count == 0); // queue exhausted
        XCTAssertNotNil(error);
        XCTAssertFalse(updated);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)test2 {
    // GET Hyperparameter -> Hyperparameter: upgradeTo:nil canonicalCheckpoint:self.checkpointId
    // No Error, No Update
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": NSNull.null,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.checkpointId
    };
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse
    ]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        XCTAssert(session.responses.count == 0); // queue exhausted
        XCTAssertNil(error);
        XCTAssertFalse(updated);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)test3 {
    // GET Hyperparameter -> Hyperparameter: upgradeTo:nil canonicalCheckpoint:new
    // GET Checkpoint -> Error
    // Error, No Update
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": NSNull.null,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.canonicalCheckpoint
    };
    
    NSError *GETCheckpointResponse = [[NSError alloc] init];
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse,
        GETCheckpointResponse
    ]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        XCTAssert(session.responses.count == 0); // queue exhausted
        XCTAssertNotNil(error);
        XCTAssertFalse(updated);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)test4 {
    // GET Hyperparameter -> Hyperparameter: upgradeTo:nil canonicalCheckpoint:new
    // GET Checkpoint -> Checkpoint
    // Download Model -> Error
    // Error, No Update
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": NSNull.null,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.canonicalCheckpoint
    };
    
    NSDictionary *GETCheckpointResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"checkpointId": self.canonicalCheckpoint,
        @"createdAt": @"1549868901",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    };
    
    NSError *DownloadResponse = [[NSError alloc] init];
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse,
        GETCheckpointResponse,
        DownloadResponse
    ]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        XCTAssert(session.responses.count == 0); // queue exhausted
        XCTAssertNotNil(error);
        XCTAssertFalse(updated);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)test5 {
    // GET Hyperparameter -> Hyperparameter: upgradeTo:nil canonicalCheckpoint:new
    // GET Checkpoint -> Checkpoint
    // Download Model -> Download
    // No Error, Update
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": NSNull.null,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.canonicalCheckpoint
    };
    
    NSDictionary *GETCheckpointResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"checkpointId": self.canonicalCheckpoint,
        @"createdAt": @"1549868901",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    };
    
    NSURL *DownloadResponse = self.download;
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse,
        GETCheckpointResponse,
        DownloadResponse
    ]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        XCTAssert(session.responses.count == 0); // queue exhausted
        XCTAssertNil(error);
        XCTAssertTrue(updated);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)test6 {
    // GET Hyperparameter -> Hyperparameter: upgradeTo:new canonicalCheckpoint:new
    // GET Hyperparameter -> Error
    // Error, No Update
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse1 = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": self.upgradeTo,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.canonicalCheckpoint
    };
    
    NSError *GETHyperParameterResponse2 = [[NSError alloc] init];
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse1,
        GETHyperParameterResponse2
    ]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        XCTAssert(session.responses.count == 0); // queue exhausted
        XCTAssertNotNil(error);
        XCTAssertFalse(updated);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)test7 {
    // GET Hyperparameter -> Hyperparameter: upgradeTo:new
    // GET Hyperparameter -> Hyperparameter: canonicalCheckpoint:new
    // GET Checkpoint -> Error
    // Error, No Update
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse1 = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": self.upgradeTo,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.checkpointId
    };
    
    NSDictionary *GETHyperParameterResponse2 = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.upgradeTo,
        @"upgradeTo": NSNull.null,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.canonicalCheckpoint
    };
    
    NSError *GETCheckpointResponse = [[NSError alloc] init];
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse1,
        GETHyperParameterResponse2,
        GETCheckpointResponse
    ]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        XCTAssert(session.responses.count == 0); // queue exhausted
        XCTAssertNotNil(error);
        XCTAssertFalse(updated);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)test8 {
    // GET Hyperparameter -> Hyperparameter: upgradeTo:new
    // GET Hyperparameter -> Hyperparameter: canonicalCheckpoint:new
    // GET Checkpoint -> Checkpoint
    // GET Download -> Error
    // Error, No Update
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse1 = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": self.upgradeTo,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.checkpointId
    };
    
    NSDictionary *GETHyperParameterResponse2 = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.upgradeTo,
        @"upgradeTo": NSNull.null,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.canonicalCheckpoint
    };
    
    NSDictionary *GETCheckpointResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.upgradeTo,
        @"checkpointId": self.canonicalCheckpoint,
        @"createdAt": @"1549868901",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    };
    
    NSError *DownloadResponse = [[NSError alloc] init];
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse1,
        GETHyperParameterResponse2,
        GETCheckpointResponse,
        DownloadResponse
    ]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        XCTAssert(session.responses.count == 0); // queue exhausted
        XCTAssertNotNil(error);
        XCTAssertFalse(updated);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)test9 {
    // GET Hyperparameter -> Hyperparameter: upgradeTo:new
    // GET Hyperparameter -> Hyperparameter: canonicalCheckpoint:new
    // GET Checkpoint -> Checkpoint
    // GET Download -> Download
    // No Error, Update
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse1 = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": self.upgradeTo,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.checkpointId
    };
    
    NSDictionary *GETHyperParameterResponse2 = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.upgradeTo,
        @"upgradeTo": NSNull.null,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.canonicalCheckpoint
    };
    
    NSDictionary *GETCheckpointResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.upgradeTo,
        @"checkpointId": self.canonicalCheckpoint,
        @"createdAt": @"1549868901",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    };
    
    NSURL *DownloadResponse = self.download;
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse1,
        GETHyperParameterResponse2,
        GETCheckpointResponse,
        DownloadResponse
    ]];
    
    TIOModelRepository *repository = [[TIOModelRepository alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        XCTAssert(session.responses.count == 0); // queue exhausted
        XCTAssertNil(error);
        XCTAssertTrue(updated);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

@end
