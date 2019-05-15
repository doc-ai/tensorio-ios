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
    
    [self updateModelWithId:identifier.modelId hyperparametersId:identifier.hyperparametersId checkpointId:identifier.checkpointId destination:nil callback:^(BOOL updated, NSError * _Nonnull error) {
        
        if (error) {
            callback(updated, error);
            return;
        }
        
        if (!updated) {
            callback(updated, error);
            return;
        }
        
        // Unzip the bundle
        
        
        
        // Validate
    
    
    
        // Callback
    
        callback(updated, error);
    
    }];
    
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

- (void)updateModelWithId:(NSString*)modelId hyperparametersId:(NSString*)hyperparametersId checkpointId:(NSString*)checkpointId destination:(NSURL*)destinationURL callback:(void(^)(BOOL updated, NSError *error))responseBlock {
    
    NSURLSessionTask *task1 = [self.repository GETHyperparameterForModelWithId:modelId hyperparametersId:hyperparametersId callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
        if ( error != nil ) {
            responseBlock(NO, error);
            return;
        }
        
        if ( hyperparameter.upgradeTo == nil && [hyperparameter.canonicalCheckpoint isEqualToString:checkpointId] ) {
            // No upgrade to a new set of hyperparameters and we are already using the canonical checkpoint
            responseBlock(NO, nil);
            return;
        } else if ( hyperparameter.upgradeTo == nil && ![hyperparameter.canonicalCheckpoint isEqualToString:checkpointId] ) {
            // No upgrade to a new set of hyperparameters but a new checkpoint is available
            
            // Request the new canonical checkpoint
            NSURLSessionTask *task2 = [self.repository GETCheckpointForModelWithId:modelId hyperparametersId:hyperparametersId checkpointId:hyperparameter.canonicalCheckpoint callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
                if ( error != nil ) {
                    responseBlock(NO, error);
                    return;
                }
                
                // From the canonical checkpoint download the model link
                NSURLSessionTask *task3 = [self.repository downloadModelBundleAtURL:checkpoint.link withModelId:checkpoint.modelId hyperparametersId:checkpoint.hyperparametersId checkpointId:checkpoint.checkpointId callback:^(TIOMRDownload * _Nullable download, double progress, NSError * _Nullable error) {
                    if ( error != nil ) {
                        responseBlock(NO, error);
                        return;
                    }
                    
                    // Uzip and copy the download to the destination URL
                    
                    NSError *unzipError;
                    BOOL unzipped = [self unzipModelBundleAtURL:download.URL toURL:destinationURL error:&unzipError];
                    
                    if ( !unzipped ) {
                        responseBlock(NO, unzipError);
                    } else {
                        responseBlock(YES, nil);
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
                    responseBlock(NO, error);
                    return;
                }
                
                // From the hyperparameters request the canonical checkpoint
                NSURLSessionTask *task3 = [self.repository GETCheckpointForModelWithId:hyperparameter.modelId hyperparametersId:hyperparameter.hyperparametersId checkpointId:hyperparameter.canonicalCheckpoint callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
                    if ( error != nil ) {
                        responseBlock(NO, error);
                        return;
                    }
                    
                    // From the canonical checkpoint download the model link
                    NSURLSessionTask *task4 = [self.repository downloadModelBundleAtURL:checkpoint.link withModelId:checkpoint.modelId hyperparametersId:checkpoint.hyperparametersId checkpointId:checkpoint.checkpointId callback:^(TIOMRDownload * _Nullable download, double progress, NSError * _Nullable error) {
                        if ( error != nil ) {
                            responseBlock(NO, error);
                            return;
                        }
                    
                        // Uzip and copy the download to the destination URL
                    
                        NSError *unzipError;
                        BOOL unzipped = [self unzipModelBundleAtURL:download.URL toURL:destinationURL error:&unzipError];
                        
                        if ( !unzipped ) {
                            responseBlock(NO, unzipError);
                        } else {
                            responseBlock(YES, nil);
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
            responseBlock(NO, error);
        }
        
    }];
    [task1 resume];
}

/**
 * Unzips a downloaded model bundle at a file URL to a destination file URL.
 * The destination will be overwritten.
 */

- (BOOL)unzipModelBundleAtURL:(NSURL*)sourceURL toURL:(NSURL*)destinationURL error:(NSError**)error {
    return YES;
}

@end
