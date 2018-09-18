//
//  TIOModelBundleValidator.m
//  TensorIO
//
//  Created by Philip Dow on 9/12/18.
//

#import "TIOModelBundleValidator.h"

#import "TIOModelBundle.h"

@implementation TIOModelBundleValidator

- (instancetype)initWithModelBundleAtPath:(NSString*)path {
    if (self = [super init]) {
        _path = path;
    }
    return self;
}

// MARK: - Errors

- (NSError*)invalidFilepathError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:301 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No .tfbundle directory exists at path, %@", self.path],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure a .tfbundle directory is the root directory"
    }];
}

- (NSError*)invalidExtensionError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:302 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Dirctory exists at path but does not have a .tfbundle extension, %@", self.path],
        NSLocalizedRecoverySuggestionErrorKey: @"Add the .tfbundle extension to the root directory"
    }];
}

- (NSError*)noModelJSONFileError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:303 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No model.json file found"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure the root .tfbundle directory contains a model.json file"
    }];
}

- (NSError*)missingPropertyError:(NSString*)property {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:304 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file is missing the %@ property", property],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure tha model.json contains the %@ property and that it is a valid value"
    }];
}

// MARK: - Validation

- (BOOL)validate:(NSError**)error {
    return [self validate:nil error:error];
}

- (BOOL)validate:(_Nullable TIOModelBundleValidationBlock)customValidator error:(NSError**)error {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    // Validate path
    
    if ( ![fm fileExistsAtPath:self.path isDirectory:&isDirectory] || !isDirectory ) {
        *error = self.invalidFilepathError;
        return NO;
    }
    
    // Validate bundle structure
    
    if ( ![self.path.pathExtension isEqualToString:kTFModelBundleExtension] ) {
        *error = self.invalidExtensionError;
        return NO;
    }
    
    if ( ![fm fileExistsAtPath:[self JSONPath] isDirectory:&isDirectory] || isDirectory ) {
        *error = self.noModelJSONFileError;
        return NO;
    }
    
    // Validate if JSON can be read
    
    NSDictionary *JSON = [self loadJSON];
    
    if ( JSON == nil ) {
    
    }
    
    // Validate basic bundle properties
    
    if ( ![self validateBundleProperties:JSON error:error] ) {
        return NO;
    }
    
    // Validate model
    
    if ( ![self validateModelProperties:JSON[@"model"] error:error] ) {
        return NO;
    }
    
    // Validate assets
    
    // Validate inputs
    
    if ( ![self validateModelProperties:JSON[@"inputs"] error:error] ) {
        return NO;
    }
    
    // Validate outputs
    
    if ( ![self validateModelProperties:JSON[@"outputs"] error:error] ) {
        return NO;
    }
    
    // Custom validator
    
    if ( customValidator && !customValidator(self.path, JSON, error) ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateBundleProperties:(NSDictionary*)JSON error:(NSError**)error {
    
    // Validate presence of basic bundle properties
    
    if ( JSON[@"name"] == nil || ![JSON[@"name"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"name"];
        return NO;
    }
    
    if ( JSON[@"details"] == nil || ![JSON[@"details"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"details"];
        return NO;
    }
    
    if ( JSON[@"id"] == nil || ![JSON[@"id"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"id"];
        return NO;
    }
    
    if ( JSON[@"version"] == nil || ![JSON[@"version"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"version"];
        return NO;
    }
    
    if ( JSON[@"author"] == nil || ![JSON[@"author"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"author"];
        return NO;
    }
    
    if ( JSON[@"license"] == nil || ![JSON[@"license"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"license"];
        return NO;
    }
    
    if ( JSON[@"model"] == nil || ![JSON[@"model"] isKindOfClass:[NSDictionary class]] ) {
        *error = [self missingPropertyError:@"model"];
        return NO;
    }
    
    if ( JSON[@"inputs"] == nil || ![JSON[@"inputs"] isKindOfClass:[NSArray class]] ) {
        *error = [self missingPropertyError:@"inputs"];
        return NO;
    }
    
    if ( JSON[@"outputs"] == nil || ![JSON[@"outputs"] isKindOfClass:[NSArray class]] ) {
        *error = [self missingPropertyError:@"outputs"];
        return NO;
    }
    
    return YES;
}

- (BOOL)validateModelProperties:(NSDictionary*)JSON error:(NSError**)error {
    
    return YES;
}

- (BOOL)validateInputs:(NSArray*)JSON error:(NSError**)error {
    
    return YES;
}

- (BOOL)validateOutputs:(NSArray*)JSON error:(NSError**)error {
    
    return YES;
}

// MARK: - Utilities

- (NSString*)JSONPath {
    return [self.path stringByAppendingPathComponent:kTFModelInfoFile];
}

- (NSDictionary*)loadJSON {
    NSString *path = [self JSONPath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSError *JSONError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];

    if ( JSON == nil ) {
        NSLog(@"Error reading json file at path %@, error %@", path, JSONError);
        return nil;
    }
    
    return JSON;
}

@end
