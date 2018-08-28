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

- (void)testPixelNormalizerForDictionaryParsesStandardZeroToOne {
    // it should return a valid pixel normalizer
    // it should return no error
    
    NSError *error;
    NSDictionary *dict = @{
        @"normalize": @{
            @"standard": @"[0,1]"
        }
    };
    
    TIOPixelNormalizer normalizer = TIOPixelNormalizerForDictionary(dict, &error);
    float_t epsilon = 0.01;
    
    XCTAssertNil(error);
    XCTAssertEqualWithAccuracy(normalizer(0, 0), 0.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(0, 1), 0.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(0, 2), 0.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 0), 0.5, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 1), 0.5, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 2), 0.5, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 0), 1.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 1), 1.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 2), 1.0, epsilon);
}

- (void)testPixelNormalizerForDictionaryParsesStandardNegativeOneToOne {
    // it should return a valid pixel normalizer
    // it should return no error
    
    NSError *error;
    NSDictionary *dict = @{
        @"normalize": @{
            @"standard": @"[-1,1]"
        }
    };
    
    TIOPixelNormalizer normalizer = TIOPixelNormalizerForDictionary(dict, &error);
    float_t epsilon = 0.01;
    
    XCTAssertNil(error);
    XCTAssertEqualWithAccuracy(normalizer(0, 0), -1.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(0, 1), -1.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(0, 2), -1.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 0), 0.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 1), 0.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 2), 0.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 0), 1.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 1), 1.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 2), 1.0, epsilon);
}

- (void)testPixelNormalizerForDictionaryReturnsError {
    // it should return a nil pixel normalizer
    // it should return an error
    
    NSError *error;
    NSDictionary *dict = @{
        @"normalize": @{
            @"standard": @"[-10, 10]"
        }
    };
    
    TIOPixelNormalizer normalizer = TIOPixelNormalizerForDictionary(dict, &error);
    
    XCTAssertNotNil(error);
    XCTAssertNil(normalizer);
}

- (void)testPixelNormalizerForDictionaryParsesScaleAndSameBiases {
    // it should return a valid pixel normalizer
    // it should return no error
    
    NSError *error;
    NSDictionary *dict = @{
        @"normalize": @{
            @"scale": @(1.0/255.0),
            @"bias": @{
                @"r": @(0),
                @"g": @(0),
                @"b": @(0)
            }
        }
    };
    
    TIOPixelNormalizer normalizer = TIOPixelNormalizerForDictionary(dict, &error);
    float_t epsilon = 0.01;
    
    XCTAssertNil(error);
    XCTAssertEqualWithAccuracy(normalizer(0, 0), 0.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(0, 1), 0.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(0, 2), 0.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 0), 0.5, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 1), 0.5, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 2), 0.5, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 0), 1.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 1), 1.0, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 2), 1.0, epsilon);
}

- (void)testPixelNormalizerForDictionaryParsesScaleAndDifferenceBiases {
    // it should return a valid pixel normalizer
    // it should return no error
    
    NSError *error;
    NSDictionary *dict = @{
        @"normalize": @{
            @"scale": @(1.0/255.0),
            @"bias": @{
                @"r": @(0.1),
                @"g": @(0.2),
                @"b": @(0.3)
            }
        }
    };
    
    TIOPixelNormalizer normalizer = TIOPixelNormalizerForDictionary(dict, &error);
    float_t epsilon = 0.01;
    
    XCTAssertNil(error);
    XCTAssertEqualWithAccuracy(normalizer(0, 0), 0.0+0.1, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(0, 1), 0.0+0.2, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(0, 2), 0.0+0.3, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 0), 0.5+0.1, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 1), 0.5+0.2, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(127, 2), 0.5+0.3, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 0), 1.0+0.1, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 1), 1.0+0.2, epsilon);
    XCTAssertEqualWithAccuracy(normalizer(255, 2), 1.0+0.3, epsilon);
}

// MARK: - Pixel Denormalization

- (void)testPixelDenormalizerForDictionaryParsesStandardZeroToOne {
    // it should return a valid pixel normalizer
    // it should return no error
    
    NSError *error;
    NSDictionary *dict = @{
        @"denormalize": @{
            @"standard": @"[0,1]"
        }
    };
    
    TIOPixelDenormalizer denormalizer = TIOPixelDenormalizerForDictionary(dict, &error);
    uint8_t epsilon = 1;
    
    XCTAssertNil(error);
    XCTAssertEqualWithAccuracy(denormalizer(0.0, 0), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.0, 1), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.0, 2), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.5, 0), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.5, 1), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.5, 2), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0, 0), 255, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0, 1), 255, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0, 2), 255, epsilon);
}

- (void)testPixelDenormalizerForDictionaryParsesStandardNegativeOneToOne {
    // it should return a valid pixel normalizer
    // it should return no error
    
    NSError *error;
    NSDictionary *dict = @{
        @"denormalize": @{
            @"standard": @"[-1,1]"
        }
    };
    
    TIOPixelDenormalizer denormalizer = TIOPixelDenormalizerForDictionary(dict, &error);
    uint8_t epsilon = 1;
    
    XCTAssertNil(error);
    XCTAssertEqualWithAccuracy(denormalizer(-1.0, 0), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(-1.0, 1), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(-1.0, 2), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.0, 0), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.0, 1), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.0, 2), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0, 0), 255, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0, 1), 255, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0, 2), 255, epsilon);
}

- (void)testPixelDenormalizerForDictionaryReturnsError {
    // it should return a nil pixel normalizer
    // it should return an error
    
    NSError *error;
    NSDictionary *dict = @{
        @"denormalize": @{
            @"standard": @"[-10, 10]"
        }
    };
    
    TIOPixelDenormalizer denormalizer = TIOPixelDenormalizerForDictionary(dict, &error);
    
    XCTAssertNotNil(error);
    XCTAssertNil(denormalizer);
}

- (void)testPixelDenormalizerForDictionaryParsesScaleAndSameBiases {
    // it should return a valid pixel normalizer
    // it should return no error
    
    NSError *error;
    NSDictionary *dict = @{
        @"denormalize": @{
            @"scale": @(255.0),
            @"bias": @{
                @"r": @(0),
                @"g": @(0),
                @"b": @(0)
            }
        }
    };
    
    TIOPixelDenormalizer denormalizer = TIOPixelDenormalizerForDictionary(dict, &error);
    uint8_t epsilon = 1;
    
    XCTAssertNil(error);
    XCTAssertEqualWithAccuracy(denormalizer(0.0, 0), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.0, 1), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.0, 2), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.5, 0), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.5, 1), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.5, 2), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0, 0), 255, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0, 1), 255, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0, 2), 255, epsilon);
}

- (void)testPixelDenormalizerForDictionaryParsesScaleAndDifferenceBiases {
    // it should return a valid pixel normalizer
    // it should return no error
    
    NSError *error;
    NSDictionary *dict = @{
        @"denormalize": @{
            @"scale": @(255.0),
            @"bias": @{
                @"r": @(-0.1),
                @"g": @(-0.2),
                @"b": @(-0.3)
            }
        }
    };
    
    TIOPixelDenormalizer denormalizer = TIOPixelDenormalizerForDictionary(dict, &error);
    uint8_t epsilon = 1;
    
    XCTAssertNil(error);
    XCTAssertEqualWithAccuracy(denormalizer(0.0+0.1, 0), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.0+0.2, 1), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.0+0.3, 2), 0, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.5+0.1, 0), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.5+0.2, 1), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(0.5+0.3, 2), 127, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0+0.1, 0), 255, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0+0.2, 1), 255, epsilon);
    XCTAssertEqualWithAccuracy(denormalizer(1.0+0.3, 2), 255, epsilon);
}

// MARK: - Quantization

- (void)testDataQuantizerForDictParsesStandardZeroToOne {
    // it should return a valid quantizer and no error
    
    const uint8_t epsilon = 1;
    NSError *error;
    TIODataQuantizer quantizer = TIODataQuantizerForDict(@{
        @"quantize": @{
            @"standard": @"[0,1]"
        }
    }, &error);
    
    XCTAssertNil(error);
    XCTAssert(quantizer(0) == 0);
    XCTAssert(quantizer(1) == 255);
    XCTAssertEqualWithAccuracy(quantizer(0.5), 127, epsilon);
}

- (void)testDataQuantizerForDictParsesStandardNegativeOneToOne {
    // it should return a valid quantizer and no error
    
    const float epsilon = 1;
    NSError *error;
    TIODataQuantizer quantizer = TIODataQuantizerForDict(@{
        @"quantize": @{
            @"standard": @"[-1,1]"
        }
    }, &error);
    
    XCTAssertNil(error);
    XCTAssert(quantizer(-1) == 0);
    XCTAssert(quantizer(1) == 255);
    XCTAssertEqualWithAccuracy(quantizer(0), 127, epsilon);
}

-(void)testDataQuantizerForDictParsesScaleAndBias {
    // it should return a valid quantizer and no error
    
    const uint8_t epsilon = 1;
    NSError *error;
    TIODataQuantizer quantizer = TIODataQuantizerForDict(@{
        @"quantize": @{
            @"scale": @(255.0),
            @"bias": @(0)
        }
    }, &error);
    
    XCTAssertNil(error);
    XCTAssert(quantizer(0) == 0);
    XCTAssert(quantizer(1) == 255);
    XCTAssertEqualWithAccuracy(quantizer(0.5), 127, epsilon);
}

- (void)testDataQuantizerForDictReturnsError {
    NSError *error;
    TIODataQuantizer quantizer = TIODataQuantizerForDict(@{
        @"quantize": @{}
    }, &error);
    
    XCTAssertNil(quantizer);
    XCTAssertNotNil(error);
}

// MARK: - Dequantization

- (void)testDataDequantizerForDictParsesStandardZeroToOne {
    // it should return a valid dequantizer and no error
    
    const float epsilon = 0.01;
    NSError *error;
    TIODataDequantizer dequantizer = TIODataDequantizerForDict(@{
        @"dequantize": @{
            @"standard": @"[0,1]"
        }
    }, &error);
    
    XCTAssertNil(error);
    XCTAssert(dequantizer(0) == 0);
    XCTAssert(dequantizer(255) == 1);
    XCTAssertEqualWithAccuracy(dequantizer(127), 0.5, epsilon);
}

- (void)testDataDequantizerForDictParsesStandardNegativeOneToOne {
    // it should return a valid dequantizer and no error
    
    const float epsilon = 0.01;
    NSError *error;
    TIODataDequantizer dequantizer = TIODataDequantizerForDict(@{
        @"dequantize": @{
            @"standard": @"[-1,1]"
        }
    }, &error);
    
    XCTAssertNil(error);
    XCTAssert(dequantizer(0) == -1);
    XCTAssert(dequantizer(255) == 1);
    XCTAssertEqualWithAccuracy(dequantizer(127), 0, epsilon);
}

- (void)testDataDequantizerForDictParsesScaleAndBias {
    const float epsilon = 0.01;
    NSError *error;
    TIODataDequantizer dequantizer = TIODataDequantizerForDict(@{
        @"dequantize": @{
            @"scale": @(1.0/255.0),
            @"bias": @(0)
        }
    }, &error);
    
    XCTAssertNil(error);
    XCTAssert(dequantizer(0) == 0);
    XCTAssert(dequantizer(255) == 1);
    XCTAssertEqualWithAccuracy(dequantizer(127), 0.5, epsilon);
}

- (void)testDataDequantizerForDictReturnsError {
    // it should return a nil quantizer and an error
    
    NSError *error;
    TIODataDequantizer dequantizer = TIODataDequantizerForDict(@{}, &error);
    XCTAssertNil(dequantizer);
    XCTAssertNotNil(error);
}

// MARK: - Pixel Format

- (void)testPixelFormatForStringParsesRGB {
    // it should parse RGB
    
    OSType pixelFormat = TIOPixelFormatForString(@"RGB");
    XCTAssertEqual(pixelFormat, kCVPixelFormatType_32ARGB);
}

- (void)testPixelFormatForStringParsesBGR {
    // it should parse BGR
    
    OSType pixelFormat = TIOPixelFormatForString(@"BGR");
    XCTAssertEqual(pixelFormat, kCVPixelFormatType_32BGRA);
}

- (void)testPixelFormatForStringReturnsInvalidForNilString {
    // it should return invalid
    
    OSType pixelFormat = TIOPixelFormatForString(nil);
    XCTAssertEqual(pixelFormat, TIOPixelFormatTypeInvalid);
}

- (void)testPixelFormatForStringReturnsInvalidForOtherString {
    // it should return invalid
    
    OSType pixelFormat = TIOPixelFormatForString(@"CMYK");
    XCTAssertEqual(pixelFormat, TIOPixelFormatTypeInvalid);
}

// MARK: - Image Volume

- (void)testImageVolumeForShapeReturnsInvalidForNilInput {
    // it should return invalid
    
    NSDictionary *dict = @{};
    NSArray<NSNumber*> *shape = dict[@"shape"];
    
    TIOImageVolume volume = TIOImageVolumeForShape(shape);
    XCTAssertTrue(TIOImageVolumesEqual(volume, kTIOImageVolumeInvalid));
}

- (void)testImageVolumeForShapeReturnsInvalidForVolumesGreaterThanThreeDimensions {
    // it should return invalid
    
    NSDictionary *dict = @{  @"shape": @[ @(224), @(224), @(3), @(1) ] };
    NSArray<NSNumber*> *shape = dict[@"shape"];
    
    TIOImageVolume volume = TIOImageVolumeForShape(shape);
    XCTAssertTrue(TIOImageVolumesEqual(volume, kTIOImageVolumeInvalid));
}

- (void)testImageVolumeForShapeParsesVolume {
    // it should return an image volume
    
    NSDictionary *dict = @{  @"shape": @[ @(224), @(224), @(3) ] };
    NSArray<NSNumber*> *shape = dict[@"shape"];
    TIOImageVolume expectedVolume = {
        .width = 224,
        .height = 224,
        .channels = 3
    };
    
    TIOImageVolume volume = TIOImageVolumeForShape(shape);
    XCTAssertTrue(TIOImageVolumesEqual(volume, expectedVolume));
}

@end
