//
//  TIOModelIOTests.m
//  TensorIO_Tests
//
//  Created by Phil Dow on 6/26/19.
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

@import XCTest;
@import TensorIO;

@interface TIOModelIOTests : XCTestCase

@property TIOLayerInterface *fooIn;
@property TIOLayerInterface *barIn;
@property TIOLayerInterface *fooOut;
@property TIOLayerInterface *barOut;
@property TIOLayerInterface *fooPlaceholder;
@property TIOLayerInterface *barPlaceholder;

@end

@implementation TIOModelIOTests

- (void)setUp {
    self.fooIn = [[TIOLayerInterface alloc] initWithName:@"foo" JSON:nil mode:TIOLayerInterfaceModeInput vectorDescription:[[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1)]
        batched:NO
        dtype:TIODataTypeFloat32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil]];
    self.barIn = [[TIOLayerInterface alloc] initWithName:@"bar" JSON:nil mode:TIOLayerInterfaceModeInput vectorDescription:[[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1)]
        batched:NO
        dtype:TIODataTypeFloat32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil]];
    self.fooOut = [[TIOLayerInterface alloc] initWithName:@"foo" JSON:nil mode:TIOLayerInterfaceModeOutput vectorDescription:[[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1)]
        batched:NO
        dtype:TIODataTypeFloat32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil]];
    self.barOut = [[TIOLayerInterface alloc] initWithName:@"bar" JSON:nil mode:TIOLayerInterfaceModeOutput vectorDescription:[[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1)]
        batched:NO
        dtype:TIODataTypeFloat32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil]];
    self.fooPlaceholder = [[TIOLayerInterface alloc] initWithName:@"foo" JSON:nil mode:TIOLayerInterfaceModePlaceholder vectorDescription:[[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1)]
        batched:NO
        dtype:TIODataTypeFloat32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil]];
    self.barPlaceholder = [[TIOLayerInterface alloc] initWithName:@"bar" JSON:nil mode:TIOLayerInterfaceModePlaceholder vectorDescription:[[TIOVectorLayerDescription alloc]
        initWithShape:@[@(1)]
        batched:NO
        dtype:TIODataTypeFloat32
        labels:nil
        quantized:NO
        quantizer:nil
        dequantizer:nil]];
}

- (void)tearDown { }

// MARK: -

- (void)testModelIOPreservesIndex {
    TIOModelIO *io = [[TIOModelIO alloc] initWithInputInterfaces:@[self.fooIn, self.barIn] ouputInterfaces:@[self.fooOut, self.barOut] placeholderInterfaces:@[self.fooPlaceholder, self.barPlaceholder]];
    
    XCTAssertEqualObjects(io.inputs[0], self.fooIn);
    XCTAssertEqualObjects(io.inputs[1], self.barIn);
    
    XCTAssertEqualObjects(io.outputs[0], self.fooOut);
    XCTAssertEqualObjects(io.outputs[1], self.barOut);
    
    XCTAssertEqualObjects(io.placeholders[0], self.fooPlaceholder);
    XCTAssertEqualObjects(io.placeholders[1], self.barPlaceholder);
}

- (void)testModelIOPreservesName {
    TIOModelIO *io = [[TIOModelIO alloc] initWithInputInterfaces:@[self.fooIn, self.barIn] ouputInterfaces:@[self.fooOut, self.barOut] placeholderInterfaces:@[self.fooPlaceholder, self.barPlaceholder]];
    
    XCTAssertEqualObjects(io.inputs[@"foo"], self.fooIn);
    XCTAssertEqualObjects(io.inputs[@"bar"], self.barIn);
    
    XCTAssertEqualObjects(io.outputs[@"foo"], self.fooOut);
    XCTAssertEqualObjects(io.outputs[@"bar"], self.barOut);
    
    XCTAssertEqualObjects(io.placeholders[@"foo"], self.fooPlaceholder);
    XCTAssertEqualObjects(io.placeholders[@"bar"], self.barPlaceholder);
}

- (void)testModelIOReturnsAllObject {
    TIOModelIO *io = [[TIOModelIO alloc] initWithInputInterfaces:@[self.fooIn, self.barIn] ouputInterfaces:@[self.fooOut, self.barOut] placeholderInterfaces:@[self.fooPlaceholder, self.barPlaceholder]];
    
    XCTAssertEqualObjects(io.inputs.all, (@[self.fooIn, self.barIn]));
    XCTAssertEqualObjects(io.outputs.all, (@[self.fooOut, self.barOut]));
    XCTAssertEqualObjects(io.placeholders.all, (@[self.fooPlaceholder, self.barPlaceholder]));
}

- (void)testModelIOReturnsAllKeys {
    TIOModelIO *io = [[TIOModelIO alloc] initWithInputInterfaces:@[self.fooIn, self.barIn] ouputInterfaces:@[self.fooOut, self.barOut] placeholderInterfaces:@[self.fooPlaceholder, self.barPlaceholder]];
    
    XCTAssertEqualObjects([NSSet setWithArray:io.inputs.keys], ([NSSet setWithArray:@[@"foo", @"bar"]]));
    XCTAssertEqualObjects([NSSet setWithArray:io.outputs.keys], ([NSSet setWithArray:@[@"foo", @"bar"]]));
    XCTAssertEqualObjects([NSSet setWithArray:io.placeholders.keys], ([NSSet setWithArray:@[@"foo", @"bar"]]));
}

- (void)testModelIOCountIsCorrect {
    TIOModelIO *io = [[TIOModelIO alloc] initWithInputInterfaces:@[self.fooIn, self.barIn] ouputInterfaces:@[self.fooOut, self.barOut] placeholderInterfaces:@[self.fooPlaceholder, self.barPlaceholder]];
    
    XCTAssert(io.inputs.count == 2);
    XCTAssert(io.outputs.count == 2);
    XCTAssert(io.placeholders.count == 2);
}

- (void)testReturnsIndexForName {
    TIOModelIO *io = [[TIOModelIO alloc] initWithInputInterfaces:@[self.fooIn, self.barIn] ouputInterfaces:@[self.fooOut, self.barOut] placeholderInterfaces:@[self.fooPlaceholder, self.barPlaceholder]];
    
    XCTAssert([io.inputs indexForName:@"foo"].integerValue == 0);
    XCTAssert([io.inputs indexForName:@"bar"].integerValue == 1);
    
    XCTAssert([io.outputs indexForName:@"foo"].integerValue == 0);
    XCTAssert([io.outputs indexForName:@"bar"].integerValue == 1);
    
    XCTAssert([io.placeholders indexForName:@"foo"].integerValue == 0);
    XCTAssert([io.placeholders indexForName:@"bar"].integerValue == 1);
}

- (void)testInputsFastEnumerator {
    TIOModelIO *io = [[TIOModelIO alloc] initWithInputInterfaces:@[self.fooIn, self.barIn] ouputInterfaces:@[self.fooOut, self.barOut] placeholderInterfaces:@[self.fooPlaceholder, self.barPlaceholder]];
    
    NSMutableArray *inputs = [[NSMutableArray alloc] init];
    
    for ( TIOLayerInterface *interface in io.inputs ) {
        [inputs addObject:interface];
    }
    
    XCTAssert([inputs isEqualToArray:io.inputs.all]);
}

- (void)testOutputsFastEnumeration {
    TIOModelIO *io = [[TIOModelIO alloc] initWithInputInterfaces:@[self.fooIn, self.barIn] ouputInterfaces:@[self.fooOut, self.barOut] placeholderInterfaces:@[self.fooPlaceholder, self.barPlaceholder]];

    NSMutableArray *outputs = [[NSMutableArray alloc] init];

    for ( TIOLayerInterface *interface in io.outputs ) {
        [outputs addObject:interface];
    }

    XCTAssert([outputs isEqualToArray:io.outputs.all]);

}

@end
