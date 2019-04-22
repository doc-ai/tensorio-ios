//
//  TensorIOModelBundleValidatorTests.m
//  TensorIO_Tests
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

@interface TensorIOModelBundleValidatorTests : XCTestCase

@property NSString *modelsPath;
@property TIOModelBundleValidator *modelValidator;

@property NSDictionary *basicProperties;
@property NSDictionary *basicInput;
@property NSDictionary *basicOutput;

@end

@implementation TensorIOModelBundleValidatorTests

- (void)setUp {
    self.modelValidator = [[TIOModelBundleValidator alloc] initWithModelBundleAtPath:@""];
    self.modelsPath = [[NSBundle mainBundle] pathForResource:@"models-tests" ofType:nil];
    self.basicProperties = @{
        @"name": @"",
        @"details": @"",
        @"id": @"",
        @"version": @"",
        @"author": @"",
        @"license": @"",
        @"model": @{ },
        @"inputs": @[
            @{ }
        ],
        @"outputs": @[
            @{ }
        ]
    };
    self.basicInput = @{
        @"name": @"",
        @"type": @"",
        @"shape": @[@(1)]
    };
    self.basicOutput = @{
        @"name": @"",
        @"type": @"",
        @"shape": @[@(1)]
    };
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

/**
 * Creates a validator from a model bundle at filename
 */

- (TIOModelBundleValidator*)validatorForFilename:(NSString*)filename {
    NSString *path = [self.modelsPath stringByAppendingPathComponent:filename];
    TIOModelBundleValidator *validator = [[TIOModelBundleValidator alloc] initWithModelBundleAtPath:path];
    return validator;
}

// MARK: - Path and Bundle Validation

- (void)testBundleAtInvalidPathDoesNotValidate {
    // it should not validate
    
    NSError *error;
    TIOModelBundleValidator *validator = [self validatorForFilename:@"qwerty.tiobundle"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutTIOBundleExtensionDoesNotValidate {
    // it should not validate
    
    NSError *error;
    TIOModelBundleValidator *validator = [self validatorForFilename:@"invalid-model-ext"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutJSONDoesNotValidate {
    // it should not validate
    
    NSError *error;
    TIOModelBundleValidator *validator = [self validatorForFilename:@"invalid-model-no-json.tiobundle"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithBadJSONDoesNotValidate {
    // it should not validate is model.json is invalid json
    
    NSError *error;
    TIOModelBundleValidator *validator = [self validatorForFilename:@"invalid-model-bad-json.tiobundle"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

// MARK: - Basic Property Validation

- (void)testBundleWithoutNameDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    [properties removeObjectForKey:@"name"];
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutDetailsDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    [properties removeObjectForKey:@"details"];
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutIDDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    [properties removeObjectForKey:@"id"];
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutVersionDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    [properties removeObjectForKey:@"version"];
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutAuthorDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    [properties removeObjectForKey:@"author"];
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutLicenseDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    [properties removeObjectForKey:@"license"];
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutModelDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    [properties removeObjectForKey:@"model"];
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutInputsDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    [properties removeObjectForKey:@"inputs"];
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutOutputsDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    [properties removeObjectForKey:@"outputs"];
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithValidPropertiesValidates {
    NSError *error;
    NSMutableDictionary *properties = self.basicProperties.mutableCopy;
    
    BOOL valid = [self.modelValidator validateBundleProperties:properties error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

// MARK: - Model Properties Validation

- (void)testModelPropertiesValidates {
    
    NSDictionary *properties;
    NSError *error;
    BOOL valid;
    
    // it should not validate if model properties is empty
    
    properties = @{};
    error = nil;
    
    valid = [self.modelValidator validateModelProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate if model properties has extraneous keys
    
    properties = @{
        @"file": @"models.json",
        @"quantized": @(YES),
        @"foo": @""
    };
    error = nil;
    
    valid = [self.modelValidator validateModelProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate if file is not a string
    
    properties = @{
        @"file": @(0),
        @"quantized": @(YES),
        @"foo": @""
    };
    error = nil;
    
    valid = [self.modelValidator validateModelProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate if quantized is not a bool
    
    properties = @{
        @"file": @"model.json",
        @"quantized": @"",
    };
    error = nil;
    
    valid = [self.modelValidator validateModelProperties:properties error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    properties = @{
        @"file": @"model.json",
        @"quantized": @(YES)
    };
    error = nil;
    
    valid = [self.modelValidator validateModelProperties:properties error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    properties = @{
        @"file": @"model.json",
        @"quantized": @(YES),
        @"type": @""
    };
    error = nil;
    
    valid = [self.modelValidator validateModelProperties:properties error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

// MARK: - Assets Validation

- (void)testAnIncorrectlyNamedModelFileDoesNotValidate {
    // it should not validate if the model.file does not exist
    
    TIOModelBundleValidator *validator = [self validatorForFilename:@"invalid-model-incorrect-model-file.tiobundle"];
    NSError *error;
    
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testAnIncorrectNamedLabelsFileDoesNotValidate {
    // it should not validate if a labels file does not exist
    
    TIOModelBundleValidator *validator = [self validatorForFilename:@"invalid-model-incorrect-labels-file.tiobundle"];
    NSError *error;
    
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

// MARK: - Inputs Validation

- (void)testZeroInputsDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSArray *inputs = @[];
    
    BOOL valid = [self.modelValidator validateInputs:inputs error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testInputWithoutNameDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    [input removeObjectForKey:@"name"];
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testInputWithoutShapeDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    [input removeObjectForKey:@"shape"];
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testInputWithoutTypeDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    [input removeObjectForKey:@"type"];
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testInputShapeMustBeArrayToValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"shape"] = @{};
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"shape"] = @(0);
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"shape"] = @"";
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input[@"shape"] = @[@(1)];
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputShapeMustHaveOneOrMoreEntriesToValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"shape"] = @[];
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    input[@"shape"] = @[@(1)];
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputShapeMustHaveNumericEntriesToValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"shape"] = @[@""];
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"shape"] = @[@{}];
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"shape"] = @[@[]];
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input[@"shape"] = @[@(1)];
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeMustBeArrayOrImageToValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"";
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"foo";
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"array";
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeArrayHasCorrectKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"foo"] = @"";
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"quantize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
     // it should validate
    
    input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeArrayQuantizeHasNoUnusedKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"quantize"] = @{
        @"foo": @""
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testInputTypeArrayQuantizeHasEitherStandardOrScaleAndBiasKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"quantize"] = @{};
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"quantize"] = @{
        @"standard": @"[0,1]",
        @"scale": @(1),
        @"bias": @(0)
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
     // it should not validate
    
    input[@"quantize"] = @{
        @"standard": @"[0,1]",
        @"scale": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"quantize"] = @{
        @"scale": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"quantize"] = @{
        @"bias": @(0)
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
     // it should validate
    
    input[@"quantize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    input[@"quantize"] = @{
        @"scale": @(1),
        @"bias": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeArrayQuantizeStandardIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"quantize"] = @{
        @"standard": @"foo"
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input[@"quantize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    input[@"quantize"] = @{
        @"standard": @"[-1,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeArrayQuantizeScaleAndBiasAreValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"quantize"] = @{
        @"scale": @"",
        @"bias": @(0)
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"quantize"] = @{
        @"scale": @(1),
        @"bias": @""
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input[@"quantize"] = @{
        @"scale": @(1),
        @"bias": @(0)
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeArrayDataTypeFieldIsValid {
    // it should validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"dtype"] = @"uint8";
    
    error = nil;
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

// TODO: backend specific dtype validation https://github.com/doc-ai/tensorio-ios/issues/44

- (void)testInputTypeArraySupportedDataTypesAreValid {
    // it should validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"dtype"] = @"uint8";
    
    error = nil;
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    input[@"dtype"] = @"float32";
    
    error = nil;
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    input[@"dtype"] = @"int32";
    
    error = nil;
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    input[@"dtype"] = @"int64";
    
    error = nil;
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeArrayUnsupportedDataTypesAreInvalid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"array";
    input[@"dtype"] = @"int8"; // invalid
    
    error = nil;
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testInputTypeImageHasCorrectKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"foo"] = @"";
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
     // it should validate
    
    input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeImageFormatIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"format"] = @"foo";
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"format"] = @(1);
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input[@"format"] = @"RGB";
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    input[@"format"] = @"BGR";
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeImageNormalizeHasNoUnusedKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"normalize"] = @{
        @"foo": @""
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testInputTypeImageNormalizeHasEitherStandardOrScaleAndBiasKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{};
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"normalize"] = @{
        @"standard": @"[0,1]",
        @"scale": @(1),
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
     // it should not validate
    
    input[@"normalize"] = @{
        @"standard": @"[0,1]",
        @"scale": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"normalize"] = @{
        @"scale": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input[@"normalize"] = @{
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
     // it should validate
    
    input[@"normalize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    input[@"normalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeImageNormalizeStandardIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"standard": @"foo"
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"standard": @"[-1,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeImageDenormalizeScaleIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"scale": @"",
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeImageDenormalizeBiasIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"scale": @(1),
        @"bias": @(0)
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"scale": @(1),
        @"bias": @{}
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @"",
            @"g": @"",
            @"b": @""
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    input = self.basicInput.mutableCopy;
    input[@"type"] = @"image";
    input[@"format"] = @"RGB";
    input[@"normalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testInputTypeImageDataTypeFieldIsNotValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *input = self.basicInput.mutableCopy;
    
    input[@"type"] = @"image";
    input[@"dtype"] = @"uint8"; // invalid
    input[@"format"] = @"RGB";
    
    error = nil;
    BOOL valid = [self.modelValidator validateInputs:@[input] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

// MARK: - Outputs Validation

- (void)testZeroOutputsDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSArray *outputs = @[];
    
    BOOL valid = [self.modelValidator validateOutputs:outputs error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testOutputWithoutNameDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    [output removeObjectForKey:@"name"];
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testOutputWithoutShapeDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    [output removeObjectForKey:@"shape"];
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testOutputWithoutTypeDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    [output removeObjectForKey:@"type"];
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testOutputShapeMustBeArrayToValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"shape"] = @{};
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"shape"] = @(0);
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"shape"] = @"";
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output[@"shape"] = @[@(1)];
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputshapeMustHaveOneOrMoreEntriesToValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"shape"] = @[];
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    output[@"shape"] = @[@(1)];
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputshapeMustHaveNumericEntriesToValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"shape"] = @[@""];
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"shape"] = @[@{}];
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"shape"] = @[@[]];
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output[@"shape"] = @[@(1)];
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeMustBeArrayOrImageToValidate {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"";
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output = self.basicOutput.mutableCopy;
    output[@"type"] = @"foo";
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output = self.basicOutput.mutableCopy;
    output[@"type"] = @"image";
    output[@"format"] = @"RGB";
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    output = self.basicOutput.mutableCopy;
    output[@"type"] = @"array";
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeArrayHasCorrectKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"foo"] = @"";
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"labels"] = @"labels.txt";
    output[@"dequantize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
     // it should validate
    
    output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeArrayDequantizeHasNoUnusedKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"quantize"] = @{
        @"foo": @""
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testOutputTypeArrayDequantizeHasEitherStandardOrScaleAndBiasKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"dequantize"] = @{};
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"dequantize"] = @{
        @"standard": @"[0,1]",
        @"scale": @(1),
        @"bias": @(0)
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
     // it should not validate
    
    output[@"dequantize"] = @{
        @"standard": @"[0,1]",
        @"scale": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"dequantize"] = @{
        @"scale": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"dequantize"] = @{
        @"bias": @(0)
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
     // it should validate
    
    output[@"dequantize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    output[@"dequantize"] = @{
        @"scale": @(1),
        @"bias": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeArrayDequantizeStandardIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"dequantize"] = @{
        @"standard": @"foo"
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output[@"dequantize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    output[@"dequantize"] = @{
        @"standard": @"[-1,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeArrayDequantizeScaleAndBiasAreValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"dequantize"] = @{
        @"scale": @"",
        @"bias": @(0)
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"dequantize"] = @{
        @"scale": @(1),
        @"bias": @""
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output[@"dequantize"] = @{
        @"scale": @(1),
        @"bias": @(0)
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeArrayDataTypeFieldIsValid {
    // it should validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicInput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"dtype"] = @"uint8";
    
    error = nil;
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

// TODO: backend specific dtype validation https://github.com/doc-ai/tensorio-ios/issues/44

- (void)testOutputTypeArraySupportedDataTypesAreValid {
    // it should validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"dtype"] = @"uint8";
    
    error = nil;
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    output[@"dtype"] = @"float32";
    
    error = nil;
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    output[@"dtype"] = @"int32";
    
    error = nil;
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    output[@"dtype"] = @"int64";
    
    error = nil;
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeArrayUnsupportedDataTypesAreInvalid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"array";
    output[@"dtype"] = @"int8"; // invalid
    
    error = nil;
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testOutputTypeImageHasCorrectKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"image";
    output[@"format"] = @"RGB";
    output[@"foo"] = @"";
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"image";
    output[@"format"] = @"RGB";
    output[@"denormalize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
     // it should validate
    
    output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"image";
    output[@"format"] = @"RGB";
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeImageFormatIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"image";
    output[@"format"] = @"foo";
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"format"] = @(1);
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output[@"format"] = @"RGB";
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    output[@"format"] = @"BGR";
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeImageDenormalizeHasNoUnusedKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"image";
    output[@"normalize"] = @{
        @"foo": @""
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testOutputTypeImageDenormalizeHasEitherStandardOrScaleAndBiasKeys {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"image";
    output[@"format"] = @"RGB";
    output[@"denormalize"] = @{};
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"denormalize"] = @{
        @"standard": @"[0,1]",
        @"scale": @(1),
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
     // it should not validate
    
    output[@"denormalize"] = @{
        @"standard": @"[0,1]",
        @"scale": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"denormalize"] = @{
        @"scale": @(1)
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"denormalize"] = @{
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
     // it should validate
    
    output[@"denormalize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    output[@"denormalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeImageDenormalizeStandardIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"image";
    output[@"format"] = @"RGB";
    output[@"denormalize"] = @{
        @"standard": @"foo"
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output[@"denormalize"] = @{
        @"standard": @"[0,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    output[@"denormalize"] = @{
        @"standard": @"[-1,1]"
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeImageDenormalizeScaleIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"image";
    output[@"format"] = @"RGB";
    output[@"denormalize"] = @{
        @"scale": @"",
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output[@"denormalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeImageDenormalizeBiasIsValid {
    // it should not validate
    
    NSError *error;
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    
    output[@"type"] = @"image";
    output[@"format"] = @"RGB";
    output[@"denormalize"] = @{
        @"scale": @(1),
        @"bias": @(0)
    };
    error = nil;
    
    BOOL valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"denormalize"] = @{
        @"scale": @(1),
        @"bias": @{}
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"denormalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should not validate
    
    output[@"denormalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @"",
            @"g": @"",
            @"b": @""
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
    
    // it should validate
    
    output[@"denormalize"] = @{
        @"scale": @(1),
        @"bias": @{
            @"r": @(0),
            @"g": @(0),
            @"b": @(0)
        }
    };
    error = nil;
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testOutputTypeImageDataTypeFieldIsNotValid {
    // it should not validate
    
    NSMutableDictionary *output = self.basicOutput.mutableCopy;
    NSError *error = nil;
    BOOL valid;
    
    output[@"type"] = @"image";
    output[@"dtype"] = @"uint8"; // invalid
    output[@"format"] = @"RGB";
    
    valid = [self.modelValidator validateOutputs:@[output] error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

// MARK: - Custom Validation

- (void)testInvalidCustomValidationDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSDictionary *properties = self.basicProperties;
    BOOL (^block)(NSString *path, NSDictionary *JSON, NSError **error) = ^BOOL(NSString *path, NSDictionary *JSON, NSError **error) {
        return NO;
    };
    
    BOOL valid = [self.modelValidator validateCustomValidator:properties validator:block error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNil(error);
}

- (void)testInvalidCustomValidationReturnsError {
    // it should return an error
    
    NSError *error;
    NSError *blockError = [NSError errorWithDomain:@"" code:0 userInfo:nil];
    NSDictionary *properties = self.basicProperties;
    BOOL (^block)(NSString *path, NSDictionary *JSON, NSError **error) = ^BOOL(NSString *path, NSDictionary *JSON, NSError **error) {
        *error = blockError;
        return NO;
    };
    
    BOOL valid = [self.modelValidator validateCustomValidator:properties validator:block error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertEqualObjects(error, blockError);
}

- (void)testValidCustomValidatorValidates {
    // it should validate
    
    NSError *error;
    NSDictionary *properties = self.basicProperties;
    BOOL (^block)(NSString *path, NSDictionary *JSON, NSError **error) = ^BOOL(NSString *path, NSDictionary *JSON, NSError **error) {
        return YES;
    };
    
    BOOL valid = [self.modelValidator validateCustomValidator:properties validator:block error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

// MARK: - Valid Models

- (void)testValidModelsValidate {
    TIOModelBundleValidator *validator;
    NSError *error;
    BOOL valid;
    
    // it should validate
    
    error = nil;
    valid = NO;
    
    validator = [self validatorForFilename:@"1_in_1_out_number_test.tiobundle"];
    valid = [validator validate:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    error = nil;
    valid = NO;
    
    validator = [self validatorForFilename:@"2_in_2_out_matrices_test.tiobundle"];
    valid = [validator validate:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    error = nil;
    valid = NO;
    
    validator = [self validatorForFilename:@"mobilenet_v2_1.4_224.tiobundle"];
    valid = [validator validate:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

//MARK: - Placeholder Models

- (void)testPlaceholderModelValidates {
    TIOModelBundleValidator *validator;
    NSError *error;
    BOOL valid;
    
    // it should validate
    
    error = nil;
    valid = NO;
    
    validator = [self validatorForFilename:@"placeholder.tiobundle"];
    valid = [validator validate:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

@end
