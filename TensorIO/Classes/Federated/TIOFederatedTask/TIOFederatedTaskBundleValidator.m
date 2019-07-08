//
//  TIOFederatedTaskBundleValidator.m
//  TensorIO
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

#import "TIOFederatedTaskBundleValidator.h"
#import "TIOFederatedTaskBundle.h"

@import DSJSONSchemaValidation;

static NSString *TIOFederatedAssetBundle = @"Federated.bundle";

static NSError * TIOFTMalformedJSONError(void);
static NSError * TIOFTInvalidFilepathError(NSString * path);
static NSError * TIOFTInvalidExtensionError(NSString * path);
static NSError * TIOFTNoTaskJSONFileError(void);
static NSError * TIOFTTaskSchemaError(void);
static NSError * TIOFTTaskValidationError(void);

@implementation TIOFederatedTaskBundleValidator

- (instancetype)initWithModelBundleAtPath:(NSString *)path {
    if ((self=[super init])) {
        _path = path;
    }
    return self;
}

- (BOOL)validate:(NSError * _Nullable *)error {
    return [self validate:nil error:error];
}

- (BOOL)validate:(_Nullable TIOFederatedTaskBundleValidationBlock)customValidator error:(NSError * _Nullable *)error {
    NSFileManager *fm = NSFileManager.defaultManager;
    BOOL isDirectory;
    
    // Validate path
    
    if ( ![fm fileExistsAtPath:self.path isDirectory:&isDirectory] || !isDirectory ) {
        if (error) {
            *error = TIOFTInvalidFilepathError(self.path);
        }
        return NO;
    }
    
    // Validate bundle structure
    
    if ( ![self.path.pathExtension isEqualToString:TIOFederatedTaskBundleExtension] ) {
       if (error) {
            *error = TIOFTInvalidExtensionError(self.path);
        }
        return NO;
    }
    
    if ( ![fm fileExistsAtPath:self.JSONPath isDirectory:&isDirectory] || isDirectory ) {
        if (error) {
            *error = TIOFTNoTaskJSONFileError();
        }
        return NO;
    }
    
    // Validate if JSON can be read
    
    NSDictionary *JSON = [self loadJSON];
    
    if ( JSON == nil ) {
        if (error) {
            *error = TIOFTMalformedJSONError();
        }
        return NO;
    }
    
    // Validate JSON using schema
    
    NSError *schemaError = nil;
    DSJSONSchema *schema = [self JSONSchema:&schemaError];
    
    if (schemaError) {
        if (error) {
            *error = TIOFTTaskSchemaError();
        }
        NSLog(@"There was a problem loading the task schema, error: %@", schemaError);
        return NO;
    }
    
    NSError *validationError;
    [schema validateObject:JSON withError:&validationError];
    
    if (validationError) {
        if (error) {
            *error = TIOFTTaskValidationError();
        }
        NSLog(@"The task.json file failed validation, error: %@", validationError);
        return NO;
    }
    
    // Custom validator
    
    if ( customValidator != nil && ![self validateCustomValidator:JSON validator:customValidator error:error] ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateCustomValidator:(NSDictionary *)JSON validator:(TIOFederatedTaskBundleValidationBlock)customValidator error:(NSError * _Nullable *)error {
    return customValidator(self.path, JSON, error);
}

// MARK: - Utilities

- (NSString *)JSONPath {
    return [self.path stringByAppendingPathComponent:TIOTaskInfoFile];
}

- (NSDictionary *)loadJSON {
    NSString *path = self.JSONPath;
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSError *JSONError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];

    if ( JSON == nil ) {
        NSLog(@"Error reading json file at path %@, error %@", path, JSONError);
        return nil;
    }
    
    return JSON;
}

- (DSJSONSchema *)JSONSchema:(NSError * _Nullable *)error {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];
    NSURL *resourceURL = [frameworkBundle.resourceURL URLByAppendingPathComponent:TIOFederatedAssetBundle];
    NSBundle *resourceBundle = [NSBundle bundleWithURL:resourceURL];
    
    NSURL *schemaURL = [resourceBundle URLForResource:@"task-schema" withExtension:@"json"];
    NSData *schemaData = [NSData dataWithContentsOfURL:schemaURL];
    
    return [DSJSONSchema
        schemaWithData:schemaData
        baseURI:nil
        referenceStorage:nil
        specification:[DSJSONSchemaSpecification draft7]
        options:nil
        error:error];
}

// MARK: - Error Codes

@end

static NSString * const TIOFederatedTaskBundleValidatorErrorDomain = @"ai.doc.tensorio.task-bundle-validator";

static const NSUInteger TIOFTMalformedJSONErrorCode = 1000;
static const NSUInteger TIOFTInvalidFilepathErrorCode = 1001;
static const NSUInteger TIOFTInvalidExtensionErrorCode = 1002;
static const NSUInteger TIOFTNoTaskJSONFileErrorCode = 1003;
static const NSUInteger TIOFTTaskSchemaErrorCode = 1006;
static const NSUInteger TIOFTTaskValidationErrorCode = 1007;

// MARK: - Bundle Structure Errors

static NSError * TIOFTInvalidFilepathError(NSString * path) {
    return [NSError errorWithDomain:TIOFederatedTaskBundleValidatorErrorDomain code:TIOFTInvalidFilepathErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No .tiotask directory exists at path, %@", path],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure a .tiotask directory is the root directory"
    }];
}

static NSError * TIOFTInvalidExtensionError(NSString * path) {
    return [NSError errorWithDomain:TIOFederatedTaskBundleValidatorErrorDomain code:TIOFTInvalidExtensionErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Dirctory exists at path but does not have a .tiotask extension, %@", path],
        NSLocalizedRecoverySuggestionErrorKey: @"Add the .tiotask extension to the root directory"
    }];
}

static NSError * TIOFTNoTaskJSONFileError(void) {
    return [NSError errorWithDomain:TIOFederatedTaskBundleValidatorErrorDomain code:TIOFTNoTaskJSONFileErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No task.json file found"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure the root .tiotask directory contains a task.json file"
    }];
}

// MARK: - JSON Errors

static NSError * TIOFTMalformedJSONError(void) {
    return [NSError errorWithDomain:TIOFederatedTaskBundleValidatorErrorDomain code:TIOFTMalformedJSONErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The task.json file could not be read"],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure that task.json contains valid json"
    }];
}

static NSError * TIOFTTaskSchemaError(void) {
    return [NSError errorWithDomain:TIOFederatedTaskBundleValidatorErrorDomain code:TIOFTTaskSchemaErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The task-schema.json file could not be loaded"],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure you have added the Federated subpod to your podspec"
    }];
}

static NSError * TIOFTTaskValidationError(void) {
    return [NSError errorWithDomain:TIOFederatedTaskBundleValidatorErrorDomain code:TIOFTTaskValidationErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The task.json file failed validation."],
        NSLocalizedRecoverySuggestionErrorKey: @"Use the ajv-cli tool and the latest task schema at https://doc-ai.github.io/tensorio/ to validate the your task.json file"
    }];
}
