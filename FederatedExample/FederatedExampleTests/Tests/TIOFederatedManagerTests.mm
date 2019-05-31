//
//  TIOFederatedManagerTests.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/22/19.
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
//  TODO: More comprehensive failure testing
//  TODO: Verify changes to the local filesystem as tasks are executed

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>
#import "TIOMockBatchDataSource.h"
#import "TIOMockModelBundle.h"
#import "TIOMockTrainableModel.h"
#import "TIOMockFederatedManagerDataSourceProvider.h"
#import "TIOMockFederatedManagerDelegate.h"
#import "MockURLSession.h"

@interface TIOFederatedManagerTests : XCTestCase

@end

@implementation TIOFederatedManagerTests

- (void)setUp { }

- (void)tearDown { }

// MARK: -

- (void)testRegisterAndUnregisterModelIds {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    TIOFederatedManager *manager = [[TIOFederatedManager alloc] initWithClient:client];
    
    [manager registerForTasksForModelWithId:@"tio:///modelid"];
    XCTAssert([manager.registeredModelIds containsObject:@"tio:///modelid"]);
    
    [manager unregisterForTasksForModelWithId:@"tio:///modelid"];
    XCTAssert(![manager.registeredModelIds containsObject:@"tio:///modelid"]);
}

// MARK: - Integration Tests

- (void)testSuccessfulIntegration {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for all responses"];
    
    // Mock data source provider
    // Mock bundle
    // Mock delegate
    
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    [model setMockExportsURL:[NSBundle.mainBundle URLForResource:@"mock-training-export" withExtension:nil]];
    TIOMockModelBundle *modelBundle = [[TIOMockModelBundle alloc] initWithMockedModel:model path:[NSBundle.mainBundle URLForResource:@"test" withExtension:@"tiobundle"].path];
    
    TIOMockFederatedManagerDataSourceProvider *dataSourceProvider = [[TIOMockFederatedManagerDataSourceProvider alloc] init];
    [dataSourceProvider setModelBundle:modelBundle forModelId:@"tio:///models/1/hyperparameters/1/checkpoint/1"];
    [dataSourceProvider setDataSource:dataSource forTaskId:@"tio:///tasks/1"];
    
    TIOMockFederatedManagerDelegate *delegate = [[TIOMockFederatedManagerDelegate alloc] initWithExpectation:expectation];
    
    // Mock session
    // Mock client
    
    NSDictionary *GETTasksResponse = @{
        @"startTaskId": @"tio:///tasks/1",
        @"maxItems": @(2),
        @"taskIds": @[
            @"tio:///tasks/1"
        ]
    };
    
    NSDictionary *GETTaskResponse = @{
        @"modelId": @"tio:///models/1/hyperparameters/1/checkpoint/1",
        @"hyperparametersId": @"1",
        @"checkpointId": @"1",
        @"taskId": @"tio:///tasks/1",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"active": @(YES),
        @"link": @"http://goo.gl/Tx3.zip",
        @"checkpointLink": @"https://localhost/v1/models/1/hyperparameters/1/checkpoint/1"
    };
    
    NSURL *DownloadTaskBundleURL = [NSBundle.mainBundle URLForResource:@"test.tiotask" withExtension:@"zip"];
    
    NSDictionary *GETStartTaskResponse = @{
        @"jobId": @"job-id",
        @"status": @"APPROVED",
        @"uploadTo": @"https://localhost/Tx3.zip"
    };
    
    NSURL *UploadJobResultsURL = [NSBundle.mainBundle URLForResource:@"test-job-results" withExtension:@"zip"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithResponses:@[
        GETTasksResponse,
        GETTaskResponse,
        DownloadTaskBundleURL,
        GETStartTaskResponse,
        UploadJobResultsURL
    ]];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://localhost/v1/flea"] session:session];
    
    // Create manager with mocked data source and delegate
    // Register tasks for a model
    // Check for tasks
    
    TIOFederatedManager *manager = [[TIOFederatedManager alloc] initWithClient:client dataSourceProvider:dataSourceProvider delegate:delegate];
    
    [manager registerForTasksForModelWithId:@"tio:///models/1/hyperparameters/1/checkpoint/1"];
    [manager checkForTasks];
    
    // Wait for the federated activity to complete
    
    [self waitForExpectations:@[expectation] timeout:10.0];
    
    // Ensure session queue is empty
    
    XCTAssert(session.responses.count == 0);
    
    // Ensure expected mock data source provider methods are called
    
    XCTAssert([dataSourceProvider dataSourceForTaskWithIdCountForTaskId:@"tio:///tasks/1"] == 1);
    XCTAssert([dataSourceProvider modelBundleForModelWithIdCountForModelId:@"tio:///models/1/hyperparameters/1/checkpoint/1"] == 1);
    
    // Ensure expected mock delegate methods are called
    
    XCTAssert([delegate willBeginProcessingTaskWithIdCountForTaskId:@"tio:///tasks/1"] == 1);
    XCTAssert([delegate didCompleteTaskWithIdCountForTaskId:@"tio:///tasks/1"] == 1);
    
    XCTAssert([delegate didBeginActionCountForAction:TIOFederatedManagerGetTasks] == 1);
    XCTAssert([delegate didBeginActionCountForAction:TIOFederatedManagerGetTask] == 1);
    XCTAssert([delegate didBeginActionCountForAction:TIOFederatedManagerDownloadTaskBundle] == 1);
    XCTAssert([delegate didBeginActionCountForAction:TIOFederatedManagerUnpackageTaskBundle] == 1);
    XCTAssert([delegate didBeginActionCountForAction:TIOFederatedManagerStartTask] == 1);
    XCTAssert([delegate didBeginActionCountForAction:TIOFederatedManagerLoadTask] == 1);
    XCTAssert([delegate didBeginActionCountForAction:TIOFederatedManagerLoadModel] == 1);
    XCTAssert([delegate didBeginActionCountForAction:TIOFederatedManagerTrainModel] == 1);
    XCTAssert([delegate didBeginActionCountForAction:TIOFederatedManagerUploadTaskResults] == 1);
    
    XCTAssert([delegate didFailWithErrorCountForAction:TIOFederatedManagerGetTasks] == 0);
    XCTAssert([delegate didFailWithErrorCountForAction:TIOFederatedManagerGetTask] == 0);
    XCTAssert([delegate didFailWithErrorCountForAction:TIOFederatedManagerDownloadTaskBundle] == 0);
    XCTAssert([delegate didFailWithErrorCountForAction:TIOFederatedManagerUnpackageTaskBundle] == 0);
    XCTAssert([delegate didFailWithErrorCountForAction:TIOFederatedManagerStartTask] == 0);
    XCTAssert([delegate didFailWithErrorCountForAction:TIOFederatedManagerLoadTask] == 0);
    XCTAssert([delegate didFailWithErrorCountForAction:TIOFederatedManagerLoadModel] == 0);
    XCTAssert([delegate didFailWithErrorCountForAction:TIOFederatedManagerTrainModel] == 0);
    XCTAssert([delegate didFailWithErrorCountForAction:TIOFederatedManagerUploadTaskResults] == 0);
}

@end
