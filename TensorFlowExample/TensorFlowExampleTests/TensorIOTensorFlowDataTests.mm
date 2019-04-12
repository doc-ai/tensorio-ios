//
//  TIOTensorFlowDataTests.m
//  TensorFlowExampleTests
//
//  Created by Phil Dow on 4/11/19.
//  Copyright © 2019 doc.ai. All rights reserved.
//

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
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: - NSNumber + TIOData Get Bytes

- (void)testNumberGetBytesFloatUnquantized {
    // It should get the float_t numeric value
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1)]
        length:1
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    NSNumber *number = @(1.0f);
    tensorflow::Tensor tensor = [number tensorWithDescription:description];
    auto maped = tensor.tensor<float_t, 2>();
    XCTAssertEqual(maped(0,0), 1.0f);
}

- (void)testNumberGetBytesUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric value
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1)]
        length:1
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

- (void)testNumberGetBytesUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric value to a uint8_t value
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1)]
        length:1
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


@end
