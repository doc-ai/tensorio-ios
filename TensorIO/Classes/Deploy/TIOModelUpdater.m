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
#import "TIOModelRepositoryClient.h"
#import "TIOModelBundle.h"
#import "TIOModelBundleValidator.h"
#import "TIOMRModelIdentifier.h"
#import "TIOMRHyperparameter.h"
#import "TIOMRCheckpoint.h"
#import "TIOMRDownload.h"
#import "TIOErrorHandling.h"
#import "TIOModelUpdaterDelegate.h"

static NSString *TIOModelUpdaterErrorDomain = @"ai.doc.tensorio.model-updater";

static NSInteger TIOMRInvalidBundleId = 0;
static NSInteger TIOMRUpdateModelInternalInconsistentyError = 100;
static NSInteger TIOMRUpdateModelUnzipError = 200;
static NSInteger TIOMRUpdateModelContentsError = 201;
static NSInteger TIOMRUpdateFileSystemError = 202;
static NSInteger TIOMRUpdateFileDeletionError = 203;
static NSInteger TIOMRUpdateFileCopyError = 204;

@implementation TIOModelUpdater

- (instancetype)initWithModelBundle:(TIOModelBundle *)bundle repository:(TIOModelRepositoryClient *)repository {
    if ((self=[super init])) {
        _bundle = bundle;
        _repository = repository;
    }
    return self;
}

// MARK: -

- (void)checkForUpdate:(void(^)(BOOL updateAvailable, NSError * _Nullable error))callback {
    TIOMRModelIdentifier *identifier = [[TIOMRModelIdentifier alloc] initWithBundleId:self.bundle.identifier];
    
    if ( identifier == nil ) {
        NSError *error;
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"Unable to initialize model identifier from bundle id %@", self.bundle.identifier]),
            TIOModelUpdaterErrorDomain,
            TIOMRInvalidBundleId,
            error);
        callback(NO, error);
        return;
    }
    
    [self.repository GETHyperparameterForModelWithId:identifier.modelId hyperparametersId:identifier.hyperparametersId callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        if ( error != nil ) {
            callback(NO, error);
            return;
        }
        
        if ( hyperparameter.upgradeTo == nil && [hyperparameter.canonicalCheckpoint isEqualToString:identifier.checkpointId] ) {
            // No upgrade to a new set of hyperparameters and we are already using the canonical checkpoint
            callback(NO, nil);
        }
        else if ( hyperparameter.upgradeTo == nil && ![hyperparameter.canonicalCheckpoint isEqualToString:identifier.checkpointId] ) {
            // No upgrade to a new set of hyperparameters but a new checkpoint is available
            callback(YES, nil);
        }
        else if ( hyperparameter.upgradeTo != nil) {
            // An upgrade to a new set of hyperparameters is available
            callback(YES, nil);
        }
        else {
            // An inconsistent response
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Inconsistent request results attempting to update model with ids (%@, %@, %@)", identifier.modelId, identifier.hyperparametersId, identifier.checkpointId]),
                TIOModelUpdaterErrorDomain,
                TIOMRUpdateModelInternalInconsistentyError,
                error);
            callback(NO, error);
        }
    }];
}

- (void)updateWithValidator:(_Nullable TIOModelBundleValidationBlock)customValidator callback:(void(^)(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error))callback {
    
    // Parse the id
    
    TIOMRModelIdentifier *identifier = [[TIOMRModelIdentifier alloc] initWithBundleId:self.bundle.identifier];
    
    if ( identifier == nil ) {
        NSError *error;
        TIO_LOGSET_ERROR(
            ([NSString stringWithFormat:@"Unable to initialize model identifier from bundle id %@", self.bundle.identifier]),
            TIOModelUpdaterErrorDomain,
            TIOMRInvalidBundleId,
            error);
        callback(NO, nil, error);
        return;
    }
    
    // Download a model bundle if one is available
    
    [self updateModelWithId:identifier.modelId hyperparametersId:identifier.hyperparametersId checkpointId:identifier.checkpointId callback:^(BOOL updated, NSURL * _Nullable downloadURL, NSError * _Nonnull error) {
        
        if (error) {
            callback(updated, nil, error);
            return;
        }
        
        if (!updated) {
            callback(updated, nil, error);
            return;
        }
    
        // Unzip the bundle
        
        NSFileManager *fm = NSFileManager.defaultManager;
        NSError *fmError;
        
        NSURL *temporaryDirectory = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:NSUUID.UUID.UUIDString];
        
        if ( ![fm createDirectoryAtURL:temporaryDirectory withIntermediateDirectories:NO attributes:nil error:&fmError] ) {
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"File error creating temporary directory: %@", fmError]),
                TIOModelUpdaterErrorDomain,
                TIOMRUpdateFileSystemError,
                error);
            callback(NO, nil, error);
            return;
        }
        
        [self unzipModelBundleAtURL:downloadURL toURL:temporaryDirectory callback:^(NSURL * _Nullable downloadedBundleURL, NSError * _Nullable error) {
            
            if (error) {
                callback(NO, nil, error);
                return;
            }
            
            // Validate
            
            NSError *validationError;
            TIOModelBundleValidator *validator = [[TIOModelBundleValidator alloc] initWithModelBundleAtPath:downloadedBundleURL.path];
        
            if ( ![validator validate:customValidator error:&validationError] ) {
                NSError *error;
                TIO_LOGSET_ERROR(
                    ([NSString stringWithFormat:@"Model updator custom validator failed: %@ with bundle at path: %@", validationError, downloadedBundleURL]),
                    validationError.domain,
                    validationError.code,
                    error);
                callback(NO, nil, validationError);
                return;
            }
        
            // Overwrite existing bundle with new bundle
            
            NSURL *newBundleURL = [[[NSURL fileURLWithPath:self.bundle.path] URLByDeletingLastPathComponent] URLByAppendingPathComponent:[downloadedBundleURL lastPathComponent]];
            NSError *fmError;
            
            if ( ![fm removeItemAtPath:self.bundle.path error:&fmError] ) {
                NSError *error;
                TIO_LOGSET_ERROR(
                    ([NSString stringWithFormat:@"Model updator unable to remove existing model from path %@, error: %@", self.bundle.path, fmError]),
                    TIOModelUpdaterErrorDomain,
                    TIOMRUpdateFileDeletionError,
                    error);
                callback(NO, nil, error);
                return;
            }
            
            if ( ![fm copyItemAtURL:downloadedBundleURL toURL:newBundleURL error:&fmError] ) {
                NSError *error;
                TIO_LOGSET_ERROR(
                    ([NSString stringWithFormat:@"Model updator unable to copy downloaded bundle at %@ to %@, error: %@", downloadedBundleURL, newBundleURL, fmError]),
                    TIOModelUpdaterErrorDomain,
                    TIOMRUpdateFileCopyError,
                    error);
                callback(NO, nil, error);
                return;
            }
        
            // Success
        
            callback(updated, newBundleURL, error);
            
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

- (void)updateModelWithId:(NSString *)modelId hyperparametersId:(NSString *)hyperparametersId checkpointId:(NSString *)checkpointId callback:(void(^)(BOOL updated, NSURL * _Nullable downloadURL, NSError * _Nullable error))responseBlock {
    
    [self.repository GETHyperparameterForModelWithId:modelId hyperparametersId:hyperparametersId callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
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
            [self.repository GETCheckpointForModelWithId:modelId hyperparametersId:hyperparametersId checkpointId:hyperparameter.canonicalCheckpoint callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
                if ( error != nil ) {
                    responseBlock(NO, nil, error);
                    return;
                }
                
                // From the canonical checkpoint download the model link
                [self.repository downloadModelBundleAtURL:checkpoint.link withModelId:checkpoint.modelId hyperparametersId:checkpoint.hyperparametersId checkpointId:checkpoint.checkpointId callback:^(TIOMRDownload * _Nullable download, double progress, NSError * _Nullable error) {
                    // TODO: refactor duplicated implementation
                    if ( error != nil ) {
                        responseBlock(NO, nil, error);
                        return;
                    }
                    
                    // Callback may be executed multiple times as progress increases
        
                    [self informDelegateOfProgress:progress];
                    
                    // But download will only be set once the task is completed
                    
                    if ( !download ) {
                        return;
                    }
                    
                    responseBlock(YES, download.URL, nil);
                }];
                
            }];
            
        } else if ( hyperparameter.upgradeTo != nil) {
            // An upgrade to a new set of hyperparameters is available
            
            // Request the new set of hyperparameters
            [self.repository GETHyperparameterForModelWithId:modelId hyperparametersId:hyperparameter.upgradeTo callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
                if ( error != nil ) {
                    responseBlock(NO, nil, error);
                    return;
                }
                
                // From the hyperparameters request the canonical checkpoint
                [self.repository GETCheckpointForModelWithId:hyperparameter.modelId hyperparametersId:hyperparameter.hyperparametersId checkpointId:hyperparameter.canonicalCheckpoint callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
                    if ( error != nil ) {
                        responseBlock(NO, nil, error);
                        return;
                    }
                    
                    // From the canonical checkpoint download the model link
                    [self.repository downloadModelBundleAtURL:checkpoint.link withModelId:checkpoint.modelId hyperparametersId:checkpoint.hyperparametersId checkpointId:checkpoint.checkpointId callback:^(TIOMRDownload * _Nullable download, double progress, NSError * _Nullable error) {
                        // TODO: refactor duplicated implementation
                        if ( error != nil ) {
                            responseBlock(NO, nil, error);
                            return;
                        }
                        
                        // Callback may be executed multiple times as progress increases
            
                        [self informDelegateOfProgress:progress];
                        
                        // But download will only be set once the task is completed
                        
                        if ( !download ) {
                            return;
                        }
                        
                        responseBlock(YES, download.URL, nil);
                    }];
                    
                }];
                
            }];
            
        } else {
            // An inconsistent response
            NSError *error;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Inconsistent request results attempting to update model with ids (%@, %@, %@)", modelId, hyperparametersId, checkpointId]),
                TIOModelUpdaterErrorDomain,
                TIOMRUpdateModelInternalInconsistentyError,
                error);
            responseBlock(NO, nil, error);
        }
    }];
}

/**
 * Unzips a downloaded model bundle at a file URL to a destination file URL,
 * which should be a temporary directory.
 */

- (BOOL)unzipModelBundleAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL callback:(void(^)(NSURL * _Nullable bundleURL, NSError * _Nullable error))callback {
    NSFileManager *fm = NSFileManager.defaultManager;
    
    [SSZipArchive unzipFileAtPath:sourceURL.path toDestination:destinationURL.path progressHandler:nil completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        
        // Report unzip errors
        
        if ( error ) {
            NSError *localError;
            TIO_LOGSET_ERROR(([NSString stringWithFormat:@"Error unzipping model bundle: %@, to: %@ error: %@", sourceURL, destinationURL, error]),
                TIOModelUpdaterErrorDomain,
                TIOMRUpdateModelUnzipError,
                localError);
            callback(nil, localError);
            return;
        }
        
        if ( ![fm fileExistsAtPath:destinationURL.path] ) {
            NSError *localError;
            TIO_LOGSET_ERROR(([NSString stringWithFormat:@"Error unzipping model bundle: %@, to: %@ error: %@", sourceURL, destinationURL, localError]),
                TIOModelUpdaterErrorDomain,
                TIOMRUpdateModelUnzipError,
                localError);
            callback(nil, localError);
            return;
        }
        
        // Confirm unzipped contents are valid
        
        NSError *fmError;
        NSArray *contents = [fm contentsOfDirectoryAtPath:destinationURL.path error:&fmError];
        
        if ( contents == nil || fmError ) {
            NSError *localError;
            TIO_LOGSET_ERROR(([NSString stringWithFormat:@"Zipped model bundle at: %@ contains no contents at: %@", sourceURL, destinationURL]),
                TIOModelUpdaterErrorDomain,
                TIOMRUpdateModelContentsError,
                localError);
            callback(nil, localError);
            return;
        }
        
        if ( contents.count != 1 ) {
            NSError *localError;
            TIO_LOGSET_ERROR(
                ([NSString stringWithFormat:@"Zipped model bundle at: %@ contains incorrect contents at: %@, contents: %@", sourceURL, destinationURL, contents]),
                TIOModelUpdaterErrorDomain,
                TIOMRUpdateModelContentsError,
                localError);
            callback(nil, localError);
            return;
        }
        
        // Append the name of the unzipped file to the destination URL and return that as the bundle URL
        
        NSURL *bundleURL = [destinationURL URLByAppendingPathComponent:contents[0]];
        callback(bundleURL, nil);
    }];
    
    return YES;
}

// MARK: - Delegate Interactions

- (void)informDelegateOfProgress:(float)progress {
    if ( !self.delegate ) {
        return;
    }
    if ( ![self.delegate respondsToSelector:@selector(modelUpdater:didProgress:)]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate modelUpdater:self didProgress:progress];
    });
}

@end
