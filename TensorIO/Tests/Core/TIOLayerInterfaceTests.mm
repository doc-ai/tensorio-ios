//
//  TIOLayerInterfaceTests.m
//  TensorIO_Tests
//
//  Created by Phil Dow on 4/17/19.
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

@interface TIOLayerInterfaceTests : XCTestCase

@end

@implementation TIOLayerInterfaceTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: - Vector Layer Description Tests

- (void)testVectorLengthIsCalculatedFromShape {
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(6),@(7)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    XCTAssert(description.length == 42);
}

- (void)testVectorLengthIsAlwaysPositive {
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(6),@(7)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    XCTAssert(description.length == 42);
}

// MARK: - String Layer Description Tests

- (void)testStringLengthIsCalculatedFromShapeAndDType {
    TIOStringLayerDescription *descriptionUInt8 = [[TIOStringLayerDescription alloc]
        initWithShape:@[@(6),@(7)]
        batched:NO
        dtype:TIODataTypeUInt8];
    
    XCTAssert(descriptionUInt8.length == 42);
    
    TIOStringLayerDescription *descriptionFloat32 = [[TIOStringLayerDescription alloc]
        initWithShape:@[@(6),@(7)]
        batched:NO
        dtype:TIODataTypeFloat32];
    
    XCTAssert(descriptionFloat32.length == 42);
    
    TIOStringLayerDescription *descriptionInt32 = [[TIOStringLayerDescription alloc]
        initWithShape:@[@(6),@(7)]
        batched:NO
        dtype:TIODataTypeInt32];
    
    XCTAssert(descriptionInt32.length == 42);
    
    TIOStringLayerDescription *descriptionInt64 = [[TIOStringLayerDescription alloc]
        initWithShape:@[@(6),@(7)]
        batched:NO
        dtype:TIODataTypeInt64];
    
    XCTAssert(descriptionInt64.length == 42);
}

- (void)testStringLengthIsAlwaysPositive {
    TIOStringLayerDescription *descriptionUInt8 = [[TIOStringLayerDescription alloc]
        initWithShape:@[@(-1),@(6),@(7)]
        batched:NO
        dtype:TIODataTypeUInt8];
    
    XCTAssert(descriptionUInt8.length == 42);
}

@end
