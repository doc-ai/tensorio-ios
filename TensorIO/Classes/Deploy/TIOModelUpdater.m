//
//  TIOModelUpdater.m
//  TensorIO
//
//  Created by Phil Dow on 5/13/19.
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

#import "TIOModelUpdater.h"
#import "TIOModelRepository.h"
#import "TIOModelBundle.h"
#import "TIOModelBundleValidator.h"
#import "TIOMRModelIdentifier.h"

#import "TIOMRHyperparameter.h"
#import "TIOMRCheckpoint.h"
#import "TIOMRDownload.h"

static NSString *TIOModelUpdaterErrorDomain = @"ai.doc.tensorio.model-updater";

static NSInteger TIOMRInvalidBundleId = 0;
static NSInteger TIOMRUpdateModelInternalInconsistentyError = 100;
static NSInteger TIOMRUpdateModelUnzipError = 200;
static NSInteger TIOMRUpdateModelContentsError = 201;
static NSInteger TIOMRUpdateFileSystemError = 202;
static NSInteger TIOMRUpdateFileCopyError = 203;

@implementation TIOModelUpdater

- (instancetype)initWithModelBundle:(TIOModelBundle*)bundle repository:(TIOModelRepository*)repository {
    if ((self=[super init])) {
        _bundle = bundle;
        _repository = repository;
    }
    return self;
}

- (void)updateWithValidator:(_Nullable TIOModelBundleValidationBlock)customValidator callback:(void(^)(BOOL updated, NSError *error))callback {
    
    // Parse the id
    
    TIOMRModelIdentifier *identifier = [[TIOMRModelIdentifier alloc] initWithBundleId:self.bundle.identifier];
    
    if ( identifier == nil ) {
        NSLog(@"Unable to initialize model identifier from bundle id %@", self.bundle.identifier);
        NSError *error = [[NSError alloc] initWithDomain:TIOModelUpdaterErrorDomain code:TIOMRInvalidBundleId userInfo:nil];
        callback(NO,error);
        return;
    }
    
    // Download a model bundle if one is available
    
    [self updateModelWithId:identifier.modelId hyperparametersId:identifier.hyperparametersId checkpointId:identifier.checkpointId callback:^(BOOL updated, NSURL * _Nullable downloadURL, NSError * _Nonnull error) {
        
        if (error) {
            callback(updated, error);
            return;
        }
        
        if (!updated) {
            callback(updated, error);
            return;
        }
        
        // Unzip the bundle
        
        NSFileManager *fm = NSFileManager.defaultManager;
        NSError *fmError;
        
        NSURL *temporaryDirectory = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:NSUUID.UUID.UUIDString];
        
        if ( ![fm createDirectoryAtURL:temporaryDirectory withIntermediateDirectories:NO attributes:nil error:&fmError] ) {
            NSError *error = [[NSError alloc] initWithDomain:TIOModelUpdaterErrorDomain code:TIOMRUpdateFileSystemError userInfo:nil];
            callback(NO, error);
            return;
        }
        
        [self unzipModelBundleAtURL:downloadURL toURL:temporaryDirectory callback:^(NSURL * _Nullable downloadedBundleURL, NSError * _Nullable error) {
            
            if (error) {
                callback(NO, error);
                return;
            }
            
            // Validate
            
            NSError *validationError;
            TIOModelBundleValidator *validator = [[TIOModelBundleValidator alloc] initWithModelBundleAtPath:downloadedBundleURL.path];
        
            if ( ![validator validate:customValidator error:&validationError] ) {
                NSLog(@"Custom validator failed: %@ with bundle at path: %@", error, downloadedBundleURL);
                callback(NO, validationError);
                return;
            }
        
            // Copy and overwrite existing bundle
            
            NSError *fmError;
            if ( ![fm replaceItemAtURL:[NSURL fileURLWithPath:self.bundle.path] withItemAtURL:downloadedBundleURL backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:&fmError] ) {
                NSError *error = [[NSError alloc] initWithDomain:TIOModelUpdaterErrorDomain code:TIOMRUpdateFileCopyError userInfo:nil];
                callback(NO, error);
                return;
            }
        
            // Success
        
            callback(updated, error);
            
        }]; // unzipModelBundleAtURL:toURL:callback:
    
    }]; // updateModelWithId:hyperparametersId:checkpointId:callback:
}

// MARK: - Private Methods

/**
 * Updates a model with the identifying (model, hyperparameter, checkpoint) triple,
 * unzipping the model bundle to the destination file URL parameter. If a bundle
 * already exists at that path, the bundle will be replaced.
 *
 * The callback is called with updated = `YES` and error = `nil` if the model
 * was successfully updated. When no update is available, updated = `NO` and
 * error = `nil`. Otherwise, error will be set to some value.
 */

- (void)updateModelWithId:(NSString*)modelId hyperparametersId:(NSString*)hyperparametersId checkpointId:(NSString*)checkpointId callback:(void(^)(BOOL updated, NSURL * _Nullable downloadURL, NSError * _Nullable error))responseBlock {
    
    NSURLSessionTask *task1 = [self.repository GETHyperparameterForModelWithId:modelId hyperparametersId:hyperparametersId callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        if ( error != nil ) {
            responseBlock(NO, nil, error);
            return;
        }
        
        if ( hyperparameter.upgradeTo == nil && [hyperparameter.canonicalCheckpoint isEqualToString:checkpointId] ) {
            // No upgrade to a new set of hyperparameters and we are already using the canonical checkpoint
            responseBlock(NO, nil, nil);
            return;
        } else if ( hyperparameter.upgradeTo == nil && ![hyperparameter.canonicalCheckpoint isEqualToString:checkpointId] ) {
            // No upgrade to a new set of hyperparameters but a new checkpoint is available
            
            // Request the new canonical checkpoint
            NSURLSessionTask *task2 = [self.repository GETCheckpointForModelWithId:modelId hyperparametersId:hyperparametersId checkpointId:hyperparameter.canonicalCheckpoint callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
                if ( error != nil ) {
                    responseBlock(NO, nil, error);
                    return;
                }
                
                // From the canonical checkpoint download the model link
                NSURLSessionTask *task3 = [self.repository downloadModelBundleAtURL:checkpoint.link withModelId:checkpoint.modelId hyperparametersId:checkpoint.hyperparametersId checkpointId:checkpoint.checkpointId callback:^(TIOMRDownload * _Nullable download, double progress, NSError * _Nullable error) {
                    if ( error != nil ) {
                        responseBlock(NO, nil, error);
                    } else {
                        responseBlock(YES, download.URL, nil);
                    }
                }];
                [task3 resume];
                
            }];
            [task2 resume];
            
        } else if ( hyperparameter.upgradeTo != nil) {
            // An upgrade to a new set of hyperparameters is available
            
            // Request the new set of hyperparameters
            NSURLSessionTask *task2 = [self.repository GETHyperparameterForModelWithId:modelId hyperparametersId:hyperparameter.upgradeTo callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
                if ( error != nil ) {
                    responseBlock(NO, nil, error);
                    return;
                }
                
                // From the hyperparameters request the canonical checkpoint
                NSURLSessionTask *task3 = [self.repository GETCheckpointForModelWithId:hyperparameter.modelId hyperparametersId:hyperparameter.hyperparametersId checkpointId:hyperparameter.canonicalCheckpoint callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
                    if ( error != nil ) {
                        responseBlock(NO, nil, error);
                        return;
                    }
                    
                    // From the canonical checkpoint download the model link
                    NSURLSessionTask *task4 = [self.repository downloadModelBundleAtURL:checkpoint.link withModelId:checkpoint.modelId hyperparametersId:checkpoint.hyperparametersId checkpointId:checkpoint.checkpointId callback:^(TIOMRDownload * _Nullable download, double progress, NSError * _Nullable error) {
                        if ( error != nil ) {
                            responseBlock(NO, nil, error);
                        } else {
                            responseBlock(YES, download.URL, nil);
                        }
                    }];
                    [task4 resume];
                    
                }];
                [task3 resume];
                
            }];
            [task2 resume];
            
        } else {
            NSLog(@"Inconsistent request results attempting to update model with ids (%@, %@, %@)", modelId, hyperparametersId, checkpointId);
            NSError *error = [[NSError alloc] initWithDomain:TIOModelUpdaterErrorDomain code:TIOMRUpdateModelInternalInconsistentyError userInfo:nil];
            responseBlock(NO, nil, error);
        }
        
    }];
    [task1 resume];
}

/**
 * Unzips a downloaded model bundle at a file URL to a destination file URL,
 * which should be a temporary directory.
 */

- (BOOL)unzipModelBundleAtURL:(NSURL*)sourceURL toURL:(NSURL*)destinationURL callback:(void(^)(NSURL * _Nullable bundleURL, NSError * _Nullable error))callback {
    NSFileManager *fm = NSFileManager.defaultManager;
    
    [SSZipArchive unzipFileAtPath:sourceURL.path toDestination:destinationURL.path progressHandler:nil completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        
        // Report unzip errors
        
        if ( error ) {
            NSLog(@"Error unzipping model bundle: %@, to: %@ error: %@", sourceURL, destinationURL, error);
            NSError *error = [[NSError alloc] initWithDomain:TIOModelUpdaterErrorDomain code:TIOMRUpdateModelUnzipError userInfo:nil];
            callback(nil, error);
            return;
        }
        
        if ( ![fm fileExistsAtPath:destinationURL.path] ) {
            NSLog(@"Error unzipping model bundle: %@, to: %@ error: %@", sourceURL, destinationURL, error);
            NSError *error = [[NSError alloc] initWithDomain:TIOModelUpdaterErrorDomain code:TIOMRUpdateModelUnzipError userInfo:nil];
            callback(nil, error);
            return;
        }
        
        // Confirm unzipped contents are valid
        
        NSError *fmError;
        NSArray *contents = [fm contentsOfDirectoryAtPath:destinationURL.path error:&fmError];
        
        if ( contents == nil || fmError ) {
            NSLog(@"Zipped model bundle at :%@ contains no contents at: %@", sourceURL, destinationURL);
            NSError *error = [[NSError alloc] initWithDomain:TIOModelUpdaterErrorDomain code:TIOMRUpdateModelContentsError userInfo:nil];
            callback(nil, error);
            return;
        }
        
        if ( contents.count != 1 ) {
            NSLog(@"Zipped model bundle at :%@ contains incorrect contents at: %@, contents: %@", sourceURL, destinationURL, contents);
            NSError *error = [[NSError alloc] initWithDomain:TIOModelUpdaterErrorDomain code:TIOMRUpdateModelContentsError userInfo:nil];
            callback(nil, error);
            return;
        }
        
        // Append the name of the unzipped file to the destination URL and return that as the bundle URL
        
        NSURL *bundleURL = [destinationURL URLByAppendingPathComponent:contents[0]];
        callback(bundleURL, nil);
    }];
    
    return YES;
}

@end
