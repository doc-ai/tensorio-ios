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

#import "TensorIO.h"

@interface TensorIOModelBundleValidatorTests : XCTestCase

@property NSString *modelsPath;
@property NSDictionary *basicProperties;
@property TIOModelBundleValidator *modelValidator;

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
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (TIOModelBundleValidator*)validatorForFilename:(NSString*)filename {
    NSString *path = [self.modelsPath stringByAppendingPathComponent:filename];
    TIOModelBundleValidator *validator = [[TIOModelBundleValidator alloc] initWithModelBundleAtPath:path];
    return validator;
}

// MARK: -

- (void)testBundleAtInvalidPathDoesNotValidate {
    // it should not validate
    
    NSError *error;
    TIOModelBundleValidator *validator = [self validatorForFilename:@"qwerty.tfbundle"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutTFBundleExtensionDoesNotValidate {
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
    TIOModelBundleValidator *validator = [self validatorForFilename:@"invalid-model-no-json.tfbundle"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

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

@end
