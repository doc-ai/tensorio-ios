//
//  TensorIOJSONParsingTests.m
//  TensorIO_Tests
//
//  Created by Philip Dow on 8/22/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
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

#import "TensorIO.h"

@interface TensorIOJSONParsingTests : XCTestCase

@end

@implementation TensorIOJSONParsingTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: - Pixel Normalization

// MARK: - Pixel Denormalization

// MARK: - Quantization

-(void)testDataQuantizerForDictReturnsNil {
    TIODataQuantizer quantizer = TIODataQuantizerForDict(@{});
    XCTAssertNil(quantizer);
}

// MARK: - Dequantization

- (void)testDataDequantizerForDictParsesZeroToOne {
    // Uniformly translates a range of values from [0,255] uint8_t to [0,1] float_t
    const float epsilon = 0.01;
    TIODataDequantizer dequantizer = TIODataDequantizerForDict(@{
        @"dequantize": @{
            @"standard": @"[0,1]"
        }
    });
    XCTAssertNotNil(dequantizer);
    XCTAssert(dequantizer(255) == 1);
    XCTAssert(dequantizer(0) == 0);
    XCTAssertEqualWithAccuracy(dequantizer(127), 0.5, epsilon);
}

- (void)testDataDequantizerForDictReturnsNil {
    TIODataDequantizer dequantizer = TIODataDequantizerForDict(@{});
    XCTAssertNil(dequantizer);
}

@end
