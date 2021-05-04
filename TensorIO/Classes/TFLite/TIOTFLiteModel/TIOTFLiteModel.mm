//
//  TIOTFLiteModel.mm
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
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

#import "TIOTFLiteModel.h"

#import "TIOModelBundle.h"
#import "TIOTFLiteErrors.h"
#import "TIOTFLiteData.h"
#import "TIOLayerInterface.h"
#import "TIOLayerDescription.h"
#import "TIOPixelBufferLayerDescription.h"
#import "TIOVectorLayerDescription.h"
#import "TIOStringLayerDescription.h"
#import "TIOScalarLayerDescription.h"
#import "TIOPixelBuffer.h"
#import "NSArray+TIOTFLiteData.h"
#import "NSNumber+TIOTFLiteData.h"
#import "NSData+TIOTFLiteData.h"
#import "NSDictionary+TIOTFLiteData.h"
#import "TIOPixelBuffer+TIOTFLiteData.h"
#import "NSArray+TIOExtensions.h"
#import "TIOBatch.h"
#import "TIOModelIO.h"

#import "TFLTensorFlowLite.h"

@implementation TIOTFLiteModel {
    TFLInterpreter *interpreter;
}

+ (nullable instancetype)modelWithBundleAtPath:(NSString *)path {
    return [[TIOTFLiteModel alloc] initWithBundle:[[TIOModelBundle alloc] initWithPath:path]];
}

- (void)dealloc {
    #ifdef DEBUG
    NSLog(@"Deallocating model");
    #endif
}

- (nullable instancetype)initWithBundle:(TIOModelBundle *)bundle {
    if (self = [super init]) {
        _bundle = bundle;
        _options = bundle.options;
        
        _identifier = bundle.identifier;
        _name = bundle.name;
        _details = bundle.details;
        _author = bundle.author;
        _license = bundle.license;
        _placeholder = bundle.placeholder;
        _quantized = bundle.quantized;
        _type = bundle.type;
        _backend = bundle.backend;
        _modes = bundle.modes;
        _io = bundle.io;
    }
    
    return self;
}

// MARK: - Model Memory Management

/**
 * Loads a model into memory and sets loaded=YES
 *
 * @param error An error describing any failure to load the model
 *
 * @return BOOL `YES` if the model is successfully loaded, `NO` otherwise.
 */

- (BOOL)load:(NSError * _Nullable *)error {
    if ( _loaded ) {
        return YES;
    }
    
    NSString *graphPath = self.bundle.modelFilepath;
    BOOL didAllocateTensors = NO;
    NSError *liteError = nil;
    
    // Load Graph
    
    interpreter = [[TFLInterpreter alloc] initWithModelPath:graphPath error:&liteError];
    
    if (!interpreter) {
        NSLog(@"Failed to init interpreter with model at path %@, error: %@", graphPath, liteError);
        if (error) {
            *error = kTIOTFLiteModelLoadModelError;
        }
        return NO;
    }
    
    didAllocateTensors = [interpreter allocateTensorsWithError:&liteError];
    
    if (!didAllocateTensors) {
        NSLog(@"Failed to allocate tensors for model %@, error: %@", self.identifier, liteError);
        if (error) {
            *error = kTIOTFLiteModelAllocateTensorsError;
        }
        return NO;
    }

    #ifdef DEBUG
    NSLog(@"Loaded model");
    #endif
    
    _loaded = YES;
    return YES;
}

/**
 * Unloads the model and sets loaded=NO
 */

- (void)unload {
    if ( !_loaded ) {
        return;
    }
    
    interpreter = nil;
    _loaded = NO;
}

// MARK: - Perform Inference

- (id<TIOData>)runOn:(id<TIOData>)input {
    return [self runOn:input error:nil];
}

- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError * _Nullable *)error {
    NSError *loadError;
    [self load:&loadError];
    
    if (loadError != nil) {
        NSLog(@"There was a problem loading the model from runOn, error: %@", loadError);
        if (*error) {
            *error = loadError;
        }
        return @{};
    }
    
    [self _prepareInput:input];
    [self _runInference];
    
    return [self _captureOutput];
}

- (id<TIOData>)runOn:(id<TIOData>)input placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError* _Nullable *)error {
    NSAssert(NO, @"TFLite models do not support placeholders.");
    return @{};
}

- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error {
    NSAssert([[NSSet setWithArray:batch.keys] isEqualToSet:[NSSet setWithArray:self.io.inputs.keys]], @"Batch keys do not match input layer names");
    NSAssert(batch.count == 1, @"Batch size must be 1 for TensorFlow Lite models");
    
    // Load
    
    NSError *loadError;
    [self load:&loadError];
    
    if (loadError != nil) {
        NSLog(@"There was a problem loading the model from run:error:, error: %@", loadError);
        if (*error) {
            *error = loadError;
        }
        return @{};
    }
    
    // Prepare Inputs
    
    TIOBatchItem *item = batch[0];
    
    for ( NSString *name in item ) {
        int index = [self.io.inputs indexForName:name].intValue;
        TFLTensor *tensor = [self inputTensorAtIndex:index];
        TIOLayerInterface *interface = self.io.inputs[name];
        id<TIOData> input = item[name];
    
        [self _prepareInput:input tensor:tensor interface:interface];
    }
    
    // Run Inference and Return Output
    
    [self _runInference];
    return [self _captureOutput];
}

- (id<TIOData>)run:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error {
    NSAssert(NO, @"TFLite models do not support placeholders.");
    return @{};
}

// MARK: - Prepare Inputs

/**
 * Iterates through the provided `TIOData` inputs, matching them to the model's input layers, and
 * copies their bytes to those input layers.
 *
 * @param data Any class conforming to the `TIOData` protocol
 */

- (void)_prepareInput:(id<TIOData>)data  {
    
    // When preparing inputs we take into account the type of input provided
    // and the number of inputs that are available
    
    if ( [data isKindOfClass:NSDictionary.class] ) {
        
        // With a dictionary input, regardless the count, iterate through the keys and values, mapping them to indices,
        // and prepare the indexed tensors with the values
    
        NSDictionary<NSString*,id<TIOData>> *dictionaryData = (NSDictionary *)data;
        NSAssert([[NSSet setWithArray:dictionaryData.allKeys] isEqualToSet:[NSSet setWithArray:self.io.inputs.keys]],
            @"Batch keys do not match input layer names");
    
        for ( NSString *name in dictionaryData ) {
            int index = [self.io.inputs indexForName:name].intValue;
            TFLTensor *tensor = [self inputTensorAtIndex:index];
            TIOLayerInterface *interface = self.io.inputs[name];
            id<TIOData> input = dictionaryData[name];
            
            [self _prepareInput:input tensor:tensor interface:interface];
        }
    }
    else if ( self.io.inputs.count == 1 ) {
    
        // If there is a single input available, simply take the input as it is
        
        TFLTensor *tensor = [self inputTensorAtIndex:0];
        TIOLayerInterface *interface = self.io.inputs[0];
        id<TIOData> input = data;
        
        [self _prepareInput:input tensor:tensor interface:interface];
    }
    else {
        
        // With more than one input, we must accept an array
        
        assert( [data isKindOfClass:NSArray.class] );
        
        // With an array input, iterate through its entries, preparing the indexed tensors with their values
        
        NSArray<id<TIOData>> *arrayData = (NSArray *)data;
        assert(arrayData.count == self.io.inputs.count);
        
        for ( int index = 0; index < arrayData.count; index++ ) {
            TFLTensor *tensor = [self inputTensorAtIndex:index];
            TIOLayerInterface *interface = self.io.inputs[index];
            id<TIOData> input = arrayData[index];
            
            [self _prepareInput:input tensor:tensor interface:interface];
        }
    }
}

/**
 * Requests the input to copy its bytes to the tensor
 *
 * @param input The data whose bytes will be copied to the tensor
 * @param tensor A pointer to the tensor which will receive those bytes
 * @param interface A description of the data which the tensor expects
 */

- (void)_prepareInput:(id<TIOData>)input tensor:(TFLTensor *)tensor interface:(TIOLayerInterface *)interface {
    __block NSData *data = nil;
    NSError *liteError = nil;
    
    [interface
        matchCasePixelBuffer:^(TIOPixelBufferLayerDescription *pixelBufferDescription) {
            assert( [input isKindOfClass:TIOPixelBuffer.class] );
            
            data = [(id<TIOTFLiteData>)input dataForDescription:pixelBufferDescription];
            
        } caseVector:^(TIOVectorLayerDescription *vectorDescription) {
            assert( [input isKindOfClass:NSArray.class]
                ||  [input isKindOfClass:NSData.class]
                ||  [input isKindOfClass:NSNumber.class] );
            
            data = [(id<TIOTFLiteData>)input dataForDescription:vectorDescription];
            
        } caseString:^(TIOStringLayerDescription * _Nonnull stringDescription) {
            assert( [input isKindOfClass:NSData.class]);
            
            data = [(id<TIOTFLiteData>)input dataForDescription:stringDescription];
        
        } caseScalar:^(TIOScalarLayerDescription * _Nonnull scalarDescription) {
            assert( [input isKindOfClass:NSArray.class]
                ||  [input isKindOfClass:NSData.class]
                ||  [input isKindOfClass:NSNumber.class] );
                
            data = [(id<TIOTFLiteData>)input dataForDescription:scalarDescription];
        }];
    
    
    if ( ![tensor copyData:data error:&liteError] ) {
        NSLog(@"There was a problem writing the data buffer to the tensor, error: %@", liteError);
    }
}

// MARK: - Execute Inference

/**
 * Runs inference on the model. Inputs must be copied to the input tensors prior to calling this method
 */

- (void)_runInference {
    NSError *liteError = nil;
    
    if (![interpreter invokeWithError:&liteError]) {
        NSLog(@"Failed to invoke for model %@, error: %@", self.identifier, liteError);
    }
}

// MARK: - Capture Outputs

/**
 * Captures outputs from the model.
 *
 * @return TIOData A class that is appropriate to the model output. Currently all outputs are
 * wrapped in an instance of `NSDictionary` whose keys are taken from the JSON description of the
 * model outputs.
 */

- (id<TIOData>)_captureOutput {
   
    NSMutableDictionary<NSString*,id<TIOData>> *outputs = [[NSMutableDictionary alloc] init];

    for ( int index = 0; index < self.io.outputs.count; index++ ) {
        TIOLayerInterface *interface = self.io.outputs[index];
        TFLTensor *tensor = [self outputTensorAtIndex:index];
        
        id<TIOData> data = [self _captureOutput:tensor interface:interface];
        outputs[interface.name] = data;
    }

    return [outputs copy];
}

/**
 * Copies bytes from the tensor to an appropriate class that conforms to `TIOData`
 *
 * @param tensor The output tensor whose bytes will be captured
 * @param interface A description of the data which this tensor contains
 */

- (id<TIOData>)_captureOutput:(TFLTensor *)tensor interface:(TIOLayerInterface *)interface {
    __block id<TIOData> output;
    
    NSError *liteError = nil;
    NSData *data = [tensor dataWithError:&liteError];

    if (!data) {
        NSLog(@"There was a problem reading the data buffer from the tensor, error: %@", liteError);
        return nil;
    }
    
    [interface
        matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
            output = [[TIOPixelBuffer alloc] initWithData:data description:pixelBufferDescription];
        
        } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
            
            TIOVector *vector = [[TIOVector alloc] initWithData:data description:vectorDescription];
            
            if ( vectorDescription.isLabeled ) {
                // If the vector's output is labeled, return a dictionary mapping labels to values
                output = [vectorDescription labeledValues:vector];
            } else {
                // If the vector's output is single-valued just return that value
                output = vector.count == 1
                    ? vector[0]
                    : vector;
            }
        } caseString:^(TIOStringLayerDescription * _Nonnull stringDescription) {
            output = [[NSData alloc] initWithData:data description:stringDescription];
        
        } caseScalar:^(TIOScalarLayerDescription * _Nonnull scalarDescription) {
            output = [[NSNumber alloc] initWithData:data description:scalarDescription];
        }];
    
    return output;
}

// MARK: - Utilities

/**
 * Returns a pointer to an input tensor at a given index
 */
 
- (nullable TFLTensor *)inputTensorAtIndex:(NSUInteger)index {
    NSError *liteError = nil;
    
    TFLTensor *tensor = [interpreter inputTensorAtIndex:index error:&liteError];
    
    if (!tensor) {
        // TODO: error
    }
    
    return tensor;
}

/**
 * Returns a pointer to an output tensor at a given index
 */

- (nullable TFLTensor *)outputTensorAtIndex:(NSUInteger)index {
    NSError *liteError = nil;
    
    TFLTensor *tensor = [interpreter outputTensorAtIndex:index error:&liteError];
    
    if (!tensor) {
        // TODO: error
    }
    
    return tensor;
}

@end
