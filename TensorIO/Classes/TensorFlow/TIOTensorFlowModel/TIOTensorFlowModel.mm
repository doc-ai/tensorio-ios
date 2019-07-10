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

//  TODO: Overloading model.file in model.json to point to predict directory, must also point to train and eval dirs
//  TODO: Duplicating input/output parsing but may need backend specific parsing as well
//  TODO: Duplicated TensorType defines, should be defined elsewhere
//  TODO: Typedefs are used elsewhere, define in shared file

#import "TIOTensorFlowModel.h"

#include <utility>
#include <string>
#include <unordered_set>
#include <vector>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#include "loader.h"
#include "tag_constants.h"
#include "tensorflow/core/public/session.h"

#pragma clang diagnostic pop

#import "TIOModelBundle.h"
#import "TIOModelBundle+TensorFlowModel.h"
#import "TIOLayerInterface.h"
#import "TIOLayerDescription.h"
#import "TIOPixelBufferLayerDescription.h"
#import "TIOVectorLayerDescription.h"
#import "TIOStringLayerDescription.h"
#import "TIOPixelBuffer.h"
#import "TIOTensorFlowData.h"
#import "NSArray+TIOTensorFlowData.h"
#import "TIOPixelBuffer+TIOTensorFlowData.h"
#import "NSData+TIOTensorFlowData.h"
#import "TIOTensorFlowErrors.h"
#import "TIOModelModes.h"
#import "TIOModelIO.h"

typedef std::pair<std::string, tensorflow::Tensor> NamedTensor;
typedef std::vector<NamedTensor> NamedTensors;
typedef std::vector<tensorflow::Tensor> Tensors;
typedef std::vector<std::string> TensorNames;

@implementation TIOTensorFlowModel {
    tensorflow::SavedModelBundle _saved_model_bundle;
    
    // Training Support
    NSArray<NSString*> *_trainingOps;
}

+ (nullable instancetype)modelWithBundleAtPath:(NSString *)path {
    return [[TIOTensorFlowModel alloc] initWithBundle:[[TIOModelBundle alloc] initWithPath:path]];
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
        
        // Training parsing
        
        if ( ![self _parseTrainingDict:bundle.info[@"train"]] ) {
            NSLog(@"Unable to parse train field in model.json");
            return nil;
        }
    }
    
    return self;
}

// MARK: - JSON Parsing
// TODO: Move training and JSON parsing to shared location

/**
 * Parses the train dict if this model includes "train" as one of its supported modes.
 *
 * @param train A JSON dictionary describing the model's training options.
 * @return BOOL `YES` if the JSON dictionary was successfully parsed, `NO` otherwise.
 */

- (BOOL)_parseTrainingDict:(nullable NSDictionary<NSString*,id>*)train {
    if ( !_modes.trains ) {
        return YES;
    }
    
    if ( !train ) {
        NSLog(@"Model with identifier %@ includes 'train' as one of its modes "
                "but does not have a train field in model.json",
                _identifier);
    }
    
    if ( !train[@"ops"] ) {
        NSLog(@"Model with identifier %@ includes 'train' as one of its modes "
                "but does not have a train.ops field in model.json",
                _identifier);
    }
    
    _trainingOps = train[@"ops"];
    
    return YES;
}

// MARK: - Lifecycle

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
    
    std::string model_dir = self.bundle.modelPredictPath.UTF8String;
    std::unordered_set<std::string> tags;
    
    if ( _modes.trains ) {
        tags = {tensorflow::kSavedModelTagTrain};
    } else if ( _modes.predicts ) {
        tags = {tensorflow::kSavedModelTagServe};
    } else {
        NSLog(@"No support model modes, i.e. predict, train, or eval");
        if (error) {
            *error = TIOTensorFlowModelModeError;
        }
        return NO;
    }
    
    tensorflow::SessionOptions session_opts;
    tensorflow::RunOptions run_opts;
    tensorflow::Status status;
    
    status = LoadSavedModel(session_opts, run_opts, model_dir, tags, &_saved_model_bundle);
    
    if ( status != tensorflow::Status::OK() ) {
        NSLog(@"Unable to load saved model, status: %@", [NSString stringWithUTF8String:status.ToString().c_str()]);
        if (error) {
            *error = TIOTensorFlowModelLoadSavedModelError;
        }
        return NO;
    }
    
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
    
    TF_CHECK_OK(_saved_model_bundle.session.get()->Close());
    _loaded = NO;
}

// MARK: - Perform Inference

// All run method eventually call run:placeholders:error:

- (id<TIOData>)runOn:(id<TIOData>)input {
    return [self runOn:input error:nil];
}

- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError * _Nullable *)error {
    return [self runOn:input placeholders:nil error:error];
}

- (id<TIOData>)runOn:(id<TIOData>)input placeholders:(NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError* _Nullable *)error {
    // Convert TIOData to TIOBatch and call run:placeholders:error:
    
    TIOBatch *batch;
    
    if ( [input isKindOfClass:NSDictionary.class] ) {
        // Converts directly to TIOBatchItem
        batch = [[TIOBatch alloc] initWithItem:(TIOBatchItem *)input];
        
    } else if ( self.io.inputs.count == 1 ) {
        // Get name of input, convert to TIOBatchItem
        batch = [[TIOBatch alloc] initWithItem:@{
            self.io.inputs[0].name: input
        }];
        
    } else {
        // More than one input must be array with same number of items as inputs
        assert( [input isKindOfClass:NSArray.class] );
        assert( ((NSArray *)input).count == self.io.inputs.count );
        
        // Match array items to named indexes and convert to TIOBatchItem
        NSMutableDictionary *item = NSMutableDictionary.dictionary;
        
        for ( NSUInteger i = 0; i < self.io.inputs.count; i++ ) {
            item[self.io.inputs[i].name] = ((NSArray *)input)[i];
        }
        
        batch = [[TIOBatch alloc] initWithItem:(TIOBatchItem *)item];
    }
    
    return [self run:batch placeholders:placeholders error:error];
}

- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error {
    return [self run:batch placeholders:nil error:error];
}

// * Internally the method converts the placeholders to a TIOBatch and treats all
// * the placeholders values as a single batch item, corresponding to a collection
// * of keys and values, which is all that placeholders, and named tensors, are.
// * This approach allows us to reuse the tensor preparation code across inference
// * inputs, training inputs, and placeholders.

- (id<TIOData>)run:(TIOBatch *)batch placeholders:(NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error {
    NSAssert([[NSSet setWithArray:batch.keys] isEqualToSet:[NSSet setWithArray:self.io.inputs.keys]], @"Batch keys do not match input layer names");
    NSAssert(batch.count == 1, @"Run batch size must currently be 1 for TensorFlow models");
    
    NSError *loadError;
    NSError *inferenceError;
    
    // Load Model
    
    [self load:&loadError];
    
    if (loadError != nil) {
        NSLog(@"There was a problem loading the model from run:error:, error: %@", loadError);
        if (*error) {
            *error = loadError;
        }
        return @{};
    }
    
    // Pepare Inputs and Placeholders
    
    NamedTensors inputs_t = [self _namedTensorsForBatch:batch layers:self.io.inputs];
    
    if ( placeholders != nil ) {
        TIOBatch *placeholdersBatch = [[TIOBatch alloc] initWithItem:(TIOBatchItem *)placeholders];
        const NamedTensors placeholders_t = [self _namedTensorsForBatch:placeholdersBatch layers:self.io.placeholders];
        inputs_t.insert(inputs_t.end(), placeholders_t.begin(), placeholders_t.end());
    }
    
    // Run Model
    
    const Tensors outputs_t = [self _runInference:inputs_t error:&inferenceError];
    
    if (inferenceError != nil ) {
        NSLog(@"There was a problem running inference, error: %@", inferenceError);
        if (error) {
            *error = inferenceError;
        }
        return @{};
    }
    
    // Return Output
    
    const id<TIOData> results = [self _captureOutput:outputs_t];
    return results;
}

// MARK: - Prepare Inputs

/**
 * Iterates through the contents of batch, matching them to the provided io
 * layers, and prepares tensors with them.
 *
 * @param batch A batch of training data.
 * @param layers The IO layer descriptions that direct how the batch data
 *  is processed;
 * @return NamedTensors Tensors ready to be passing to an run session.
 */

- (NamedTensors)_namedTensorsForBatch:(TIOBatch *)batch layers:(TIOModelIOList*)layers {
    NamedTensors tensors;
    
    for ( NSString *key in batch.keys ) {
        NSArray<id<TIOTensorFlowData>> *column = (NSArray<id<TIOTensorFlowData>>*)[batch valuesForKey:key];
        TIOLayerInterface *interface = layers[key];
        
        NamedTensor tensor = [self _namedTensorForColumn:column interface:interface];
        tensors.push_back(tensor);
    }
    
    return tensors;
}

/**
 * Prepares a tensor from an inference input
 *
 * @param column A colun of data for the specified interface
 * @param interface A description of the data which the tensor expects
 */

- (NamedTensor)_namedTensorForColumn:(NSArray<id<TIOTensorFlowData>> *)column interface:(TIOLayerInterface *)interface {
    __block NamedTensor named_tensor;
    
    [interface matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
        assert( [column[0] isKindOfClass:TIOPixelBuffer.class] );
        
        tensorflow::Tensor tensor = [column[0].class tensorWithColumn:column description:pixelBufferDescription];
        std::string name = interface.name.UTF8String;
    
        named_tensor = NamedTensor(name, tensor);
        
    } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
        assert( [column[0] isKindOfClass:NSArray.class]
            ||  [column[0] isKindOfClass:NSData.class]
            ||  [column[0] isKindOfClass:NSNumber.class] );
        
        tensorflow::Tensor tensor = [column[0].class tensorWithColumn:column description:vectorDescription];
        std::string name = interface.name.UTF8String;
    
        named_tensor = NamedTensor(name, tensor);
        
    } caseString:^(TIOStringLayerDescription * _Nonnull stringDescription) {
        assert( [column[0] isKindOfClass:NSData.class] );
        
        tensorflow::Tensor tensor = [column[0].class tensorWithColumn:column description:stringDescription];
        std::string name = interface.name.UTF8String;
    
        named_tensor = NamedTensor(name, tensor);
    }];
    
    return named_tensor;
}

// MARK: - Execute Inference

/**
 * Runs inference on the model with prepared inputs.
 *
 * @param inputs `NamedTensors` that are ready to be passed to an inference session
 * @return Tensors The output tensors that are a result of running inference
 */

- (Tensors)_runInference:(NamedTensors)inputs error:(NSError * _Nullable *)error {
    TensorNames output_names;
    Tensors outputs;
    
    for (TIOLayerInterface *interface in self.io.outputs.all) {
        output_names.push_back(interface.name.UTF8String);
    }
    
    tensorflow::Session *session = _saved_model_bundle.session.get();
    tensorflow::Status status;
    
    status = session->Run(inputs, output_names, {}, &outputs);
    
    if ( status != tensorflow::Status::OK() ) {
        NSLog(@"Run error on session->Run with the inputs and output_names: %@", [NSString stringWithUTF8String:status.ToString().c_str()]);
        if (error) {
            *error = TIOTensorFlowModelSessionInferenceError;
        }
        return outputs;
    }
    
    return outputs;
}

// MARK: - Capture Outputs

/**
 * Captures outputs from the model.
 *
 * @param outputTensors `Tensors` that have been produced by an inference session
 * @return TIOData A class that is appropriate to the model output. Currently all outputs are
 *  wrapped in an instance of `NSDictionary` whose keys are taken from the json description of the
 *  model outputs.
 */

- (id<TIOData>)_captureOutput:(Tensors)outputTensors {
   
    NSMutableDictionary<NSString*,id<TIOData>> *outputs = [[NSMutableDictionary alloc] init];

    for ( int index = 0; index < self.io.outputs.count; index++ ) {
        TIOLayerInterface *interface = self.io.outputs[index];
        tensorflow::Tensor tensor = outputTensors[index];
        
        id<TIOData> data = [self _captureOutput:tensor interface:interface];
        outputs[interface.name] = data;
    }
    
    return outputs.copy;
}

/**
 * Copies bytes from the tensor to an appropriate class that conforms to `TIOData`
 *
 * @param tensor The output tensor whose bytes will be captured
 * @param interface A description of the data which this tensor contains
 */

- (id<TIOData>)_captureOutput:(tensorflow::Tensor)tensor interface:(TIOLayerInterface *)interface {
    __block id<TIOData> data;
    
    [interface
        matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
            
            data = [[TIOPixelBuffer alloc] initWithTensor:tensor description:pixelBufferDescription];
        
        } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
            
            TIOVector *vector = [[TIOVector alloc] initWithTensor:tensor description:vectorDescription];
            
            if ( vectorDescription.isLabeled ) {
                // If the vector's output is labeled, return a dictionary mapping labels to values
                data = [vectorDescription labeledValues:vector];
            } else {
                // If the vector's output is single-valued just return that value
                data = vector.count == 1
                    ? vector[0]
                    : vector;
            }
            
        } caseString:^(TIOStringLayerDescription * _Nonnull stringDescription) {
            
            data = [[NSData alloc] initWithTensor:tensor description:stringDescription];
        }];
    
    return data;
}

@end

// MARK: - Training

@implementation TIOTensorFlowModel (TIOTrainableModel)

- (id<TIOData>)train:(TIOBatch *)batch {
    return [self train:batch error:nil];
}

- (id<TIOData>)train:(TIOBatch *)batch error:(NSError * _Nullable *)error {
    return [self train:batch placeholders:nil error:error];
}

// * Internally the method converts the placeholders to a TIOBatch and treats all
// * the placeholders values as a single batch item, corresponding to a collection
// * of keys and values, which is all that placeholders, and named tensors, are.
// * This approach allows us to reuse the tensor preparation code across inference
// * inputs, training inputs, and placeholders.

- (id<TIOData>)train:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error {
    NSError *loadError;
    NSError *trainError;
    
    [self load:&loadError];
    
    if (loadError != nil) {
        NSLog(@"There was a problem loading the model from runOn, error: %@", loadError);
        if (error) {
            *error = loadError;
        }
        return @{};
    }
    
    NamedTensors inputs_t = [self _namedTensorsForBatch:batch layers:self.io.inputs];
    
    if ( placeholders != nil ) {
        TIOBatch *placeholdersBatch = [[TIOBatch alloc] initWithItem:(TIOBatchItem *)placeholders];
        const NamedTensors placeholders_t = [self _namedTensorsForBatch:placeholdersBatch layers:self.io.placeholders];
        inputs_t.insert(inputs_t.end(), placeholders_t.begin(), placeholders_t.end());
    }
    
    const Tensors outputs_t = [self _runTraining:inputs_t error:&trainError];
    
    if (trainError != nil) {
        NSLog(@"There was a problem training the model from train:, error: %@", trainError);
        if (error) {
            *error = trainError;
        }
        return @{};
    }
    
    const id<TIOData> results = [self _captureTrainingOutput:outputs_t];
    return results;
}

// MARK: - Execute Training

/**
 * Runs training on the model with prepared inputs.
 *
 * @param inputs `NamedTensors` that are ready to be passed to a training session
 * @return Tensors The output tensors that are a result of running training
 */

- (Tensors)_runTraining:(NamedTensors)inputs error:(NSError * _Nullable *)error {
    TensorNames training_names;
    TensorNames output_names;
    Tensors outputs;
    
    // Output names
    
    for (TIOLayerInterface *interface in self.io.outputs.all) {
        output_names.push_back(interface.name.UTF8String);
    }
    
    // Training op names
    
    for (NSString *op in _trainingOps) {
         training_names.push_back(op.UTF8String);
    }
    
    // Run training
    
    tensorflow::Session *session = _saved_model_bundle.session.get();
    tensorflow::Status status;
    
    status = session->Run(inputs, {}, training_names, nullptr);
    
    if ( status != tensorflow::Status::OK() ) {
        NSLog(@"Train rror on session->Run with the inputs and training_names: %@", [NSString stringWithUTF8String:status.ToString().c_str()]);
        if (error) {
            *error = TIOTensorFlowModelSessionTrainError;
        }
        return outputs;
    }
    
    // Get loss
    
    status = session->Run(inputs, output_names, {}, &outputs);
    
    if ( status != tensorflow::Status::OK() ) {
        NSLog(@"Train error on session->Run with the inputs and output_na,mes: %@", [NSString stringWithUTF8String:status.ToString().c_str()]);
        if (error) {
            *error = TIOTensorFlowModelSessionTrainError;
        }
        return outputs;
    }
    
    // Train and get loss at the same time : results in a slightly different output
    // TF_CHECK_OK(session->Run(inputs, output_names, training_names, &outputs));
    
    return outputs;
}

// MARK: - Capture Outputs

/**
 * Captures training outputs from the model.
 *
 * @param outputTensors `Tensors` that have been produced by a training session
 * @return TIOData A class that is appropriate to the model output. Currently all outputs are
 *  wrapped in an instance of `NSDictionary` whose keys are taken from the JSON description of the
 *  model's training outputs.
 */

- (id<TIOData>)_captureTrainingOutput:(Tensors)outputTensors {
   // Note that this implementation is currently identical to _captureOutput:
   
    NSMutableDictionary<NSString*,id<TIOData>> *outputs = [[NSMutableDictionary alloc] init];

    for ( int index = 0; index < self.io.outputs.count; index++ ) {
        TIOLayerInterface *interface = self.io.outputs[index];
        tensorflow::Tensor tensor = outputTensors[index];
        
        id<TIOData> data = [self _captureTrainingOutput:tensor interface:interface];
        outputs[interface.name] = data;
    }
    
    return outputs.copy;
}

/**
 * Copies bytes from the tensor to an appropriate class that conforms to `TIOData`
 *
 * @param tensor The output tensor whose bytes will be captured
 * @param interface A description of the data which this tensor contains
 */

- (id<TIOData>)_captureTrainingOutput:(tensorflow::Tensor)tensor interface:(TIOLayerInterface *)interface {
    // Note that this implementation is currently identical to _captureOutput:interface
    
    __block id<TIOData> data;
    
    [interface
        matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
            
            data = [[TIOPixelBuffer alloc] initWithTensor:tensor description:pixelBufferDescription];
        
        } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
            
            TIOVector *vector = [[TIOVector alloc] initWithTensor:tensor description:vectorDescription];
            
            if ( vectorDescription.isLabeled ) {
                // If the vector's output is labeled, return a dictionary mapping labels to values
                data = [vectorDescription labeledValues:vector];
            } else {
                // If the vector's output is single-valued just return that value
                data = vector.count == 1
                    ? vector[0]
                    : vector;
            }
            
        } caseString:^(TIOStringLayerDescription * _Nonnull stringDescription) {
            
            data = [[NSData alloc] initWithTensor:tensor description:stringDescription];
        }];
    
    return data;
}

// MARK: - Export

- (BOOL)exportTo:(NSURL *)fileURL error:(NSError * _Nullable *)error {
    NSFileManager *fm = NSFileManager.defaultManager;
    BOOL isDirectory;
    
    if ( !fileURL.isFileURL ) {
        if (error) {
            *error = TIOTensorFlowModelExportURLNotFilePath;
        }
        return NO;
    }
    
    if ( ![fm fileExistsAtPath:fileURL.path isDirectory:&isDirectory] || !isDirectory ) {
        if (error) {
            *error = TIOTensorFlowModelExportURLDoesNotExist;
        }
        return NO;
    }
    
    // Save checkpoint
    
    NSURL *checkpointURL = [fileURL URLByAppendingPathComponent:@"checkpoint"];
    
    tensorflow::Tensor checkpoint_tensor(tensorflow::DT_STRING, tensorflow::TensorShape());
    checkpoint_tensor.scalar<std::string>()() = checkpointURL.path.UTF8String;

    tensorflow::Session *session = _saved_model_bundle.session.get();
    tensorflow::MetaGraphDef meta_graph_def = _saved_model_bundle.meta_graph_def;

    NamedTensors checkpoint_feed_dict = {{meta_graph_def.saver_def().filename_tensor_name(), checkpoint_tensor}};
    tensorflow::Status status = session->Run(checkpoint_feed_dict, {}, {meta_graph_def.saver_def().save_tensor_name()}, nullptr);
    
    if ( status != tensorflow::Status::OK() ) {
        NSLog(@"Unable to export model, status: %@", [NSString stringWithUTF8String:status.ToString().c_str()]);
        if (error) {
            *error = TIOTensorFlowModelExportError;
        }
        return NO;
    }
    
    return YES;
}

@end
