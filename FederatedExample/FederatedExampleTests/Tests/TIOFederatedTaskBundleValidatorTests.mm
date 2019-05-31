//
//  TIOFederatedTaskBundleValidatorTests.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/21/19.
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

@interface TIOFederatedTaskBundleValidatorTests : XCTestCase

@property NSString *tasksPath;

@end

@implementation TIOFederatedTaskBundleValidatorTests

- (void)setUp {
    self.tasksPath = [[NSBundle mainBundle] pathForResource:@"task-tests" ofType:nil];
}

- (void)tearDown { }

/**
 * Creates a validator from a task bundle at filename
 */

- (TIOFederatedTaskBundleValidator*)validatorForFilename:(NSString*)filename {
    NSString *path = [self.tasksPath stringByAppendingPathComponent:filename];
    TIOFederatedTaskBundleValidator *validator = [[TIOFederatedTaskBundleValidator alloc] initWithModelBundleAtPath:path];
    return validator;
}

// MARK: - Path and Bundle Validation

- (void)testBundleAtInvalidPathDoesNotValidate {
    // it should not validate
    
    NSError *error;
    TIOFederatedTaskBundleValidator *validator = [self validatorForFilename:@"qwerty.tiobundle"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutTIOTaskExtensionDoesNotValidate {
    // it should not validate
    
    NSError *error;
    TIOFederatedTaskBundleValidator *validator = [self validatorForFilename:@"invalid-task-ext"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithoutJSONDoesNotValidate {
    // it should not validate
    
    NSError *error;
    TIOFederatedTaskBundleValidator *validator = [self validatorForFilename:@"invalid-task-no-json.tiotask"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testBundleWithBadJSONDoesNotValidate {
    // it should not validate is task.json is invalid json
    
    NSError *error;
    TIOFederatedTaskBundleValidator *validator = [self validatorForFilename:@"invalid-task-bad-json.tiotask"];
    BOOL valid = [validator validate:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

// MARK: - Custom Validation

- (void)testInvalidCustomValidationDoesNotValidate {
    // it should not validate
    
    NSError *error;
    NSDictionary *JSON = @{};
    BOOL (^block)(NSString *path, NSDictionary *JSON, NSError **error) = ^BOOL(NSString *path, NSDictionary *JSON, NSError **error) {
        return NO;
    };
    
    TIOFederatedTaskBundleValidator *validator = [[TIOFederatedTaskBundleValidator alloc] initWithModelBundleAtPath:@""];
    BOOL valid = [validator validateCustomValidator:JSON validator:block error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertNil(error);
}

- (void)testInvalidCustomValidationReturnsError {
    // it should return an error
    
    NSError *error;
    NSError *blockError = [NSError errorWithDomain:@"" code:0 userInfo:nil];
    NSDictionary *JSON = @{};
    BOOL (^block)(NSString *path, NSDictionary *JSON, NSError **error) = ^BOOL(NSString *path, NSDictionary *JSON, NSError **error) {
        *error = blockError;
        return NO;
    };
    
    TIOFederatedTaskBundleValidator *validator = [[TIOFederatedTaskBundleValidator alloc] initWithModelBundleAtPath:@""];
    BOOL valid = [validator validateCustomValidator:JSON validator:block error:&error];
    
    XCTAssertFalse(valid);
    XCTAssertEqualObjects(error, blockError);
}

- (void)testValidCustomValidatorValidates {
    // it should validate
    
    NSError *error;
    NSDictionary *JSON = @{};
    BOOL (^block)(NSString *path, NSDictionary *JSON, NSError **error) = ^BOOL(NSString *path, NSDictionary *JSON, NSError **error) {
        return YES;
    };
    
    TIOFederatedTaskBundleValidator *validator = [[TIOFederatedTaskBundleValidator alloc] initWithModelBundleAtPath:@""];
    BOOL valid = [validator validateCustomValidator:JSON validator:block error:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

// MARK: - Valid Tasks

- (void)testCorrectBasicTaskValidates {
    // it should validate
    
    NSError *error;
    BOOL valid;
    
    TIOFederatedTaskBundleValidator *validator = [self validatorForFilename:@"basic.tiotask"];
    valid = [validator validate:&error];
    
    XCTAssertTrue(valid);
    XCTAssertNil(error);
}

@end
