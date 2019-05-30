//
//  DockerTests.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/25/19.
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

@interface DockerTests : XCTestCase

@property TIOFleaClient *client;

@end

@implementation DockerTests

- (void)setUp {
    NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
    configuration.HTTPAdditionalHeaders = @{
        @"Authorization": @"Bearer ClientToken"
    };

    NSURLSession *URLSession = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"http://localhost:8083/v1/flea"];
    
    self.client = [[TIOFleaClient alloc] initWithBaseURL:URL session:URLSession];
}

- (void)tearDown { }

- (void)testGETHealth {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for health status response"];
    
    [self.client GETHealthStatus:^(TIOFleaStatus * _Nullable status, NSError * _Nonnull error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(status);
        
        XCTAssert(status.status == TIOFleaStatusValueServing);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGetAllTasks {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for all tasks response"];
    
    [self.client GETTasksWithModelId:nil hyperparametersId:nil checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(tasks);

        NSLog(@"Tasks are: %@", tasks);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETTask {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    NSString *taskId = @"b7"; // From mocks script
    
    [self.client GETTaskWithTaskId:taskId callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(task);

        NSLog(@"Task is: %@", task);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETStartTask {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for start task response"];
    NSString *taskId = @"b7"; // From mocks script
    
    [self.client GETStartTaskWithTaskId:taskId callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(job);

        NSLog(@"Job is: %@", job);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
}

@end
