//
//  TIOTensorFlowDataTests.m
//  TensorFlowExampleTests
//
//  Created by Phil Dow on 4/11/19.
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

//  TODO: Add pixel buffer tests (#63)

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#include "tensorflow/core/framework/tensor.h"

#pragma clang diagnostic pop

@interface TIOTensorFlowDataTests : XCTestCase

@end

@implementation TIOTensorFlowDataTests

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)tearDown { }

- (void)testTypeSizes {
    XCTAssert(sizeof(float_t) == 4);
    XCTAssert(sizeof(int32_t) == 4);
    XCTAssert(sizeof(int64_t) == 8);
    
    // 32 bit system: sizeof(long) = 4, sizeof(long long) = 8
    // 64 bit system: sizeof(long) = 8, sizeof(long long) = 8
    
    XCTAssert(sizeof((int64_t)@(NSIntegerMax).longLongValue) == 8);
    XCTAssert(sizeof((int32_t)@(NSIntegerMax).longValue) == 4);
    
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    XCTAssert(@(min32bit).longValue == min32bit);
    XCTAssert(@(max32bit).longValue == max32bit);
    XCTAssert(@(min64bit).longLongValue == min64bit);
    XCTAssert(@(max64bit).longLongValue == max64bit);
}

// Note that the zeroth index of a mapped tensor is always the batch
// Our tests use batch sizes of 1

// MARK: - NSNumber + TIOTensorFlowData Get Tensor

- (void)testNumberGetTensorFloatUnquantized {
    // It should get the float_t numeric value
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSNumber *number = @(1.0f);
    tensorflow::Tensor tensor = [number tensorWithDescription:description];
    auto maped = tensor.tensor<float_t, 2>();
    XCTAssertEqual(maped(0,0), 1.0f);
}

- (void)testNumberGetTensorUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric value
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    NSNumber *n0 = @(0);
    tensorflow::Tensor t0 = [n0 tensorWithDescription:description];
    auto m0 = t0.tensor<uint8_t, 2>();
    XCTAssertEqual(m0(0,0), 0);
    
    NSNumber *n1 = @(1);
    tensorflow::Tensor t1 = [n1 tensorWithDescription:description];
    auto m1 = t1.tensor<uint8_t, 2>();
    XCTAssertEqual(m1(0,0), 1);
    
    NSNumber *n255 = @(255);
    tensorflow::Tensor t255 = [n255 tensorWithDescription:description];
    auto m255 = t255.tensor<uint8_t, 2>();
    XCTAssertEqual(m255(0,0), 255);
}

- (void)testNumberGetTensorUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric value to a uint8_t value
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:quantizer
        dequantizer:nil];
    
    NSNumber *n0 = @(0.0f);
    tensorflow::Tensor t0 = [n0 tensorWithDescription:description];
    auto m0 = t0.tensor<uint8_t, 2>();
    XCTAssertEqual(m0(0,0), 0);
    
    NSNumber *n1 = @(1.0f);
    tensorflow::Tensor t1 = [n1 tensorWithDescription:description];
    auto m1 = t1.tensor<uint8_t, 2>();
    XCTAssertEqual(m1(0,0), 1);
    
    NSNumber *n255 = @(255.0f);
    tensorflow::Tensor t255 = [n255 tensorWithDescription:description];
    auto m255 = t255.tensor<uint8_t, 2>();
    XCTAssertEqual(m255(0,0), 255);
}

- (void)testNumberGetTensorInt32 {
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeInt32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSNumber *n0 = @(min32bit);
    tensorflow::Tensor t0 = [n0 tensorWithDescription:description];
    auto m0 = t0.tensor<int32_t, 2>();
    XCTAssertEqual(m0(0,0), min32bit);
    
    NSNumber *n1 = @(max32bit);
    tensorflow::Tensor t1 = [n1 tensorWithDescription:description];
    auto m1 = t1.tensor<int32_t, 2>();
    XCTAssertEqual(m1(0,0), max32bit);
}

- (void)testNumberGetTensorInt64 {
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeInt64
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSNumber *n0 = @(min64bit);
    tensorflow::Tensor t0 = [n0 tensorWithDescription:description];
    auto m0 = t0.tensor<int64_t, 2>();
    XCTAssertEqual(m0(0,0), min64bit);
    
    NSNumber *n1 = @(max64bit);
    tensorflow::Tensor t1 = [n1 tensorWithDescription:description];
    auto m1 = t1.tensor<int64_t, 2>();
    XCTAssertEqual(m1(0,0), max64bit);
}

// MARK: - Batched

- (void)testBatchNumberGetTensorFloatUnquantized {
    // It should get the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(1)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        @(2.0f),
        @(4.0f)
    ];
    
    tensorflow::Tensor tensor = [NSNumber tensorWithColumn:column  description:description];
    auto maped = tensor.tensor<float_t, 2>();
    
    XCTAssertEqual(maped(0,0), 2.0f);
    XCTAssertEqual(maped(1,0), 4.0f);
}

- (void)testBatchNumberGetTensorUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(1)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        @(0),
        @(1),
        @(255)
    ];
    
    tensorflow::Tensor tensor = [NSNumber tensorWithColumn:column  description:description];
    auto maped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(maped(0,0), 0);
    XCTAssertEqual(maped(1,0), 1);
    XCTAssertEqual(maped(2,0), 255);
}

- (void)testBatchNumberGetTensorUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric values to a uint8_t values
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(1)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:quantizer
        dequantizer:nil];
    
    NSArray *column = @[
        @(0.0f),
        @(1.0f),
        @(255.0f)
    ];
    
    tensorflow::Tensor tensor = [NSNumber tensorWithColumn:column  description:description];
    auto maped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(maped(0,0), 0);
    XCTAssertEqual(maped(1,0), 1);
    XCTAssertEqual(maped(2,0), 255);
}

- (void)testBatchNumberGetTensorInt32 {
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(1)]
        batched:YES
        dtype:TIODataTypeInt32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        @(min32bit),
        @(max32bit)
    ];
    
    tensorflow::Tensor tensor = [NSNumber tensorWithColumn:column  description:description];
    auto maped = tensor.tensor<int32_t, 2>();
    
    XCTAssertEqual(maped(0,0), min32bit);
    XCTAssertEqual(maped(1,0), max32bit);
}

- (void)testBatchNumberGetTensorInt64 {
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(1)]
        batched:YES
        dtype:TIODataTypeInt64
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        @(min64bit),
        @(max64bit)
    ];
    
    tensorflow::Tensor tensor = [NSNumber tensorWithColumn:column  description:description];
    auto maped = tensor.tensor<int64_t, 2>();
    
    XCTAssertEqual(maped(0,0), min64bit);
    XCTAssertEqual(maped(1,0), max64bit);
}

// MARK: - NSNumber + TIOTensorFlowData Init with Tensor

- (void)testNumberInitWithTensorFloatUnquantized {
    // It should return a number with the float_t numeric value
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_FLOAT, tensorflow::TensorShape({1,1}));
    tensor.tensor<float_t, 2>()(0,0) = 1.0f;
    
    NSNumber *number = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(number.floatValue, 1.0f);
}

- (void)testNumberInitWithTensorUInt8QuantizedWithoutDequantizer {
    // It should return a number with the uint8_t numeric value
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_UINT8, tensorflow::TensorShape({1,1}));
    
    tensor.tensor<uint8_t, 2>()(0,0) = 0;
    NSNumber *n0 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(n0.unsignedCharValue, 0);
    
    tensor.tensor<uint8_t, 2>()(0,0) = 1;
    NSNumber *n1 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(n1.unsignedCharValue, 1);
    
    tensor.tensor<uint8_t, 2>()(0,0) = 255;
    NSNumber *n255 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(n255.unsignedCharValue, 255);
}

- (void)testNumberInitWithTensorUInt8QuantizedWithDequantizer {
    // It should return a number by converting a uint8_t value to a float_t value
    
    TIODataDequantizer dequantizer = ^float_t(uint8_t value) {
        return (float_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:dequantizer];
    
    tensorflow::Tensor tensor(tensorflow::DT_UINT8, tensorflow::TensorShape({1,1}));
    
    tensor.tensor<uint8_t, 2>()(0,0) = 0;
    NSNumber *n0 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(n0.floatValue, 0.0f);
    
    tensor.tensor<uint8_t, 2>()(0,0) = 1;
    NSNumber *n1 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(n1.floatValue, 1.0f);
    
    tensor.tensor<uint8_t, 2>()(0,0) = 255;
    NSNumber *n255 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(n255.floatValue, 255.0f);
}

- (void)testNumberInitWithTensorInt32 {
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeInt32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_INT32, tensorflow::TensorShape({1,1}));
    
    tensor.tensor<int32_t, 2>()(0,0) = min32bit;
    NSNumber *n0 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual((int32_t)n0.longValue, min32bit);
    
    tensor.tensor<int32_t, 2>()(0,0) = max32bit;
    NSNumber *n1 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual((int32_t)n1.longValue, max32bit);
}

- (void)testNumberInitWithTensorInt64 {
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(1)]
        batched:NO
        dtype:TIODataTypeInt64
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_INT64, tensorflow::TensorShape({1,1}));
    
    tensor.tensor<int64_t, 2>()(0,0) = min64bit;
    NSNumber *n0 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual((int64_t)n0.longLongValue, min64bit);
    
    tensor.tensor<int64_t, 2>()(0,0) = max64bit;
    NSNumber *n1 = [[NSNumber alloc] initWithTensor:tensor description:description];
    XCTAssertEqual((int64_t)n1.longLongValue, max64bit);
}

// MARK: - NSArray + TIOTensorFlowData Get Tensor

- (void)testArrayGetTensorFloatUnquantized {
    // It should get the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *numbers = @[@(-1.0f), @(0.0f), @(1.0f)];
    tensorflow::Tensor tensor = [numbers tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<float_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), -1.0f);
    XCTAssertEqual(tensor_mapped(0,1), 0.0f);
    XCTAssertEqual(tensor_mapped(0,2), 1.0f);
}

- (void)testArrayGetTensorUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    NSArray *numbers = @[ @(0), @(1), @(255)];
    tensorflow::Tensor tensor = [numbers tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), 0);
    XCTAssertEqual(tensor_mapped(0,1), 1);
    XCTAssertEqual(tensor_mapped(0,2), 255);
}

- (void)testArrayGetTensorUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric values to uint8_t values
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:quantizer
        dequantizer:nil];
    
    NSArray *numbers = @[ @(0.0f), @(1.0f), @(255.0f)];
    tensorflow::Tensor tensor = [numbers tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), 0);
    XCTAssertEqual(tensor_mapped(0,1), 1);
    XCTAssertEqual(tensor_mapped(0,2), 255);
}

- (void)testArrayGetTensorInt32 {
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(2)]
        batched:NO
        dtype:TIODataTypeInt32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *numbers = @[ @(min32bit), @(max32bit)];
    tensorflow::Tensor tensor = [numbers tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<int32_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), min32bit);
    XCTAssertEqual(tensor_mapped(0,1), max32bit);
}

- (void)testArrayGetTensorInt64 {
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(2)]
        batched:NO
        dtype:TIODataTypeInt64
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *numbers = @[ @(min64bit), @(max64bit)];
    tensorflow::Tensor tensor = [numbers tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<int64_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), min64bit);
    XCTAssertEqual(tensor_mapped(0,1), max64bit);
}

// MARK: - Batched

- (void)testBatchArrayGetTensorFloatUnquantized {
    // It should get the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(3)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        @[@(-1.0f), @(0.0f), @(1.0f)],
        @[@(-10.0f), @(0.0f), @(10.0f)]
    ];
    
    tensorflow::Tensor tensor = [NSArray tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<float_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), -1.0f);
    XCTAssertEqual(tensor_mapped(0,1), 0.0f);
    XCTAssertEqual(tensor_mapped(0,2), 1.0f);
    
    XCTAssertEqual(tensor_mapped(1,0), -10.0f);
    XCTAssertEqual(tensor_mapped(1,1), 0.0f);
    XCTAssertEqual(tensor_mapped(1,2), 10.0f);
}

- (void)testBatchArrayGetTensorUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(3)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        @[@(0),@(1), @(2)],
        @[@(255), @(254), @(253)]
    ];
    
    tensorflow::Tensor tensor = [NSArray tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), 0);
    XCTAssertEqual(tensor_mapped(0,1), 1);
    XCTAssertEqual(tensor_mapped(0,2), 2);
    
    XCTAssertEqual(tensor_mapped(1,0), 255);
    XCTAssertEqual(tensor_mapped(1,1), 254);
    XCTAssertEqual(tensor_mapped(1,2), 253);
}

- (void)testBatchArrayGetTensorUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric values to uint8_t values
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(3)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:quantizer
        dequantizer:nil];
    
    NSArray *column = @[
        @[@(0.0f), @(1.0f), @(2.0f)],
        @[@(255.0f), @(254.0f), @(253.0f)]
    ];
    
    tensorflow::Tensor tensor = [NSArray tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), 0);
    XCTAssertEqual(tensor_mapped(0,1), 1);
    XCTAssertEqual(tensor_mapped(0,2), 2);
    
    XCTAssertEqual(tensor_mapped(1,0), 255);
    XCTAssertEqual(tensor_mapped(1,1), 254);
    XCTAssertEqual(tensor_mapped(1,2), 253);
}

- (void)testBatchArrayGetTensorInt32 {
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(2)]
        batched:YES
        dtype:TIODataTypeInt32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        @[@(min32bit), @(max32bit)],
        @[@(min32bit+1), @(max32bit-1)]
    ];
    
    tensorflow::Tensor tensor = [NSArray tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<int32_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), min32bit);
    XCTAssertEqual(tensor_mapped(0,1), max32bit);
    
    XCTAssertEqual(tensor_mapped(1,0), min32bit+1);
    XCTAssertEqual(tensor_mapped(1,1), max32bit-1);
}

- (void)testBatchArrayGetTensorInt64 {
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(2)]
        batched:YES
        dtype:TIODataTypeInt64
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        @[@(min64bit), @(max64bit)],
        @[@(min64bit+1), @(max64bit-1)]
    ];
    
    tensorflow::Tensor tensor = [NSArray tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<int64_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), min64bit);
    XCTAssertEqual(tensor_mapped(0,1), max64bit);
    
    XCTAssertEqual(tensor_mapped(1,0), min64bit+1);
    XCTAssertEqual(tensor_mapped(1,1), max64bit-1);
}

// MARK: - NSArray + TIOTensorFlowData Init with Tensor

- (void)testArrayInitWithTensorFloatUnquantized {
    // It should return an array of numbers with the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_FLOAT, tensorflow::TensorShape({1,3}));
    auto tensor_mapped = tensor.tensor<float_t, 2>();
    tensor_mapped(0,0) = -1.0f;
    tensor_mapped(0,1) = 0.0f;
    tensor_mapped(0,2) = 1.0f;
    
    NSArray<NSNumber*> *numbers = [[NSArray alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(numbers[0].floatValue, -1.0f);
    XCTAssertEqual(numbers[1].floatValue, 0.0f);
    XCTAssertEqual(numbers[2].floatValue, 1.0f);
}

- (void)testArrayInitWithTensorUInt8QuantizedWithoutDequantizer {
    // It should return an array of numbers with the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_UINT8, tensorflow::TensorShape({1,3}));
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    tensor_mapped(0,0) = 0;
    tensor_mapped(0,1) = 1;
    tensor_mapped(0,2) = 255;
    
    NSArray<NSNumber*> *numbers = [[NSArray alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(numbers[0].unsignedCharValue, 0);
    XCTAssertEqual(numbers[1].unsignedCharValue, 1);
    XCTAssertEqual(numbers[2].unsignedCharValue, 255);
}

- (void)testArrayInitWithTensorUInt8QuantizedWithDequantizer {
    // It should return an array of numbers by converting uint8_t values to float_t values
    
    TIODataDequantizer dequantizer = ^float_t(uint8_t value) {
        return (float_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:dequantizer];
    
    tensorflow::Tensor tensor(tensorflow::DT_UINT8, tensorflow::TensorShape({1,3}));
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    tensor_mapped(0,0) = 0;
    tensor_mapped(0,1) = 1;
    tensor_mapped(0,2) = 255;
    
    NSArray<NSNumber*> *numbers = [[NSArray alloc] initWithTensor:tensor description:description];
    XCTAssertEqual(numbers[0].unsignedCharValue, 0.0);
    XCTAssertEqual(numbers[1].unsignedCharValue, 1.0);
    XCTAssertEqual(numbers[2].unsignedCharValue, 255.0);
}

- (void)testArrayInitWithTensorInt32 {
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(2)]
        batched:NO
        dtype:TIODataTypeInt32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_INT32, tensorflow::TensorShape({1,2}));
    auto tensor_mapped = tensor.tensor<int32_t, 2>();
    tensor_mapped(0,0) = min32bit;
    tensor_mapped(0,1) = max32bit;
    
    NSArray<NSNumber*> *numbers = [[NSArray alloc] initWithTensor:tensor description:description];
    XCTAssertEqual((int32_t)numbers[0].longValue, min32bit);
    XCTAssertEqual((int32_t)numbers[1].longValue, max32bit);
}

- (void)testArrayInitWithTensorInt64 {
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(2)]
        batched:NO
        dtype:TIODataTypeInt64
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_INT64, tensorflow::TensorShape({1,2}));
    auto tensor_mapped = tensor.tensor<int64_t, 2>();
    tensor_mapped(0,0) = min64bit;
    tensor_mapped(0,1) = max64bit;
    
    NSArray<NSNumber*> *numbers = [[NSArray alloc] initWithTensor:tensor description:description];
    XCTAssertEqual((int64_t)numbers[0].longValue, min64bit);
    XCTAssertEqual((int64_t)numbers[1].longValue, max64bit);
}

// MARK: - NSData + TIOTensorFlowData Get Tensor

- (void)testDataGetTensorFloatUnquantized {
    // It should get the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    size_t len = 3 * sizeof(float_t);
    float_t bytes[3] = { -1.0f, 0.0f, 1.0f};
    NSData *data = [NSData dataWithBytes:bytes length:len];
    tensorflow::Tensor tensor = [data tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<float_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), -1.0f);
    XCTAssertEqual(tensor_mapped(0,1), 0.0f);
    XCTAssertEqual(tensor_mapped(0,2), 1.0f);
}

- (void)testDataGetTensorUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    size_t len = 3 * sizeof(uint8_t);
    uint8_t bytes[3] = {0, 1, 255};
    NSData *data = [NSData dataWithBytes:bytes length:len];
    tensorflow::Tensor tensor = [data tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), 0);
    XCTAssertEqual(tensor_mapped(0,1), 1);
    XCTAssertEqual(tensor_mapped(0,2), 255);
}

- (void)testDataGetTensorUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric values to uint8_t values
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:quantizer
        dequantizer:nil];
    
    size_t len = 3 * sizeof(float_t);
    float_t bytes[3] = { 0.0f, 1.0f, 255.0f};
    NSData *data = [NSData dataWithBytes:bytes length:len];
    tensorflow::Tensor tensor = [data tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), 0);
    XCTAssertEqual(tensor_mapped(0,1), 1);
    XCTAssertEqual(tensor_mapped(0,2), 255);
}

- (void)testDataGetTensorInt32 {
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(2)]
        batched:NO
        dtype:TIODataTypeInt32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    size_t len = 2 * sizeof(int32_t);
    int32_t bytes[2] = { min32bit, max32bit };
    NSData *data = [NSData dataWithBytes:bytes length:len];
    tensorflow::Tensor tensor = [data tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<int32_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), min32bit);
    XCTAssertEqual(tensor_mapped(0,1), max32bit);
}

- (void)testDataGetTensorInt64 {
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(2)]
        batched:NO
        dtype:TIODataTypeInt64
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    size_t len = 2 * sizeof(int64_t);
    int64_t bytes[2] = { min64bit, max64bit };
    NSData *data = [NSData dataWithBytes:bytes length:len];
    tensorflow::Tensor tensor = [data tensorWithDescription:description];
    auto tensor_mapped = tensor.tensor<int64_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), min64bit);
    XCTAssertEqual(tensor_mapped(0,1), max64bit);
}

// MARK: - Batched

- (void)testBatchDataGetTensorFloatUnquantized {
    // It should get the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(3)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        [NSData dataWithBytes:(float_t[]){-1.0f, 0.0f, 1.0f} length:sizeof(float_t)*3],
        [NSData dataWithBytes:(float_t[]){-10.0f, 0.0f, 10.0f} length:sizeof(float_t)*3]
    ];
    
    tensorflow::Tensor tensor = [NSData tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<float_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), -1.0f);
    XCTAssertEqual(tensor_mapped(0,1), 0.0f);
    XCTAssertEqual(tensor_mapped(0,2), 1.0f);
    
    XCTAssertEqual(tensor_mapped(1,0), -10.0f);
    XCTAssertEqual(tensor_mapped(1,1), 0.0f);
    XCTAssertEqual(tensor_mapped(1,2), 10.0f);
}

- (void)testBatchDataGetTensorUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(3)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        [NSData dataWithBytes:(uint8_t[]){0, 1, 2} length:sizeof(uint8_t)*3],
        [NSData dataWithBytes:(uint8_t[]){255, 254, 253} length:sizeof(uint8_t)*3]
    ];
    
    tensorflow::Tensor tensor = [NSData tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), 0);
    XCTAssertEqual(tensor_mapped(0,1), 1);
    XCTAssertEqual(tensor_mapped(0,2), 2);
    
    XCTAssertEqual(tensor_mapped(1,0), 255);
    XCTAssertEqual(tensor_mapped(1,1), 254);
    XCTAssertEqual(tensor_mapped(1,2), 253);
}

- (void)testBatchDataGetTensorUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric values to uint8_t values
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(3)]
        batched:YES
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:quantizer
        dequantizer:nil];
    
    NSArray *column = @[
        [NSData dataWithBytes:(float_t[]){0.0f, 1.0f, 2.0f} length:sizeof(float_t)*3],
        [NSData dataWithBytes:(float_t[]){255.0f, 254.0f, 253.0f} length:sizeof(float_t)*3]
    ];
    
    tensorflow::Tensor tensor = [NSData tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), 0);
    XCTAssertEqual(tensor_mapped(0,1), 1);
    XCTAssertEqual(tensor_mapped(0,2), 2);
    
    XCTAssertEqual(tensor_mapped(1,0), 255);
    XCTAssertEqual(tensor_mapped(1,1), 254);
    XCTAssertEqual(tensor_mapped(1,2), 253);
}

- (void)testBatchDataGetTensorInt32 {
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(2)]
        batched:YES
        dtype:TIODataTypeInt32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        [NSData dataWithBytes:(int32_t[]){min32bit, max32bit} length:sizeof(int32_t)*2],
        [NSData dataWithBytes:(int32_t[]){min32bit+1, max32bit-1} length:sizeof(int32_t)*2]
    ];
    
    tensorflow::Tensor tensor = [NSData tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<int32_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), min32bit);
    XCTAssertEqual(tensor_mapped(0,1), max32bit);
    
    XCTAssertEqual(tensor_mapped(1,0), min32bit+1);
    XCTAssertEqual(tensor_mapped(1,1), max32bit-1);
}

- (void)testBatchDataGetTensorInt64 {
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(-1),@(2)]
        batched:YES
        dtype:TIODataTypeInt64
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSArray *column = @[
        [NSData dataWithBytes:(int64_t[]){min64bit, max64bit} length:sizeof(int64_t)*2],
        [NSData dataWithBytes:(int64_t[]){min64bit+1, max64bit-1} length:sizeof(int64_t)*2]
    ];
    
    tensorflow::Tensor tensor = [NSData tensorWithColumn:column description:description];
    auto tensor_mapped = tensor.tensor<int64_t, 2>();
    
    XCTAssertEqual(tensor_mapped(0,0), min64bit);
    XCTAssertEqual(tensor_mapped(0,1), max64bit);
    
    XCTAssertEqual(tensor_mapped(1,0), min64bit+1);
    XCTAssertEqual(tensor_mapped(1,1), max64bit-1);
}

// MARK: - NSData + TIOTensorFlowData Init with Tensor

- (void)testDataInitWithTensorFloatUnquantized {
    // It should return an array of numbers with the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_FLOAT, tensorflow::TensorShape({1,3}));
    auto tensor_mapped = tensor.tensor<float_t, 2>();
    tensor_mapped(0,0) = -1.0f;
    tensor_mapped(0,1) = 0.0f;
    tensor_mapped(0,2) = 1.0f;
    
    NSData *numbers = [[NSData alloc] initWithTensor:tensor description:description];
    float_t *buffer = (float_t *)numbers.bytes;
    XCTAssertEqual(buffer[0], -1.0f);
    XCTAssertEqual(buffer[1], 0.0f);
    XCTAssertEqual(buffer[2], 1.0f);
}

- (void)testDataInitWithTensorUInt8QuantizedWithoutDequantizer {
    // It should return an array of numbers with the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_UINT8, tensorflow::TensorShape({1,3}));
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    tensor_mapped(0,0) = 0;
    tensor_mapped(0,1) = 1;
    tensor_mapped(0,2) = 255;
    
    NSData *numbers = [[NSData alloc] initWithTensor:tensor description:description];
    uint8_t *buffer = (uint8_t *)numbers.bytes;
    XCTAssertEqual(buffer[0], 0);
    XCTAssertEqual(buffer[1], 1);
    XCTAssertEqual(buffer[2], 255);
}

- (void)testDataInitWithTensorUInt8QuantizedWithDequantizer {
    // It should return an array of numbers by converting uint8_t values to float_t values
    
    TIODataDequantizer dequantizer = ^float_t(uint8_t value) {
        return (float_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(3)]
        batched:NO
        dtype:TIODataTypeUnknown
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:dequantizer];
    
    tensorflow::Tensor tensor(tensorflow::DT_UINT8, tensorflow::TensorShape({1,3}));
    auto tensor_mapped = tensor.tensor<uint8_t, 2>();
    tensor_mapped(0,0) = 0;
    tensor_mapped(0,1) = 1;
    tensor_mapped(0,2) = 255;
    
    NSData *numbers = [[NSData alloc] initWithTensor:tensor description:description];
    float_t *buffer = (float_t *)numbers.bytes;
    XCTAssertEqual(buffer[0], 0.0);
    XCTAssertEqual(buffer[1], 1.0);
    XCTAssertEqual(buffer[2], 255.0);
}

- (void)testDataInitWithTensorInt32 {
    const int32_t min32bit = std::numeric_limits<int32_t>::min();
    const int32_t max32bit = std::numeric_limits<int32_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(2)]
        batched:NO
        dtype:TIODataTypeInt32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_INT32, tensorflow::TensorShape({1,2}));
    auto tensor_mapped = tensor.tensor<int32_t, 2>();
    tensor_mapped(0,0) = min32bit;
    tensor_mapped(0,1) = max32bit;
    
    NSData *numbers = [[NSData alloc] initWithTensor:tensor description:description];
    int32_t *buffer = (int32_t *)numbers.bytes;
    XCTAssertEqual(buffer[0], min32bit);
    XCTAssertEqual(buffer[1], max32bit);
}

- (void)testDataInitWithTensorInt64 {
    const int64_t min64bit = std::numeric_limits<int64_t>::min();
    const int64_t max64bit = std::numeric_limits<int64_t>::max();
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1),@(2)]
        batched:NO
        dtype:TIODataTypeInt64
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    tensorflow::Tensor tensor(tensorflow::DT_INT64, tensorflow::TensorShape({1,2}));
    auto tensor_mapped = tensor.tensor<int64_t, 2>();
    tensor_mapped(0,0) = min64bit;
    tensor_mapped(0,1) = max64bit;
    
    NSData *numbers = [[NSData alloc] initWithTensor:tensor description:description];
    int64_t *buffer = (int64_t *)numbers.bytes;
    XCTAssertEqual(buffer[0], min64bit);
    XCTAssertEqual(buffer[1], max64bit);
}

// MARK: - TIOPixelBuffer + TIOTensorFlowData Get Tensor

- (void)testPixelBufferGetTensorUnnormalized {
    // Create ARGB bytes
    
    const int width = 224;
    const int height = 224;
    const int channels = 4;
    
    uint8_t *bytes = (uint8_t *)malloc(224*224*4*sizeof(uint8_t));
    
    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = bytes + (i * channels);
        
        pixel[0] = 255; // A
        pixel[1] = 255; // R
        pixel[2] = 0;   // G
        pixel[3] = 0;   // B
    }
    
    // Create a pixel buffer for those bytes
    
    const OSType format = kCVPixelFormatType_32ARGB;
    CVPixelBufferRef pixelBuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        format,
        NULL,
        &pixelBuffer);
    
    // Error handling
    
    if ( status != kCVReturnSuccess ) {
        XCTFail(@"Couldn't create pixel buffer");
    }
    
    // Copy bytes to pixel buffer
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(baseAddress, bytes, width * height * channels);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    // Get bytes from pixel buffer
    
    TIOPixelBuffer *pixelBufferWrapper = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    NSArray *shape = @[@(224),@(224),@(3)];
    TIOImageVolume volume = TIOImageVolumeForShape(shape);
    
    TIOPixelBufferLayerDescription *description = [[TIOPixelBufferLayerDescription alloc]
        initWithPixelFormat:kCVPixelFormatType_32ARGB
        shape:shape
        imageVolume:volume
        batched:NO
        normalizer:nil
        denormalizer:nil
        quantized:YES];
    
    tensorflow::Tensor tensor = [pixelBufferWrapper tensorWithDescription:description];
    uint8_t *tensor_bytes = tensor.flat<uint8_t>().data();
    
    const int tensor_channels = 3;
    uint8_t espilon = 1;
    
    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = tensor_bytes + (i * tensor_channels);
        
        XCTAssertEqualWithAccuracy(pixel[0], 255, espilon); // R
        XCTAssertEqualWithAccuracy(pixel[1], 0, espilon);   // G
        XCTAssertEqualWithAccuracy(pixel[2], 0, espilon);   // B
    }
    
    // Free memory
    
    CFRelease(pixelBuffer);
    free(bytes);
}

- (void)testPixelBufferGetTensorNormalized {
    // Create ARGB bytes

    const int width = 224;
    const int height = 224;
    const int channels = 4;

    uint8_t *bytes = (uint8_t *)malloc(224*224*4*sizeof(uint8_t));

    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = bytes + (i * channels);

        pixel[0] = 255; // A
        pixel[1] = 255; // R
        pixel[2] = 0;   // G
        pixel[3] = 0;   // B
    }

    // Create a pixel buffer for those bytes

    const OSType format = kCVPixelFormatType_32ARGB;
    CVPixelBufferRef pixelBuffer = NULL;

    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        format,
        NULL,
        &pixelBuffer);

    // Error handling

    if ( status != kCVReturnSuccess ) {
        XCTFail(@"Couldn't create pixel buffer");
    }

    // Copy bytes to pixel buffer

    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(baseAddress, bytes, width * height * channels);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);

    // Get bytes from pixel buffer

    TIOPixelBuffer *pixelBufferWrapper = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    NSArray *shape = @[@(224),@(224),@(3)];
    TIOImageVolume volume = TIOImageVolumeForShape(shape);
    TIOPixelNormalizer normalizer = TIOPixelNormalizerZeroToOne();

    TIOPixelBufferLayerDescription *description = [[TIOPixelBufferLayerDescription alloc]
        initWithPixelFormat:kCVPixelFormatType_32ARGB
        shape:shape
        imageVolume:volume
        batched:NO
        normalizer:normalizer
        denormalizer:nil
        quantized:NO];

    tensorflow::Tensor tensor = [pixelBufferWrapper tensorWithDescription:description];
    float_t *tensor_bytes = tensor.flat<float_t>().data();

    const int tensor_channels = 3;
    uint8_t espilon = 0.1;

    for ( int i = 0; i < width * height; i++) {
        float_t *pixel = tensor_bytes + (i * tensor_channels);

        XCTAssertEqualWithAccuracy(pixel[0], 1, espilon);   // R
        XCTAssertEqualWithAccuracy(pixel[1], 0, espilon);   // G
        XCTAssertEqualWithAccuracy(pixel[2], 0, espilon);   // B
    }

    // Free memory

    CFRelease(pixelBuffer);
    free(bytes);
}

// MARK: - Batched

- (void)testBatchPixelBufferGetTensorUnnormalized {
    TIOPixelBuffer *pixelBufferWrapper1;
    TIOPixelBuffer *pixelBufferWrapper2;
    
    const int width = 224;
    const int height = 224;
    const int channels = 4;
    const int tensor_channels = 3;
    
    // Create Pixel Buffer 1 ARGB bytes
{
    uint8_t *bytes = (uint8_t *)malloc(224*224*4*sizeof(uint8_t));
    
    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = bytes + (i * channels);
        
        pixel[0] = 255; // A
        pixel[1] = 255; // R
        pixel[2] = 0;   // G
        pixel[3] = 0;   // B
    }
    
    // Create a pixel buffer for those bytes
    
    const OSType format = kCVPixelFormatType_32ARGB;
    CVPixelBufferRef pixelBuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        format,
        NULL,
        &pixelBuffer);
    
    // Error handling
    
    if ( status != kCVReturnSuccess ) {
        XCTFail(@"Couldn't create pixel buffer");
    }
    
    // Copy bytes to pixel buffer
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(baseAddress, bytes, width * height * channels);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    pixelBufferWrapper1 = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    CFRelease(pixelBuffer);
}
    // Create Pixel Buffer 2 ARGB bytes
{
    uint8_t *bytes = (uint8_t *)malloc(224*224*4*sizeof(uint8_t));
    
    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = bytes + (i * channels);
        
        pixel[0] = 255; // A
        pixel[1] = 0;   // R
        pixel[2] = 255; // G
        pixel[3] = 0;   // B
    }
    
    // Create a pixel buffer for those bytes
    
    const OSType format = kCVPixelFormatType_32ARGB;
    CVPixelBufferRef pixelBuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        format,
        NULL,
        &pixelBuffer);
    
    // Error handling
    
    if ( status != kCVReturnSuccess ) {
        XCTFail(@"Couldn't create pixel buffer");
    }
    
    // Copy bytes to pixel buffer
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(baseAddress, bytes, width * height * channels);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    pixelBufferWrapper2 = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    CFRelease(pixelBuffer);
}

    // Get tensor from column of pixel buffers

    NSArray *shape = @[@(-1),@(224),@(224),@(3)];
    TIOImageVolume volume = TIOImageVolumeForShape(shape);

    TIOPixelBufferLayerDescription *description = [[TIOPixelBufferLayerDescription alloc]
        initWithPixelFormat:kCVPixelFormatType_32ARGB
        shape:shape
        imageVolume:volume
        batched:YES
        normalizer:nil
        denormalizer:nil
        quantized:YES];

    tensorflow::Tensor tensor = [TIOPixelBuffer tensorWithColumn:@[
        pixelBufferWrapper1,
        pixelBufferWrapper2
    ] description:description];
    
    // Check Tensor Bytes 1
{
    int offset = 0;
    uint8_t *tensor_bytes = tensor.flat<uint8_t>().data() + offset;

    const int tensor_channels = 3;
    uint8_t espilon = 1;

    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = tensor_bytes + (i * tensor_channels);

        XCTAssertEqualWithAccuracy(pixel[0], 255, espilon); // R
        XCTAssertEqualWithAccuracy(pixel[1], 0, espilon);   // G
        XCTAssertEqualWithAccuracy(pixel[2], 0, espilon);   // B
    }
}
    // Check Tensor Bytes 2
{
    int offset = 1 * width * height * tensor_channels;
    uint8_t *tensor_bytes = tensor.flat<uint8_t>().data() + offset;

    const int tensor_channels = 3;
    uint8_t espilon = 1;

    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = tensor_bytes + (i * tensor_channels);

        XCTAssertEqualWithAccuracy(pixel[0], 0, espilon);   // R
        XCTAssertEqualWithAccuracy(pixel[1], 255, espilon); // G
        XCTAssertEqualWithAccuracy(pixel[2], 0, espilon);   // B
    }
}

}

- (void)testBatchPixelBufferGetTensorNormalized {
    TIOPixelBuffer *pixelBufferWrapper1;
    TIOPixelBuffer *pixelBufferWrapper2;
    
    const int width = 224;
    const int height = 224;
    const int channels = 4;
    const int tensor_channels = 3;
    
    // Create Pixel Buffer 1 ARGB bytes
{
    uint8_t *bytes = (uint8_t *)malloc(224*224*4*sizeof(uint8_t));
    
    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = bytes + (i * channels);
        
        pixel[0] = 255; // A
        pixel[1] = 255; // R
        pixel[2] = 0;   // G
        pixel[3] = 0;   // B
    }
    
    // Create a pixel buffer for those bytes
    
    const OSType format = kCVPixelFormatType_32ARGB;
    CVPixelBufferRef pixelBuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        format,
        NULL,
        &pixelBuffer);
    
    // Error handling
    
    if ( status != kCVReturnSuccess ) {
        XCTFail(@"Couldn't create pixel buffer");
    }
    
    // Copy bytes to pixel buffer
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(baseAddress, bytes, width * height * channels);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    pixelBufferWrapper1 = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    CFRelease(pixelBuffer);
}
    // Create Pixel Buffer 2 ARGB bytes
{
    uint8_t *bytes = (uint8_t *)malloc(224*224*4*sizeof(uint8_t));
    
    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = bytes + (i * channels);
        
        pixel[0] = 255; // A
        pixel[1] = 0;   // R
        pixel[2] = 255; // G
        pixel[3] = 0;   // B
    }
    
    // Create a pixel buffer for those bytes
    
    const OSType format = kCVPixelFormatType_32ARGB;
    CVPixelBufferRef pixelBuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        format,
        NULL,
        &pixelBuffer);
    
    // Error handling
    
    if ( status != kCVReturnSuccess ) {
        XCTFail(@"Couldn't create pixel buffer");
    }
    
    // Copy bytes to pixel buffer
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(baseAddress, bytes, width * height * channels);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    pixelBufferWrapper2 = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    CFRelease(pixelBuffer);
}

    // Get tensor from column of pixel buffers

    NSArray *shape = @[@(-1),@(224),@(224),@(3)];
    TIOImageVolume volume = TIOImageVolumeForShape(shape);
    TIOPixelNormalizer normalizer = TIOPixelNormalizerZeroToOne();

    TIOPixelBufferLayerDescription *description = [[TIOPixelBufferLayerDescription alloc]
        initWithPixelFormat:kCVPixelFormatType_32ARGB
        shape:shape
        imageVolume:volume
        batched:YES
        normalizer:normalizer
        denormalizer:nil
        quantized:NO];

    tensorflow::Tensor tensor = [TIOPixelBuffer tensorWithColumn:@[
        pixelBufferWrapper1,
        pixelBufferWrapper2
    ] description:description];
    
    // Check Tensor Bytes 1
{
    int offset = 0;
    float_t *tensor_bytes = tensor.flat<float_t>().data() + offset;

    const int tensor_channels = 3;
    float_t espilon = 0.1;

    for ( int i = 0; i < width * height; i++) {
        float_t *pixel = tensor_bytes + (i * tensor_channels);

        XCTAssertEqualWithAccuracy(pixel[0], 1.0, espilon); // R
        XCTAssertEqualWithAccuracy(pixel[1], 0.0, espilon); // G
        XCTAssertEqualWithAccuracy(pixel[2], 0.0, espilon); // B
    }
}
    // Check Tensor Bytes 2
{
    int offset = 1 * width * height * tensor_channels;
    float_t *tensor_bytes = tensor.flat<float_t>().data() + offset;

    const int tensor_channels = 3;
    float_t espilon = 0.1;

    for ( int i = 0; i < width * height; i++) {
        float_t *pixel = tensor_bytes + (i * tensor_channels);

        XCTAssertEqualWithAccuracy(pixel[0], 0.0, espilon); // R
        XCTAssertEqualWithAccuracy(pixel[1], 1.0, espilon); // G
        XCTAssertEqualWithAccuracy(pixel[2], 0.0, espilon); // B
    }
}
}

// MARK: - TIOPixelBuffer + TIOTensorFlowData Init With Tensor

- (void)testPixelBufferInitWithTensorUnnormalized {
    // Create RGB tensor

    const int width = 224;
    const int height = 224;
    const int channels = 3;

    tensorflow::Tensor tensor(tensorflow::DT_UINT8, {width,height,channels});
    uint8_t *bytes = tensor.flat<uint8_t>().data();

    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = bytes + (i * channels);

        pixel[0] = 255; // R
        pixel[1] = 0;   // G
        pixel[2] = 0;   // B
    }

    // Create a pixel buffer from them

    NSArray *shape = @[@(224),@(224),@(3)];
    TIOImageVolume volume = TIOImageVolumeForShape(shape);

    TIOPixelBufferLayerDescription *description = [[TIOPixelBufferLayerDescription alloc]
        initWithPixelFormat:kCVPixelFormatType_32ARGB
        shape:shape
        imageVolume:volume
        batched:NO
        normalizer:nil
        denormalizer:nil
        quantized:YES];
    
    TIOPixelBuffer *pixelBufferWrapper = [[TIOPixelBuffer alloc] initWithTensor:tensor description:description];
    CVPixelBufferRef pixelBuffer = pixelBufferWrapper.pixelBuffer;

    // Get bytes to pixel buffer

    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *pixel_bytes = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);

    const int pixel_channels = 4;
    uint8_t espilon = 1;

    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = pixel_bytes + (i * pixel_channels);

        XCTAssertEqualWithAccuracy(pixel[0], 255, espilon); // A
        XCTAssertEqualWithAccuracy(pixel[1], 255, espilon); // R
        XCTAssertEqualWithAccuracy(pixel[2], 0, espilon);   // G
        XCTAssertEqualWithAccuracy(pixel[3], 0, espilon);   // B
    }

    // Free memory

    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
}

- (void)testPixelBufferInitWithTensorNormalized {
    // Create floating point RGB bytes

    const int width = 224;
    const int height = 224;
    const int channels = 3;

    tensorflow::Tensor tensor(tensorflow::DT_FLOAT, {width,height,channels});
    float_t *bytes = tensor.flat<float_t>().data();
    
    for ( int i = 0; i < width * height; i++) {
        float_t *pixel = bytes + (i * channels);

        pixel[0] = 1.0; // R
        pixel[1] = 0.0; // G
        pixel[2] = 0.0; // B
    }

    // Create a pixel buffer from them

    NSArray *shape = @[@(224),@(224),@(3)];
    TIOImageVolume volume = TIOImageVolumeForShape(shape);
    TIOPixelDenormalizer denormalizer = TIOPixelDenormalizerZeroToOne();

    TIOPixelBufferLayerDescription *description = [[TIOPixelBufferLayerDescription alloc]
        initWithPixelFormat:kCVPixelFormatType_32ARGB
        shape:shape
        imageVolume:volume
        batched:NO
        normalizer:nil
        denormalizer:denormalizer
        quantized:NO];

    TIOPixelBuffer *pixelBufferWrapper = [[TIOPixelBuffer alloc] initWithTensor:tensor description:description];
    CVPixelBufferRef pixelBuffer = pixelBufferWrapper.pixelBuffer;

    // Get bytes to pixel buffer

    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *pixel_bytes = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);

    const int pixel_channels = 4;
    uint8_t espilon = 1;

    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = pixel_bytes + (i * pixel_channels);

        XCTAssertEqualWithAccuracy(pixel[0], 255, espilon); // A
        XCTAssertEqualWithAccuracy(pixel[1], 255, espilon); // R
        XCTAssertEqualWithAccuracy(pixel[2], 0, espilon);   // G
        XCTAssertEqualWithAccuracy(pixel[3], 0, espilon);   // B
    }

    // Free memory

    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
}

@end
