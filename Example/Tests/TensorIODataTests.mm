//
//  TensorIODataTests.m
//  TensorIO_Tests
//
//  Created by Philip Dow on 8/23/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <TensorIO/TensorIO-umbrella.h>

@interface TensorIODataTests : XCTestCase

@end

@implementation TensorIODataTests

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
        initWithLength:1
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 1 * sizeof(float_t);
    float_t *bytes = (float *)malloc(length);
    NSNumber *number = @(1.0f);
    
    [number getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 1.0f);
    
    free(bytes);
}

- (void)testNumberGetBytesUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric value
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 1 * sizeof(uint8_t);
    uint8_t *bytes = (uint8_t *)malloc(length);
    
    NSNumber *n0 = @(0);
    [n0 getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 0);
    
    NSNumber *n1 = @(1);
    [n1 getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 1);
    
    NSNumber *n255 = @(255);
    [n255 getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 255);
    
    free(bytes);
}

- (void)testNumberGetBytesUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric value to a uint8_t value
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:quantizer
        dequantizer:nil];
    
    size_t length = 1 * sizeof(uint8_t);
    uint8_t *bytes = (uint8_t *)malloc(length);
    
    NSNumber *n0 = @(0.0f);
    [n0 getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 0);
    
    NSNumber *n1 = @(1.0f);
    [n1 getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 1);
    
    NSNumber *n255 = @(255.0f);
    [n255 getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 255);
    
    free(bytes);
}

// MARK: - NSNumber + TIOData Init with Bytes

- (void)testNumberInitWithBytesFloatUnquantized {
    // It should return a number with the float_t numeric value
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 1 * sizeof(float_t);
    float_t bytes[1] = { 1.0f };
    
    NSNumber *number = [[NSNumber alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(number.floatValue, 1.0f);
}

- (void)testNumberInitWithBytesUInt8QuantizedWithoutDequantizer {
    // It should return a number with the uint8_t numeric value
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 1 * sizeof(uint8_t);
    uint8_t bytes[1] = { 0 };
    
    bytes[0] = 0;
    NSNumber *n0 = [[NSNumber alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(n0.unsignedCharValue, 0);
    
    bytes[0] = 1;
    NSNumber *n1 = [[NSNumber alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(n1.unsignedCharValue, 1);
    
    bytes[0] = 255;
    NSNumber *n255 = [[NSNumber alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(n255.unsignedCharValue, 255);
}

- (void)testNumberInitWithBytesUInt8QuantizedWithDequantizer {
    // It should return a number by converting a uint8_t value to a float_t value
    
    TIODataDequantizer dequantizer = ^float_t(uint8_t value) {
        return (float_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:dequantizer];
    
    size_t length = 1 * sizeof(uint8_t);
    uint8_t bytes[1] = { 0 };
    
    bytes[0] = 0;
    NSNumber *n0 = [[NSNumber alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(n0.floatValue, 0.0f);
    
    bytes[0] = 1;
    NSNumber *n1 = [[NSNumber alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(n1.floatValue, 1.0f);
    
    bytes[0] = 255;
    NSNumber *n255 = [[NSNumber alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(n255.floatValue, 255.0f);
}

// MARK: - NSArray + TIOData Get Bytes

- (void)testArrayGetBytesFloatUnquantized {
    // It should get the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:3
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 3 * sizeof(float_t);
    float_t *bytes = (float *)malloc(length);
    NSArray *numbers = @[ @(-1.0f), @(0.0f), @(1.0f)];
    
    [numbers getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], -1.0f);
    XCTAssertEqual(bytes[1], 0.0f);
    XCTAssertEqual(bytes[2], 1.0f);
    
    free(bytes);
}

- (void)testArrayGetBytesUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 3 * sizeof(uint8_t);
    uint8_t *bytes = (uint8_t *)malloc(length);
    NSArray *numbers = @[ @(0), @(1), @(255)];
    
    [numbers getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 0);
    XCTAssertEqual(bytes[1], 1);
    XCTAssertEqual(bytes[2], 255);
    
    free(bytes);
}

- (void)testArrayGetBytesUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric values to uint8_t values
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:quantizer
        dequantizer:nil];
    
    size_t length = 3 * sizeof(uint8_t);
    uint8_t *bytes = (uint8_t *)malloc(length);
    NSArray *numbers = @[ @(0.0f), @(1.0f), @(255.0f)];
    
    [numbers getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 0);
    XCTAssertEqual(bytes[1], 1);
    XCTAssertEqual(bytes[2], 255);
}

// MARK: - NSArray + TIOData Init with Bytes

- (void)testArrayInitWithBytesFloatUnquantized {
    // It should return an array of numbers with the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:3
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 3 * sizeof(float_t);
    float_t bytes[3] = { -1.0f, 0.0f, 1.0f };
    
    NSArray<NSNumber*> *numbers = [[NSArray alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(numbers[0].floatValue, -1.0f);
    XCTAssertEqual(numbers[1].floatValue, 0.0f);
    XCTAssertEqual(numbers[2].floatValue, 1.0f);
}

- (void)testArrayInitWithBytesUInt8QuantizedWithoutDequantizer {
    // It should return an array of numbers with the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:3
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 3 * sizeof(uint8_t);
    uint8_t bytes[3] = { 0, 1, 255 };
    
    NSArray<NSNumber*> *numbers = [[NSArray alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(numbers[0].unsignedCharValue, 0);
    XCTAssertEqual(numbers[1].unsignedCharValue, 1);
    XCTAssertEqual(numbers[2].unsignedCharValue, 255);
}

- (void)testArrayInitWithBytesUInt8QuantizedWithDequantizer {
    // It should return an array of numbers by converting uint8_t values to float_t values
    
    TIODataDequantizer dequantizer = ^float_t(uint8_t value) {
        return (float_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:dequantizer];
    
    size_t length = 3 * sizeof(uint8_t);
    uint8_t bytes[3] = { 0, 1, 255 };
    
    NSArray<NSNumber*> *numbers = [[NSArray alloc] initWithBytes:bytes length:length description:description];
    XCTAssertEqual(numbers[0].unsignedCharValue, 0.0);
    XCTAssertEqual(numbers[1].unsignedCharValue, 1.0);
    XCTAssertEqual(numbers[2].unsignedCharValue, 255.0);
}

// MARK: - NSData + TIOData Get Bytes

- (void)testDataGetBytesFloatUnquantized {
    // It should get the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:3
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 3 * sizeof(float_t);
    float_t *bytes = (float *)malloc(length);
    
    float_t srcBytes[3] = { -1.0f, 0.0f, 1.0f};
    NSData *data = [NSData dataWithBytes:srcBytes length:length];
    
    [data getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], -1.0f);
    XCTAssertEqual(bytes[1], 0.0f);
    XCTAssertEqual(bytes[2], 1.0f);
    
    free(bytes);
}

- (void)testDataGetBytesUInt8QuantizedWithoutQuantizer {
    // It should get the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 3 * sizeof(uint8_t);
    uint8_t *bytes = (uint8_t *)malloc(length);
    
    uint8_t srcBytes[3] = { 0, 1, 255};
    NSData *data = [NSData dataWithBytes:srcBytes length:length];
    
    [data getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 0);
    XCTAssertEqual(bytes[1], 1);
    XCTAssertEqual(bytes[2], 255);
    
    free(bytes);
}

- (void)testDataGetBytesUInt8QuantizedWithQuantizer {
    // It should convert the float_t numeric values to uint8_t values
    
    TIODataQuantizer quantizer = ^uint8_t(float_t value) {
        return (uint8_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:quantizer
        dequantizer:nil];
    
    size_t length = 3 * sizeof(uint8_t);
    uint8_t *bytes = (uint8_t *)malloc(length);
    
    size_t srcLength = 3 * sizeof(float_t);
    float_t srcBytes[3] = { 0.0f, 1.0f, 255.0f};
    NSData *data = [NSData dataWithBytes:srcBytes length:srcLength];
    
    [data getBytes:bytes length:length description:description];
    XCTAssertEqual(bytes[0], 0);
    XCTAssertEqual(bytes[1], 1);
    XCTAssertEqual(bytes[2], 255);
}

// MARK: - NSData + TIOData Init with Bytes

- (void)testDataInitWithBytesFloatUnquantized {
    // It should return an array of numbers with the float_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:3
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 3 * sizeof(float_t);
    float_t bytes[3] = { -1.0f, 0.0f, 1.0f };
    
    NSData *numbers = [[NSData alloc] initWithBytes:bytes length:length description:description];
    float_t *buffer = (float_t *)numbers.bytes;
    XCTAssertEqual(buffer[0], -1.0f);
    XCTAssertEqual(buffer[1], 0.0f);
    XCTAssertEqual(buffer[2], 1.0f);
}

- (void)testDataInitWithBytesUInt8QuantizedWithoutDequantizer {
    // It should return an array of numbers with the uint8_t numeric values
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:3
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:nil];
    
    size_t length = 3 * sizeof(uint8_t);
    uint8_t bytes[3] = { 0, 1, 255 };
    
    NSData *numbers = [[NSData alloc] initWithBytes:bytes length:length description:description];
    uint8_t *buffer = (uint8_t *)numbers.bytes;
    XCTAssertEqual(buffer[0], 0);
    XCTAssertEqual(buffer[1], 1);
    XCTAssertEqual(buffer[2], 255);
}

- (void)testDataInitWithBytesUInt8QuantizedWithDequantizer {
    // It should return an array of numbers by converting uint8_t values to float_t values
    
    TIODataDequantizer dequantizer = ^float_t(uint8_t value) {
        return (float_t)value;
    };
    
    TIOVectorLayerDescription *description = [[TIOVectorLayerDescription alloc]
        initWithLength:1
        labels:nil
        quantized:YES
        quantizer:nil
        dequantizer:dequantizer];
    
    size_t length = 3 * sizeof(uint8_t);
    uint8_t bytes[3] = { 0, 1, 255 };
    
    NSData *numbers = [[NSData alloc] initWithBytes:bytes length:length description:description];
    float_t *buffer = (float_t *)numbers.bytes;
    XCTAssertEqual(buffer[0], 0.0);
    XCTAssertEqual(buffer[1], 1.0);
    XCTAssertEqual(buffer[2], 255.0);
}

@end
