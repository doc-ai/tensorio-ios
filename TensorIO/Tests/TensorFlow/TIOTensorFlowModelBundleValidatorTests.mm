//
//  TIOTensorFlowModelBundleValidatorTests.m
//  TensorFlowExampleTests
//
//  Created by Phil Dow on 5/1/19.
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

@interface TIOTensorFlowModelBundleValidatorTests : XCTestCase

@property NSString *modelsPath;

@end

@implementation TIOTensorFlowModelBundleValidatorTests

- (void)setUp {
    self.modelsPath = [[NSBundle mainBundle] pathForResource:@"models-tests" ofType:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

/**
 * Creates a validator from a model bundle at filename
 */

- (TIOModelBundleValidator *)validatorForFilename:(NSString *)filename {
    NSString *path = [self.modelsPath stringByAppendingPathComponent:filename];
    TIOModelBundleValidator *validator = [[TIOModelBundleValidator alloc] initWithModelBundleAtPath:path];
    return validator;
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
    
    validator = [self validatorForFilename:@"cats-vs-dogs-predict.tiobundle"];
    valid = [validator validate:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
    
    // it should validate
    
    error = nil;
    valid = NO;
    
    validator = [self validatorForFilename:@"cats-vs-dogs-train.tiobundle"];
    valid = [validator validate:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testModelWithoutBackendValidates {
    // it should validate
    
    NSError *error;
    TIOModelBundleValidator *validator = [self validatorForFilename:@"no-backend.tiobundle"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

- (void)testModelWithoutModesValidates {
    // it should validate
    
    NSError *error;
    TIOModelBundleValidator *validator = [self validatorForFilename:@"no-modes.tiobundle"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

// MARK: - Placeholder Models

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
