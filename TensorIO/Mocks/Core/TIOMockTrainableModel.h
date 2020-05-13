//
//  TIOMockTrainableModel.h
//  TensorIO_Example
//
//  Created by Phil Dow on 5/20/19.
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

@import Foundation;
@import TensorIO;

NS_ASSUME_NONNULL_BEGIN

/**
 * The mock trainable model tracks the number of times `run:` and `train:` have
 * been called and is used to validate `TIOModelTrainer` behavior.
 */

@interface TIOMockTrainableModel : NSObject <TIOModel, TIOTrainableModel>

// MARK: - Mock Properties

/**
 * Tracks number of times the run: method has been called.
 */

@property (readonly) NSUInteger runCount;

/**
 * Tracks number of times the train: method has been called.
 */

@property (readonly) NSUInteger trainCount;

/**
 * Tracks the number of times the exportTo: method has been called.
 */

@property (readonly) NSUInteger exportCount;

/**
 * A file URL to a directory containing mock export data. If set, the contents
 * of this directory will be written to the path passed to the exportTo:
 * method.
 */

@property (nullable) NSURL *mockExportsURL;

/**
 * Mock initializer.
 */

- (instancetype)initMock;

// MARK: - TIOModel

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

- (nullable instancetype)initWithBundle:(TIOModelBundle *)bundle NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)modelWithBundleAtPath:(NSString *)path;

// MARK: - Lifecycle

- (BOOL)load:(NSError * _Nullable *)error;
- (void)unload;

// MARK: - Run

- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError* _Nullable *)error;
- (id<TIOData>)runOn:(id<TIOData>)input placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError* _Nullable *)error;
- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error;
- (id<TIOData>)run:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error;
- (id<TIOData>)runOn:(id<TIOData>)input __attribute__((deprecated));

// MARK: - Train

- (id<TIOData>)train:(TIOBatch *)batch error:(NSError * _Nullable *)error;
- (id<TIOData>)train:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error;
- (id<TIOData>)train:(TIOBatch *)batch __attribute__((deprecated));

- (BOOL)exportTo:(NSURL *)fileURL error:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
