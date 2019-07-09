//
//  TIOTensorFlowModel.h
//  TensorIO
//
//  Created by Phil Dow on 4/9/19.
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

#import <Foundation/Foundation.h>

#import "TIOLayerInterface.h"
#import "TIOData.h"
#import "TIOModel.h"
#import "TIOTrainableModel.h"
#import "TIOBatch.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOModelIO;

/**
 * An Objective-C wrapper around TensorFlow models that provides a unified interface to the
 * input and output layers of the underlying model. These models are capable of
 * performing inference, training, and evaluation.
 *
 * See `TIOModel` for more information about TensorIO models and for a description of the
 * conforming properties and methods here.
 */

@interface TIOTensorFlowModel : NSObject <TIOModel>

@property (readonly) TIOModelBundle *bundle;
@property (readonly) TIOModelOptions *options;
@property (readonly) NSString* identifier;
@property (readonly) NSString* name;
@property (readonly) NSString* details;
@property (readonly) NSString* author;
@property (readonly) NSString* license;
@property (readonly) BOOL placeholder;
@property (readonly) BOOL quantized;
@property (readonly) NSString *type;
@property (readonly) NSString *backend;
@property (readonly) TIOModelModes *modes;
@property (readonly) BOOL loaded;
@property (readonly) TIOModelIO *io;

// MARK: - Initialization

/**
 * The designated initializer for conforming classes.
 *
 * You should not need to call this method directly. Instead, acquire an instance of a `TIOModelBundle`
 * associated with this model by way of the model's identifier. Then the `TIOModelBundle` class
 * calls this `initWithBundle:` factory initialization method, which conforming classes may override
 * to support custom initialization.
 *
 * @param bundle `TIOModelBundle` containing information about the model and its path
 *
 * @return instancetype An instance of the conforming class, may be `nil`.
 */

- (nullable instancetype)initWithBundle:(TIOModelBundle *)bundle NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Convenience method for initializing a model directly from bundle at some path
 *
 * @param path The path to the model bundle folder
 *
 * @return instancetype An instance of the model, or `nil`.
 */

+ (nullable instancetype)modelWithBundleAtPath:(NSString *)path;

// MARK: - Lifecycle

/**
 * Loads a model into memory.
 *
 * A model should load itself prior to running on any input, but consumers of the model may want
 * more control over when a model is loaded in order to avoid placing parameters into memory
 * before they are needed.
 *
 * Conforming classes should override this method to perform custom loading and set loaded=YES.
 *
 * @param error Set to one of the errors in TIOTFLiteErrors.h for TFLiteModels, or one of your own error.
 *
 * @return BOOL `YES` if the model is successfully loaded, `NO` otherwise.
 */

- (BOOL)load:(NSError * _Nullable *)error;

/**
 * Unloads a model from memory
 *
 * A model will unload its resources automatically when it is deallocated, but the unload function
 * may do this as well in order to provide finer grained control to consumers.
 *
 * Conforming classes should override this method to perform custom unloading and set `loaded=NO`.
 */

- (void)unload;

// MARK: - Run

/**
 * Performs inference on the provided input and returns the results. The primary
 * interface to a conforming class.
 *
 * @param input Any class conforming to `TIOData`.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of performing inference on input.
 */

- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError* _Nullable *)error;

/**
 * Performs inference on the provided input and returns the results.
 *
 * @param input Any class conforming to `TIOData`.
 * @param placeholders A dictionary of `TIOData` conforming placeholder values,
 *  which will be matched to placeholder layers in the model. May be nil.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of performing inference on input.
 */

- (id<TIOData>)runOn:(id<TIOData>)input placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError* _Nullable *)error;

/**
 * Performs inference on the provided batch and returns the results. A batch is
 * a more well defined way of providing data to a model and is comprised of
 * batch items, effectively rows of data, each of which contains feature values
 * as columns. See `TIOBatch` for more information.
 *
 * @param batch A batch of input data.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of performing inference on input.
 */

- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error;

/**
 * Performs inference on the provided batch and returns the results. A batch is
 * a more well defined way of providing data to a model and is comprised of
 * batch items, effectively rows of data, each of which contains feature values
 * as columns. See `TIOBatch` for more information.
 *
 * @param batch A batch of input data.
 * @param placeholders A dictionary of `TIOData` conforming placeholder values,
 *  which will be matched to placeholder layers in the model. May be nil.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of performing inference on input.
 */

- (id<TIOData>)run:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error;

/**
 * Deprecated. Use `runOn:error:` or one of the other similar methods instead.
 */

- (id<TIOData>)runOn:(id<TIOData>)input __attribute__((deprecated));

@end

// MARK: - Training

@interface TIOTensorFlowModel (TIOTrainableModel) <TIOTrainableModel>

/**
 * Calls the underlying training op with a single batch.
 *
 * A complete round of training will involve iterating over all the available
 * batches for a certain number of epochs. It is the responsibility of other
 * objects to execute those loops and prepare batches for calls to this method.
 * The `TIOModelTrainer` provides that functionality.
 *
 * @param batch A batch of input data.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of training, or an empty dictionary if an error
 *  occurs.
 */

- (id<TIOData>)train:(TIOBatch *)batch error:(NSError * _Nullable *)error;

/**
 * Calls the underlying training op with a single batch and a set of placeholder
 * values.
 *
 * A complete round of training will involve iterating over all the available
 * batches for a certain number of epochs. It is the responsibility of other
 * objects to execute those loops and prepare batches for calls to this method.
 * The `TIOModelTrainer` provides that functionality.
 *
 * @param batch A batch of input data.
 * @param placeholders A dictionary of `TIOData` conforming placeholder values,
 *  which will be matched to placeholder layers in the model. May be nil.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of training, or an empty dictionary if an error
 *  occurs.
 */

- (id<TIOData>)train:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error;

/**
 * Deprecated. `Use train:error:` or train:placeholders:error:` instead.
 */

- (id<TIOData>)train:(TIOBatch *)batch __attribute__((deprecated));

/**
 * Exports the results of training to the specified directory. The directory
 * must already exist.
 *
 * A TensorFlow export appends "checkpoint" to the file URL and exports two
 * files into that dirctory:
 *
 * checkpoint.index
 * checkpoint.data-XXXXX-of-YYYYY, e.g. checkpoint.data-00000-of-00001
 *
 * @param fileURL File URL to the directory in which the export will be saved
 * @param error Set to any error that occurs during the export, otherwise `nil`
 *
 * @return `YES` if the export was successful,`NO` otherwise
 */

- (BOOL)exportTo:(NSURL *)fileURL error:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
