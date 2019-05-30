//
//  TIOMRCheckpointTests.m
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

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>
#import "MockURLSession.h"

@interface TIOMRCheckpointTests : XCTestCase

@end

@implementation TIOMRCheckpointTests

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

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: -

- (void)testGETCheckpointWithCheckpointPropertieSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoint response"];
    
    NSDate *date = [TIOMRCheckpointTests.JSONDateFormatter dateFromString:@"2019-04-20T16:20:00.000+0000"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"checkpointId": @"model.ckpt-321312",
        @"createdAt": @"2019-04-20T16:20:00.000+0000",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(checkpoint);
        XCTAssertEqualObjects(checkpoint.modelId, @"happy-face");
        XCTAssertEqualObjects(checkpoint.hyperparametersId, @"batch-9-2-0-1-5");
        XCTAssertEqualObjects(checkpoint.checkpointId, @"model.ckpt-321312");
        XCTAssertEqualObjects(checkpoint.createdAt, date);
        XCTAssertEqualObjects(checkpoint.link, [NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"]);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://storage.googleapis.com/doc-ai-models"] session:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {}];
    
    NSURL *expectedURL = [[[[[[[NSURL
        URLWithString:@"https://storage.googleapis.com/doc-ai-models"]
        URLByAppendingPathComponent:@"models"]
        URLByAppendingPathComponent:@"happy-face"]
        URLByAppendingPathComponent:@"hyperparameters"]
        URLByAppendingPathComponent:@"batch-9-2-0-1-5"]
        URLByAppendingPathComponent:@"checkpoints"]
        URLByAppendingPathComponent:@"model.ckpt-321312"];
    
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

// MARK: -

- (void)testGETCheckpointWithoutModelIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoint response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"checkpointId": @"model.ckpt-321312",
        @"createdAt": @"1549868901",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(checkpoint);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointWithouthyperparametersIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoint response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"checkpointId": @"model.ckpt-321312",
        @"createdAt": @"1549868901",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(checkpoint);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointWithoutCheckpointIdFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoint response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"createdAt": @"1549868901",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(checkpoint);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointWithoutCreatedAtFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoint response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"checkpointId": @"model.ckpt-321312",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(checkpoint);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointWithoutInfoFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoint response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"checkpointId": @"model.ckpt-321312",
        @"createdAt": @"1549868901",
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(checkpoint);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointWithoutLinkFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoint response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"happy-face",
        @"hyperparametersId": @"batch-9-2-0-1-5",
        @"checkpointId": @"model.ckpt-321312",
        @"createdAt": @"1549868901",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        }
    }];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(checkpoint);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

// MARK: -

- (void)testGETCheckpointWithErrorFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoint response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithError:[[NSError alloc] init]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(checkpoint);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETCheckpointWithoutDataFails {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for checkpoint response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONData:[NSData data]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[repository GETCheckpointForModelWithId:@"happy-face" hyperparametersId:@"batch-9-2-0-1-5" checkpointId:@"model.ckpt-321312" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertNil(checkpoint);
        [expectation fulfill];
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

@end
