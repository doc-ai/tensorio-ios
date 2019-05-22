//
//  TIOFederatedTaskTests.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/21/19.
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

@interface TIOFederatedTaskTests : XCTestCase

@property NSDictionary *JSON;

@end

@implementation TIOFederatedTaskTests

- (void)setUp {
    self.JSON = @{
        @"id": @"tio://taskid",
        @"name": @"foo",
        @"details": @"bar",
        @"model": @{
            @"id": @"tio://modelid"
        },
        @"taskParameters": @{
            @"numEpochs": @(1),
            @"batchSize": @(8),
            @"placeholders": @[]
        }
    };
}

- (void)tearDown { }

- (void)testParsersIdentifier {
    TIOFederatedTask *task = [[TIOFederatedTask alloc] initWithJSON:self.JSON];
    XCTAssertEqualObjects(task.identifier, @"tio://taskid");
}

- (void)testParsesName {
    TIOFederatedTask *task = [[TIOFederatedTask alloc] initWithJSON:self.JSON];
    XCTAssertEqualObjects(task.name, @"foo");
}

- (void)testParsesDetails {
    TIOFederatedTask *task = [[TIOFederatedTask alloc] initWithJSON:self.JSON];
    XCTAssertEqualObjects(task.details, @"bar");
}

- (void)testParsesModelIdentifier {
    TIOFederatedTask *task = [[TIOFederatedTask alloc] initWithJSON:self.JSON];
    XCTAssertEqualObjects(task.modelIdentifier, @"tio://modelid");
}

- (void)testParsesNumEpochs {
    TIOFederatedTask *task = [[TIOFederatedTask alloc] initWithJSON:self.JSON];
    XCTAssert(task.epochs == 1);
}

- (void)testParsesBatchSize {
    TIOFederatedTask *task = [[TIOFederatedTask alloc] initWithJSON:self.JSON];
    XCTAssert(task.batchSize == 8);
}

- (void)testIgnoresPlaceholders {
    TIOFederatedTask *task = [[TIOFederatedTask alloc] initWithJSON:self.JSON];
    XCTAssertNil(task.placeholders);
}

@end
