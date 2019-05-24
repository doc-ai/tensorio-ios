//
//  TIOFleaTaskTests.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/24/19.
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

//  TODO: More tests, will be added to this PR

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>
#import "MockURLSession.h"

@interface TIOFleaTaskTests : XCTestCase

@end

@implementation TIOFleaTaskTests

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

- (void)setUp { }

- (void)tearDown { }

- (void)testGETTask  {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Wait for task response"];
    
    NSDate *date = [TIOFleaTaskTests.JSONDateFormatter dateFromString:@"2019-04-20T16:20:00.000+0000"];
    
    MockURLSession *session = [[MockURLSession alloc] initWithJSONResponse:@{
        @"modelId": @"model-id",
        @"hyperparametersId": @"hyperparameters-id",
        @"checkpointId": @"checkpoint-id",
        @"taskId": @"task-id",
        @"deadline": @"2019-04-20T16:20:00.000+0000",
        @"active": @(YES),
        @"link": @"http://goo.gl/Tx3.zip",
        @"checkpointLink": @"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"
    }];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.com"] session:session];
    
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
        [expectation fulfill];
        
        XCTAssertNil(error);
        XCTAssertNotNil(task);
        
        XCTAssertEqualObjects(task.modelId, @"model-id");
        XCTAssertEqualObjects(task.hyperparametersId, @"hyperparameters-id");
        XCTAssertEqualObjects(task.checkpointId, @"checkpoint-id");
        XCTAssertEqualObjects(task.taskId, @"task-id");
        XCTAssertEqualObjects(task.deadline, date);
        XCTAssertTrue(task.active);
        XCTAssertEqualObjects(task.link, [NSURL URLWithString:@"http://goo.gl/Tx3.zip"]);
        XCTAssertEqualObjects(task.checkpointLink, [NSURL URLWithString:@"http://tensoriorepor/models/id/hyperparameters/id/checkpoint/id"]);
    }];
    
    XCTAssert(task.calledResume);
    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testGETTaskURL {
    MockURLSession *session = [[MockURLSession alloc] init];
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://foo.com"] session:session];
    MockSessionDataTask *task = (MockSessionDataTask*)[client GETTaskWithTaskId:@"task-id" callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) { }];
    
    NSURL *expectedURL = [NSURL URLWithString:@"https://foo.com/tasks/task-id"];
    XCTAssertEqualObjects(task.currentRequest.URL, expectedURL);
}

@end
