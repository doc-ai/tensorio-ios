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

// MARK: -

@interface TIOMRUpdateTests : XCTestCase

@property NSString *modelId;
@property NSString *hyperparametersId;
@property NSString *checkpointId;

@property NSString *upgradeTo;
@property NSString *canonicalCheckpoint;

@property TIOModelBundle *upgradableBundle;

@end

@implementation TIOMRUpdateTests

- (void)setUp {
    // taken from upgradable.id: tio:///models/happy-face/hyperparameters/batch-9-2-0-1-5/checkpoints/model.ckpt-321312
   
    self.modelId = @"happy-face";
    self.hyperparametersId = @"batch-9-2-0-1-5";
    self.checkpointId = @"model.ckpt-321312";
    
    // taken from upgradable-hyperparameters.id: tio:///models/happy-face/hyperparameters/batch-9-2-0-1-6/checkpoints/model.ckpt-321312
    
    self.upgradeTo = @"batch-9-2-0-1-6";
    
    // taken from upgradable-checkpoint.id: tio:///models/happy-face/hyperparameters/batch-9-2-0-1-5/checkpoints/model.ckpt-329117
    
    self.canonicalCheckpoint = @"model.ckpt-329117";
    
    // Ensure each test works with a unique copy of upgradable.tiobundle
    
    NSFileManager *fm = NSFileManager.defaultManager;
    NSError *fmError;
    
    NSURL *upgradableURL = [NSBundle.mainBundle URLForResource:@"upgradable" withExtension:@"tiobundle"];
    NSURL *uniqueDirectory = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:NSUUID.UUID.UUIDString];
    NSURL *uniqueUpgradableURL = [uniqueDirectory URLByAppendingPathComponent:upgradableURL.lastPathComponent];
    
    if ( ![fm createDirectoryAtURL:uniqueDirectory withIntermediateDirectories:NO attributes:nil error:&fmError] ) {
        NSLog(@"Unable to create directory at %@", uniqueDirectory);
        XCTAssert(NO);
    }
    
    if ( ![fm copyItemAtURL:upgradableURL toURL:uniqueUpgradableURL error:&fmError] || fmError ) {
        NSLog(@"Unable to copy upgradable bundle at %@ to unique location at %@", upgradableURL, uniqueUpgradableURL);
        XCTAssert(NO);
    }
    
    TIOModelBundle *bundle = [[TIOModelBundle alloc] initWithPath:uniqueUpgradableURL.path];
    XCTAssertNotNil(bundle);
    
    self.upgradableBundle = bundle;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: -

- (void)testCheckForUpdateIsFalseWhenUpgradeToIsNilAndCheckpointIsLatest {
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
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater checkForUpdate:^(BOOL updateAvailable, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertFalse(updateAvailable);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
}

- (void)testCheckForUpdateIsTrueWhenUpgradeToIsNilButCheckpointIsNotLatest {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": NSNull.null,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.canonicalCheckpoint
    };
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse
    ]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater checkForUpdate:^(BOOL updateAvailable, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertTrue(updateAvailable);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
}

- (void)testCheckForUpdateIsTrueWhenUpgradeToIsNotNil {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Update"];
    
    NSDictionary *GETHyperParameterResponse = @{
        @"modelId": self.modelId,
        @"hyperparametersId": self.hyperparametersId,
        @"upgradeTo": self.upgradeTo,
        @"hyperparameters": @{},
        @"canonicalCheckpoint": self.canonicalCheckpoint
    };
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse
    ]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater checkForUpdate:^(BOOL updateAvailable, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertTrue(updateAvailable);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
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
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(updatedBundleURL);
        XCTAssertFalse(updated);
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
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
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNil(updatedBundleURL);
        XCTAssertFalse(updated);
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
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
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(updatedBundleURL);
        XCTAssertFalse(updated);
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
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
        @"createdAt": @"2019-04-20T16:20:00.000+0000",
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
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(updatedBundleURL);
        XCTAssertFalse(updated);
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
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
        @"createdAt": @"2019-04-20T16:20:00.000+0000",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    };
    
    NSURL *DownloadResponse = [NSBundle.mainBundle URLForResource:@"upgradable-checkpoint.tiobundle" withExtension:@"zip"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse,
        GETCheckpointResponse,
        DownloadResponse
    ]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(updatedBundleURL);
        XCTAssertTrue(updated);
        
        // Confirm that the bundle has been replaced
        
        TIOModelBundle *newBundle = [[TIOModelBundle alloc] initWithPath:updatedBundleURL.path];
        XCTAssertEqualObjects(newBundle.identifier, @"tio:///models/happy-face/hyperparameters/batch-9-2-0-1-5/checkpoints/model.ckpt-329117");
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
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
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(updatedBundleURL);
        XCTAssertFalse(updated);
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
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
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(updatedBundleURL);
        XCTAssertFalse(updated);
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
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
        @"createdAt": @"2019-04-20T16:20:00.000+0000",
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
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNotNil(error);
        XCTAssertNil(updatedBundleURL);
        XCTAssertFalse(updated);
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
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
        @"createdAt": @"2019-04-20T16:20:00.000+0000",
        @"info": @{
            @"standard-1-accuracy": @"0.934"
        },
        @"link": @"https://storage.googleapis.com/doc-ai-models/happy-face/batch-9-2-0-9-2-0/model.ckpt-322405.zip"
    };
    
    NSURL *DownloadResponse = [NSBundle.mainBundle URLForResource:@"upgradable-hyperparameters.tiobundle" withExtension:@"zip"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETHyperParameterResponse1,
        GETHyperParameterResponse2,
        GETCheckpointResponse,
        DownloadResponse
    ]];
    
    TIOModelRepositoryClient *repository = [[TIOModelRepositoryClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session downloadSession:session];
    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:self.upgradableBundle repository:repository];
    
    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(updatedBundleURL);
        XCTAssertTrue(updated);
        
        // Confirm that the bundle has been replaced
        
        TIOModelBundle *newBundle = [[TIOModelBundle alloc] initWithPath:updatedBundleURL.path];
        XCTAssertEqualObjects(newBundle.identifier, @"tio:///models/happy-face/hyperparameters/batch-9-2-0-1-6/checkpoints/model.ckpt-321312");
    }];
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    XCTAssert(session.responses.count == 0); // queue exhausted
}

@end
