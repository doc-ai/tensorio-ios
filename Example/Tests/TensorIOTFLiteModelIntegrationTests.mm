//
//  TIOTFLiteModelTests.m
//  Net Runner ParserTests
//
//  Created by Philip Dow on 8/7/18.
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

#import <TensorIO/TensorIO-umbrella.h>

@interface TIOTFLiteModelTests : XCTestCase

@property NSString *modelsPath;

@end

@implementation TIOTFLiteModelTests

- (instancetype)init {
    return [super init];
}

- (void)setUp {
    self.modelsPath = [[NSBundle mainBundle] pathForResource:@"models-tests" ofType:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (TIOModelBundle*)bundleWithName:(NSString*)filename {
    NSString *path = [self.modelsPath stringByAppendingPathComponent:filename];
    return [[TIOModelBundle alloc] initWithPath:path];
}

- (id<TIOModel>)loadModelFromBundle:(nonnull TIOModelBundle*)bundle {
    
    id<TIOModel> model = (id<TIOModel>)[bundle newModel];
    NSError *modelError;
    
    if ( model == nil ) {
        NSLog(@"Unable to find and instantiate model with id %@", bundle.identifier);
        model = nil;
        return nil;
    }
    
    if ( ![model load:&modelError] ) {
        NSLog(@"Model does could not be loaded, id: %@, error: %@", bundle.identifier, modelError);
        model = nil;
        return nil;
    }
    
    return model;
}

// MARK: - Single Valued Tests

- (void)test1In1OutNumberModel {
    TIOModelBundle *bundle = [self bundleWithName:@"1_in_1_out_number_test.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 1);
    XCTAssert(model.outputs.count == 1);
    
    // Run the model on a number
    
    NSNumber *numericInput = @(2);
    NSDictionary *numericResults = (NSDictionary*)[model runOn:numericInput];
    
    XCTAssert(numericResults.count == 1);
    XCTAssert([numericResults[@"output"] isEqualToNumber:@(25)]);
    
    // Run the model on bytes
    
    float_t bytes[1] = {2};
    NSData *byteInput = [NSData dataWithBytes:bytes length:sizeof(float_t)*1];
    NSDictionary *byteResults = (NSDictionary*)[model runOn:byteInput];
    
    XCTAssert(byteResults.count == 1);
    XCTAssert([byteResults[@"output"] isEqualToNumber:@(25)]);
    
    // Run the model on a vector
    
    TIOVector *vectorInput = @[@(2)];
    NSDictionary *vectorResults = (NSDictionary*)[model runOn:vectorInput];
    
    XCTAssert(vectorResults.count == 1);
    XCTAssert([vectorResults[@"output"] isEqualToNumber:@(25)]);
}

// MARK: - Vector, Matrix, Tensor Tests

- (void)test1x1VectorsModel {
    TIOModelBundle *bundle = [self bundleWithName:@"1_in_1_out_vectors_test.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 1);
    XCTAssert(model.outputs.count == 1);
    
    // Expected output
    
    TIOVector *expectedOutput = @[@(2),@(2),@(4),@(4)];
    
    // Run the model on a vector
    
    TIOVector *vectorInput = @[@(1),@(2),@(3),@(4)];
    NSDictionary *vectorResults = (NSDictionary*)[model runOn:vectorInput];
    
    XCTAssert(vectorResults.count == 1);
    XCTAssert([vectorResults[@"output"] isEqualToArray:expectedOutput]);
    
    // Run the model on bytes
    
    float_t bytes[4] = {1,2,3,4};
    NSData *byteInput = [NSData dataWithBytes:bytes length:sizeof(float_t)*4];
    NSDictionary *byteResults = (NSDictionary*)[model runOn:byteInput];
    
    XCTAssert(byteResults.count == 1);
    XCTAssert([byteResults[@"output"] isEqualToArray:expectedOutput]);
}

- (void)test2x2VectorsModel {
    TIOModelBundle *bundle = [self bundleWithName:@"2_in_2_out_vectors_test.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 2);
    XCTAssert(model.outputs.count == 2);
    
    // Run model on number
    
    NSArray *vectorInputs = @[
        @[@1,  @2,  @3,  @4],
        @[@10, @20, @30, @40]
    ];
    NSDictionary *vectorResults = (NSDictionary*)[model runOn:vectorInputs];
    
    XCTAssert(vectorResults.count == 2);
    XCTAssert([vectorResults[@"output1"] isEqualToNumber:@(240)]);
    XCTAssert([vectorResults[@"output2"] isEqualToNumber:@(64)]);
    
    // With bytes
    
    float_t byteInputs1[4] = {1,2,3,4};
    float_t byteInputs2[4] = {10,20,30,40};
    
    NSArray *byteInputs = @[
        [NSData dataWithBytes:byteInputs1 length:4*sizeof(float_t)],
        [NSData dataWithBytes:byteInputs2 length:4*sizeof(float_t)],
    ];
    NSDictionary *byteResults = (NSDictionary*)[model runOn:byteInputs];
    
    XCTAssert(byteResults.count == 2);
    XCTAssert([byteResults[@"output1"] isEqualToNumber:@(240)]);
    XCTAssert([byteResults[@"output2"] isEqualToNumber:@(64)]);
}

- (void)test2x2MatricesModel {
    TIOModelBundle *bundle = [self bundleWithName:@"2_in_2_out_matrices_test.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 2);
    XCTAssert(model.outputs.count == 2);
    
    // Expected outputs
    
    TIOVector *expectedOutput1 = @[
        @(56),      @(72),      @(56),      @(72),
        @(5600),    @(7200),    @(5600),    @(7200),
        @(560000),  @(720000),  @(560000),  @(720000),
        @(56000000),@(72000000),@(56000000),@(72000000)
    ];
    TIOVector *expectedOutput2 = @[
        @(18),   @(18),   @(18),   @(18),
        @(180),  @(180),  @(180),  @(180),
        @(1800), @(1800), @(1800), @(1800),
        @(18000),@(18000),@(18000),@(18000)
    ];
    
    // Run model on numbers
    
    NSArray *matrixInput = @[
        @[
            @1,   @2,   @3,   @4,
            @10,  @20,  @30,  @40,
            @100, @200, @300, @400,
            @1000,@2000,@3000,@4000
        ],
        @[
            @5,   @6,   @7,   @8,
            @50,  @60,  @70,  @80,
            @500, @600, @700, @800,
            @5000,@6000,@7000,@8000
        ]
    ];
    NSDictionary *matrixResults = (NSDictionary*)[model runOn:matrixInput];
    
    XCTAssert(matrixResults.count == 2);
    XCTAssert([matrixResults[@"output1"] isEqualToArray:expectedOutput1]);
    XCTAssert([matrixResults[@"output2"] isEqualToArray:expectedOutput2]);
    
    // Byte input
    
    float_t matrixInput1[16] = {
        1,   2,   3,   4,
        10,  20,  30,  40,
        100, 200, 300, 400,
        1000,2000,3000,4000
    };
    float_t matrixInput2[16] = {
        5,   6,   7,   8,
        50,  60,  70,  80,
        500, 600, 700, 800,
        5000,6000,7000,8000
    };
    
    NSArray *byteInputs = @[
        [NSData dataWithBytes:matrixInput1 length:16*sizeof(float_t)],
        [NSData dataWithBytes:matrixInput2 length:16*sizeof(float_t)],
    ];
    NSDictionary *byteResults = (NSDictionary*)[model runOn:byteInputs];
    
    XCTAssert(byteResults.count == 2);
    XCTAssert([matrixResults[@"output1"] isEqualToArray:expectedOutput1]);
    XCTAssert([matrixResults[@"output2"] isEqualToArray:expectedOutput2]);
}

- (void)test3x3MatricesModel {
    TIOModelBundle *bundle = [self bundleWithName:@"1_in_1_out_tensors_test.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 1);
    XCTAssert(model.outputs.count == 1);
    
    // Expected outputs
    
    TIOVector *expectedOutput = @[
        @(2),  @(3),  @(4),  @(5),  @(6),  @(7),  @(8),  @(9),  @(10),
        @(12), @(22), @(32), @(42), @(52), @(62), @(72), @(82), @(92),
        @(103),@(203),@(303),@(403),@(503),@(603),@(703),@(803),@(903)
    ];
    
    // Run model on numbers
    
    TIOVector *vectorInput = @[
        @(1),  @(2),  @(3),  @(4),  @(5),  @(6),  @(7),  @(8),  @(9),
        @(10), @(20), @(30), @(40), @(50), @(60), @(70), @(80), @(90),
        @(100),@(200),@(300),@(400),@(500),@(600),@(700),@(800),@(900)
    ];
    
    NSDictionary *vectorResults = (NSDictionary*)[model runOn:vectorInput];
    
    XCTAssert(vectorResults.count == 1);
    XCTAssert([vectorResults[@"output"] isEqualToArray:expectedOutput]);
    
    // Run model on bytes
    
    float_t byteInput[27] = {
        1,  2,  3,  4,  5,  6,  7,  8,  9,
        10, 20, 30, 40, 50, 60, 70, 80, 90,
        100,200,300,400,500,600,700,800,900
    };
    NSData *byteData = [NSData dataWithBytes:byteInput length:sizeof(float_t)*27];
    
    NSDictionary *byteResults = (NSDictionary*)[model runOn:byteData];
    
    XCTAssert(byteResults.count == 1);
    XCTAssert([byteResults[@"output"] isEqualToArray:expectedOutput]);
}

// MARK: - Pixel Buffer Tests

- (void)testPixelBufferIdentityModel {
    self.continueAfterFailure = NO;
    
    TIOModelBundle *bundle = [self bundleWithName:@"1_in_1_out_pixelbuffer_identity_test.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 1);
    XCTAssert(model.outputs.count == 1);
    
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
    
    // Create a pixel buffer for those bytes (could blast bytes directly into pixel buffer)
    
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
        NSLog(@"Couldn't create pixel buffer");
    }
    
    // Copy bytes to pixel buffer
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(baseAddress, bytes, width * height * channels);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    // Run model on pixel buffer
    
    TIOPixelBuffer *pixelBufferWrapper = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    NSDictionary *output = (NSDictionary*)[model runOn:pixelBufferWrapper];
    
    // Capture output
    
    TIOPixelBuffer *outputPixelBufferWrapper = output[@"output"];
    CVPixelBufferRef outputPixelBuffer = outputPixelBufferWrapper.pixelBuffer;
    
    // Inspect pixel buffer bytes
    
    uint8_t espilon = 1;
    CVPixelBufferLockBaseAddress(outputPixelBuffer, kNilOptions);
    uint8_t *outAddr = (uint8_t *)CVPixelBufferGetBaseAddress(outputPixelBuffer);
    
    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = outAddr + (i * channels);
        
        XCTAssertEqualWithAccuracy(pixel[0], 255, espilon);
        XCTAssertEqualWithAccuracy(pixel[1], 255, espilon);
        XCTAssertEqualWithAccuracy(pixel[2], 0, espilon);
        XCTAssertEqualWithAccuracy(pixel[3], 0, espilon);
    }
    
    CVPixelBufferUnlockBaseAddress(outputPixelBuffer, kNilOptions);
    
    // Cleanup
    
    CVPixelBufferRelease(pixelBuffer);
    free(bytes);
}

- (void)testPixelBufferNormalizationTransformationModel {
    self.continueAfterFailure = NO;
    
    TIOModelBundle *bundle = [self bundleWithName:@"1_in_1_out_pixelbuffer_normalization_test.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 1);
    XCTAssert(model.outputs.count == 1);
    
    // Create ARGB bytes
    
    const int width = 224;
    const int height = 224;
    const int channels = 4;
    
    uint8_t *bytes = (uint8_t *)malloc(224*224*4*sizeof(uint8_t));
    
    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = bytes + (i * channels);
        
        pixel[0] = 255; // A
        pixel[1] = 0;   // R
        pixel[2] = 255; // G
        pixel[3] = 0;   // B
    }
    
    // Create a pixel buffer for those bytes (could blast bytes directly into pixel buffer)
    
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
        NSLog(@"Couldn't create pixel buffer");
    }
    
    // Copy bytes to pixel buffer
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(baseAddress, bytes, width * height * channels);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    // Run model on pixel buffer
    
    TIOPixelBuffer *pixelBufferWrapper = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    NSDictionary *output = (NSDictionary*)[model runOn:pixelBufferWrapper];
    
    // Capture output
    
    TIOPixelBuffer *outputPixelBufferWrapper = output[@"output"];
    CVPixelBufferRef outputPixelBuffer = outputPixelBufferWrapper.pixelBuffer;
    
    // Inspect pixel buffer bytes
    
    uint8_t espilon = 1;
    CVPixelBufferLockBaseAddress(outputPixelBuffer, kNilOptions);
    uint8_t *outAddr = (uint8_t *)CVPixelBufferGetBaseAddress(outputPixelBuffer);
    
    for ( int i = 0; i < width * height; i++) {
        uint8_t *pixel = outAddr + (i * channels);
        
        XCTAssertEqualWithAccuracy(pixel[0], 255, espilon);
        XCTAssertEqualWithAccuracy(pixel[1], 0, espilon);
        XCTAssertEqualWithAccuracy(pixel[2], 255, espilon);
        XCTAssertEqualWithAccuracy(pixel[3], 0, espilon);
    }
    
    CVPixelBufferUnlockBaseAddress(outputPixelBuffer, kNilOptions);
    
    // Cleanup
    
    CVPixelBufferRelease(pixelBuffer);
    free(bytes);
}

// MARK: - Tensor Flow Classification Models

- (void)testMobileNetClassificationModel {
    TIOModelBundle *bundle = [self bundleWithName:@"mobilenet_v2_1.4_224.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 1);
    XCTAssert(model.outputs.count == 1);
    
    // Prepare image input
    
    UIImage *image = [UIImage imageNamed:@"example-image"];
    TIOPixelBuffer *imageFeature = [[TIOPixelBuffer alloc] initWithPixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    // Run the model directly on the pixel buffer
    
    NSDictionary *imageResults = (NSDictionary*)[model runOn:imageFeature];
    NSDictionary *top5 = [imageResults[@"classification"] topN:5 threshold:0.1];
    
    XCTAssert(top5.count == 1);
    XCTAssert([top5.allKeys containsObject:@"rocking chair"]);
    
    for ( NSNumber *value in top5.allValues ) {
        XCTAssert(value.floatValue >= 0.0 && value.floatValue <= 1.0);
    }
    
    // Run the model on a named pixel buffer
    
    imageResults = (NSDictionary*)[model runOn:@{ @"image": imageFeature }];
    top5 = [imageResults[@"classification"] topN:5 threshold:0.1];
    
    XCTAssert(top5.count == 1);
    XCTAssert([top5.allKeys containsObject:@"rocking chair"]);
    
    for ( NSNumber *value in top5.allValues ) {
        XCTAssert(value.floatValue >= 0.0 && value.floatValue <= 1.0);
    }
}

- (void)testMobileNetClassificationModelPreprocessing {
    TIOModelBundle *bundle = [self bundleWithName:@"mobilenet_v2_1.4_224.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 1);
    XCTAssert(model.outputs.count == 1);
    
    // Prepare image input
    
    UIImage *image = [UIImage imageNamed:@"example-image"];
    TIOPixelBufferLayerDescription *description = (TIOPixelBufferLayerDescription*)[model descriptionOfInputAtIndex:0];
    TIOVisionPipeline *pipeline = [[TIOVisionPipeline alloc] initWithTIOPixelBufferDescription:description];
    CVPixelBufferRef pixelBuffer = [pipeline transform:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];
    TIOPixelBuffer *imageFeature = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    // Run the model directly on the preprocessed pixel buffer
    
    NSDictionary *imageResults = (NSDictionary*)[model runOn:imageFeature];
    NSDictionary *top5 = [imageResults[@"classification"] topN:5 threshold:0.1];
    
    XCTAssert(top5.count == 1);
    XCTAssert([top5.allKeys containsObject:@"rocking chair"]);
    
    for ( NSNumber *value in top5.allValues ) {
        XCTAssert(value.floatValue >= 0.0 && value.floatValue <= 1.0);
    }
    
    // Run the model on a named pixel buffer
    
    imageResults = (NSDictionary*)[model runOn:@{ @"image": imageFeature }];
    top5 = [imageResults[@"classification"] topN:5 threshold:0.1];
    
    XCTAssert(top5.count == 1);
    XCTAssert([top5.allKeys containsObject:@"rocking chair"]);
    
    for ( NSNumber *value in top5.allValues ) {
        XCTAssert(value.floatValue >= 0.0 && value.floatValue <= 1.0);
    }
}

- (void)testQuantizedMobileNetClassificationModel {
    TIOModelBundle *bundle = [self bundleWithName:@"mobilenet_v1_1.0_224_quant.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    // Ensure inputs and outputs return correct count
    
    XCTAssert(model.inputs.count == 1);
    XCTAssert(model.outputs.count == 1);
    
    // Prepare image input
    
    UIImage *image = [UIImage imageNamed:@"example-image"];
    TIOPixelBuffer *imageFeature = [[TIOPixelBuffer alloc] initWithPixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    // Run the model directly on the pixel buffer
    
    NSDictionary *imageResults = (NSDictionary*)[model runOn:imageFeature];
    NSDictionary *top5 = [imageResults[@"classification"] topN:5 threshold:0.1];
    
    XCTAssert(top5.count == 1);
    XCTAssert([top5.allKeys containsObject:@"rocking chair"]);
    
    for ( NSNumber *value in top5.allValues ) {
        XCTAssert(value.floatValue >= 0.0 && value.floatValue <= 1.0);
    }
    
    // Run the model on a named pixel buffer
    
    imageResults = (NSDictionary*)[model runOn:@{ @"image": imageFeature }];
    top5 = [imageResults[@"classification"] topN:5 threshold:0.1];
    
    XCTAssert(top5.count == 1);
    XCTAssert([top5.allKeys containsObject:@"rocking chair"]);
    
    for ( NSNumber *value in top5.allValues ) {
        XCTAssert(value.floatValue >= 0.0 && value.floatValue <= 1.0);
    }
}

// MARK: - Placeholder Model

- (void)testPlaceholderModel {
    TIOModelBundle *bundle = [self bundleWithName:@"placeholder.tfbundle"];
    id<TIOModel> model = [self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    XCTAssert([model isKindOfClass:TIOPlaceholderModel.class]);
}

@end
