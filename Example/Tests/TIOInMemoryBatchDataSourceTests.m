//
//  TIOInMemoryBatchDataSourceTests.m
//  TensorIO_Tests
//
//  Created by Phil Dow on 5/20/19.
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

@interface TIOInMemoryBatchDataSourceTests : XCTestCase

@property TIOBatchItem *item;
@property TIOBatch *batch;

@end

@implementation TIOInMemoryBatchDataSourceTests

- (void)setUp {
    
    // Single item tests
    
    self.item = @{
        @"image": @[@(0),@(1),@(2)],
        @"label": @(-1)
    };
    
    // Batch tests
    
    self.batch = [[TIOBatch alloc] initWithKeys:@[
        @"image",
        @"label"
    ]];
    
    [self.batch addItem:@{
        @"image": @[@(0),@(1),@(2)],
        @"label": @(-1)
    }];
    
    [self.batch addItem:@{
        @"image": @[@(3),@(4),@(5)],
        @"label": @(0)
    }];
    
    [self.batch addItem:@{
        @"image": @[@(6),@(7),@(8)],
        @"label": @(1)
    }];
}

- (void)tearDown { }

- (void)testInitsWithBatchCorrectly {
    TIOInMemoryBatchDataSource *source = [[TIOInMemoryBatchDataSource alloc] initWithItem:self.item];
    
    XCTAssert(source.numberOfItems == 1);
    XCTAssertEqualObjects([source.batch itemAtIndex:0], self.item);
}

- (void)testInitsWithBatchItemCorrectly {
    TIOInMemoryBatchDataSource *source = [[TIOInMemoryBatchDataSource alloc] initWithBatch:self.batch];
    
    XCTAssert(source.numberOfItems == 3);
    XCTAssertEqualObjects([source.batch itemAtIndex:0], [self.batch itemAtIndex:0]);
    XCTAssertEqualObjects([source.batch itemAtIndex:1], [self.batch itemAtIndex:1]);
    XCTAssertEqualObjects([source.batch itemAtIndex:2], [self.batch itemAtIndex:2]);
}

- (void)testReturnsCorrectKeys {
    TIOInMemoryBatchDataSource *source = [[TIOInMemoryBatchDataSource alloc] initWithBatch:self.batch];
    
    XCTAssertEqualObjects(source.keys, (@[@"image", @"label"]));
}

- (void)testReturnsCorrectNumberOfItems {
    TIOInMemoryBatchDataSource *source = [[TIOInMemoryBatchDataSource alloc] initWithBatch:self.batch];
    
    XCTAssert(source.numberOfItems == 3);
}

- (void)testReturnsCorrectItemAtIndex {
    TIOInMemoryBatchDataSource *source = [[TIOInMemoryBatchDataSource alloc] initWithBatch:self.batch];
    
    XCTAssertEqualObjects([source itemAtIndex:0], [self.batch itemAtIndex:0]);
    XCTAssertEqualObjects([source itemAtIndex:1], [self.batch itemAtIndex:1]);
    XCTAssertEqualObjects([source itemAtIndex:2], [self.batch itemAtIndex:2]);
}

@end
