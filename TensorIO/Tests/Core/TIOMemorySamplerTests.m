//
//  TIOMemorySamplerTests.m
//  TensorIO_Tests
//
//  Created by Phil Dow on 7/2/19.
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

@interface TIOMemorySamplerTests : XCTestCase

@end

@implementation TIOMemorySamplerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testReturnsNoResultIfStartNeverCalled {
    TIOMemorySampler *sampler = [[TIOMemorySampler alloc] initWithInterval:0.1];
    XCTAssert(sampler.max.longValue == -1);
}

- (void)testReturnsSomeResult {
    TIOMemorySampler *sampler = [[TIOMemorySampler alloc] initWithInterval:0.01];
    
    [sampler start];
    for (NSUInteger i = 0; i < 1000000; i++) {
        uint8_t *bytes = (uint8_t *)malloc(1024 * sizeof(uint8_t));
        for (NSUInteger j = 0; j < 1024; j++) {
            bytes[j] = 1;
        }
        free(bytes);
    };
    [sampler stop];
    
    XCTAssert(sampler.max.longValue > 0);
}

@end
