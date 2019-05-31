//
//  TIOFleaClientTests.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/29/19.
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

static NSString * const TIOUserDefaultsClientIdKey = @"TIOClientId";

@interface TIOFleaClientTests : XCTestCase

@end

@implementation TIOFleaClientTests

- (void)setUp {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:TIOUserDefaultsClientIdKey];
}

- (void)tearDown { }

- (void)testClientGeneratedClientIdIfUnavailable {
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:nil];
    XCTAssertNotNil(client.clientId);
}

- (void)testClientUsesClientIdIfAvailable {
    [NSUserDefaults.standardUserDefaults setObject:@"FOO" forKey:TIOUserDefaultsClientIdKey];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:nil];
    XCTAssertEqualObjects(client.clientId, @"FOO");
}

// MARK: -

- (void)testReportErrorWithMessageSucceeds {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for upload response"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"message": @"Thank you for the error report."
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@""] session:session];
    
    MockSessionDownloadTask *task = (MockSessionDownloadTask*)[client POSTErrorMessage:@"message" taskId:@"taskid" jobId:@"jobid" callback:^(BOOL success, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertTrue(success);
    }];
    
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssert(session.responses.count == 0); // queue exhausted
    XCTAssert(task.calledResume);
}

@end
