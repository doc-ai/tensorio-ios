//
//  TIOTensorFlowModel.m
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

//  TODO: Using class string to identity tensorflow model in model.json, identify some other way
//  TODO: Overloading model.file in model.json to point to predict directory, must also point to train and eval dirs

#import "TIOTensorFlowModel.h"

#include <string>
#include <unordered_set>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#include "loader.h"
#include "tag_constants.h"
#include "tensorflow/core/public/session.h"

#pragma clang diagnostic pop

#import "TIOModelBundle.h"
#import "TIOModelBundle+TensorFlowModel.h"

typedef std::vector<std::pair<std::string, tensorflow::Tensor>> TensorDict;

@implementation TIOTensorFlowModel {
    tensorflow::MetaGraphDef _meta_graph_def;
    tensorflow::Session* _session;
}

+ (nullable instancetype)modelWithBundleAtPath:(NSString*)path {
    return [[[TIOModelBundle alloc] initWithPath:path] newModel];
}

- (void)dealloc {
    #ifdef DEBUG
    NSLog(@"Deallocating model");
    #endif
}

- (nullable instancetype)initWithBundle:(TIOModelBundle*)bundle {
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
    }
    
    return self;
}

- (instancetype)init {
    self = [self initWithBundle:[[TIOModelBundle alloc] initWithPath:@""]];
    NSAssert(NO, @"Use the designated initializer initWithBundle:");
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

- (BOOL)load:(NSError**)error {
    if ( _loaded ) {
        return YES;
    }
    
    std::string model_dir = self.bundle.modelPredictPath.UTF8String;
    const std::unordered_set<std::string> tags = {tensorflow::kSavedModelTagServe};
    
    tensorflow::SavedModelBundle bundle;
    tensorflow::SessionOptions session_opts;
    tensorflow::RunOptions run_opts;
    
    TF_CHECK_OK(LoadSavedModel(session_opts, run_opts, model_dir, tags, &bundle));
    _meta_graph_def = bundle.meta_graph_def;
    _session = bundle.session.get();
    
    return YES;
}

/**
 * Unloads the model and sets loaded=NO
 */

- (void)unload {
    TF_CHECK_OK(_session->Close());
    delete _session;
    
    _loaded = NO;
}

// MARK: - Perform Inference

/**
 * Prepares the model's input tensors and performs inference, returning the results.
 *
 * @param input Any class conforming to `TIOData` whose bytes will be copied to the input tensors
 *
 * @return TIOData The results of performing inference
 */

- (id<TIOData>)runOn:(id<TIOData>)input {
    [self load:nil];
    [self _prepareInput:input];
    [self _runInference];
    return [self _captureOutput];
}

/**
 * Iterates through the provided `TIOData` inputs, matching them to the model's input layers, and
 * copies their bytes to those input layers.
 *
 * @param data Any class conforming to the `TIOData` protocol
 */

- (void)_prepareInput:(id<TIOData>)data  {

}

/**
 * Requests the input to copy its bytes to the tensor
 *
 * @param input The data whose bytes will be copied to the tensor
 * @param tensor A pointer to the tensor which will receive those bytes
 * @param interface A description of the data which the tensor expects
 */

- (void)_prepareInput:(id<TIOData>)input tensor:(void *)tensor interface:(TIOLayerInterface*)interface {

}

/**
 * Runs inference on the model. Inputs must be copied to the input tensors prior to calling this method
 */

- (void)_runInference {
    
}

/**
 * Captures outputs from the model.
 *
 * @return TIOData A class that is appropriate to the model output. Currently all outputs are
 * wrapped in an instance of `NSDictionary` whose keys are taken from the json description of the
 * model outputs.
 */

- (id<TIOData>)_captureOutput {
    return nil;
}

/**
 * Copies bytes from the tensor to an appropricate class that conforms to `TIOData`
 *
 * @param tensor The output tensor whose bytes will be captured
 * @param interface A description of the data which this tensor contains
 */

- (id<TIOData>)_captureOutput:(void *)tensor interface:(TIOLayerInterface*)interface {
    return nil;
}

@end
