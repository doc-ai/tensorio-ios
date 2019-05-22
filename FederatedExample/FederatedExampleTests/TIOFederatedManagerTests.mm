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

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>

/**
 * (Temporarily?) expose some of the private methods for tests as we go
 */

@interface TIOFederatedManager ()

- (id<TIOData>)executeTask:(TIOFederatedTask*)task model:(id<TIOTrainableModel>)model;

@end

// MARK: -

@interface TIOFederatedManagerTests : XCTestCase

@end

@implementation TIOFederatedManagerTests

- (void)setUp { }

- (void)tearDown { }

- (void)testRegisterAndUnregisterModelIds {
    TIOFederatedManager *manager = [[TIOFederatedManager alloc] init];
    
    [manager registerForTasksForModelWithId:@"tio:///modelid"];
    XCTAssert([manager.registeredModelIds containsObject:@"tio:///modelid"]);
    
    [manager unregisterForTasksForModelWithId:@"tio:///modelid"];
    XCTAssert(![manager.registeredModelIds containsObject:@"tio:///modelid"]);
}

@end
