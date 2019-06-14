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
#import "TIOPixelBuffer.h"
#import "TIOModelJSONParsing.h"
#import "TIOTensorFlowData.h"
#import "NSArray+TIOTensorFlowData.h"
#import "TIOPixelBuffer+TIOTensorFlowData.h"
#import "TIOTensorFlowErrors.h"
#import "TIOModelModes.h"

static NSString * const kTensorTypeVector = @"array";
static NSString * const kTensorTypeImage = @"image";

typedef std::pair<std::string, tensorflow::Tensor> NamedTensor;
typedef std::vector<NamedTensor> NamedTensors;
typedef std::vector<tensorflow::Tensor> Tensors;
typedef std::vector<std::string> TensorNames;

@implementation TIOTensorFlowModel {
    @protected
    tensorflow::SavedModelBundle _saved_model_bundle;
    
    // Index to Interface Description
    NSArray<TIOLayerInterface*> *_indexedInputInterfaces;
    NSArray<TIOLayerInterface*> *_indexedOutputInterfaces;
    
    // Name to Interface Description
    NSDictionary<NSString*,TIOLayerInterface*> *_namedInputInterfaces;
    NSDictionary<NSString*,TIOLayerInterface*> *_namedOutputInterfaces;
    
    // Name to Index
    NSDictionary<NSString*,NSNumber*> *_namedInputToIndex;
    NSDictionary<NSString*,NSNumber*> *_namedOutputToIndex;
    
    // Training Support
    NSArray<NSString*> *_trainingOps;
}

+ (nullable instancetype)modelWithBundleAtPath:(NSString*)path {
    return [[TIOTensorFlowModel alloc] initWithBundle:[[TIOModelBundle alloc] initWithPath:path]];
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
        _backend = bundle.backend;
        _modes = bundle.modes;
        
        // Input and output parsing
        
        NSArray<NSDictionary<NSString*,id>*> *inputs = bundle.info[@"inputs"];
        NSArray<NSDictionary<NSString*,id>*> *outputs = bundle.info[@"outputs"];
        NSDictionary<NSString*,id> *train = bundle.info[@"train"];
        
        if ( inputs == nil ) {
            NSLog(@"Expected input array field in model.json, none found");
            return nil;
        }
        
        if ( outputs == nil ) {
            NSLog(@"Expected output array field in model.json, none found");
            return nil;
        }
        
        if ( ![self _parseInputs:inputs] ) {
            NSLog(@"Unable to parse input field in model.json");
            return nil;
        }
        
        if ( ![self _parseOutputs:outputs] ) {
            NSLog(@"Unable to parse output field in model.json");
            return nil;
        }
        
        if ( ![self _parseTrainingDict:train] ) {
            NSLog(@"Unable to parse train field in model.json");
            return nil;
        }
    }
    
    return self;
}

- (instancetype)init {
    self = [self initWithBundle:[[TIOModelBundle alloc] initWithPath:@""]];
    NSAssert(NO, @"Use the designated initializer initWithBundle:");
    return self;
}

// MARK: - JSON Parsing

/**
 * Enumerates through the json described inputs and constructs a `TIOLayerInterface` for each one.
 *
 * @param inputs An array of dictionaries describing the model's input layers
 *
 * @return BOOL `YES` if the json descriptions were successfully parsed, `NO` otherwise
 */

- (BOOL)_parseInputs:(NSArray<NSDictionary<NSString*,id>*>*)inputs {
    
    auto *indexedInputInterfaces = [NSMutableArray<TIOLayerInterface*> array];
    auto *namedInputInterfaces = [NSMutableDictionary<NSString*,TIOLayerInterface*> dictionary];
    auto *namedInputToIndex = [NSMutableDictionary<NSString*,NSNumber*> dictionary];
    
    auto isQuantized = self.quantized;
    auto isInput = YES;
    
    __block BOOL error = NO;
    
    [inputs enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull input, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *type = input[@"type"];
        NSString *name = input[@"name"];
        
        TIOLayerInterface *interface;
        
        if ( [type isEqualToString:kTensorTypeVector] ) {
            interface = TIOTFLiteModelParseTIOVectorDescription(input, isInput, isQuantized, self->_bundle);
        } else if ( [type isEqualToString:kTensorTypeImage] ) {
            interface = TIOTFLiteModelParseTIOPixelBufferDescription(input, isInput, isQuantized);
        }
        
        if ( interface == nil ) {
            error = YES;
            *stop = YES;
            return;
        }
        
        [indexedInputInterfaces addObject:interface];
        namedInputInterfaces[name] = interface;
        namedInputToIndex[name] = @(idx);
    }];
    
    _indexedInputInterfaces = indexedInputInterfaces.copy;
    _namedInputInterfaces = namedInputInterfaces.copy;
    _namedInputToIndex = namedInputToIndex.copy;
    
    return !error;
}

/**
 * Enumerates through the json described outputs and constructs a `TIOLayerInterface` for each one.
 *
 * @param outputs An array of dictionaries describing the model's output layers
 *
 * @return BOOL `YES` if the json descriptions were successfully parsed, `NO` otherwise
 */

- (BOOL)_parseOutputs:(NSArray<NSDictionary<NSString*,id>*>*)outputs {
    
    auto *indexedOutputInterfaces = [NSMutableArray<TIOLayerInterface*> array];
    auto *namedOutputInterfaces = [NSMutableDictionary<NSString*,TIOLayerInterface*> dictionary];
    auto *namedOutputToIndex = [NSMutableDictionary<NSString*,NSNumber*> dictionary];
    
    auto isQuantized = self.quantized;
    auto isInput = NO;
    
    __block BOOL error = NO;
    
    [outputs enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull output, NSUInteger idx, BOOL * _Nonnull stop) {
    
        NSString *type = output[@"type"];
        NSString *name = output[@"name"];
        
        TIOLayerInterface *interface;
        
        if ( [type isEqualToString:kTensorTypeVector] ) {
            interface = TIOTFLiteModelParseTIOVectorDescription(output, isInput, isQuantized, self->_bundle);
        } else if ( [type isEqualToString:kTensorTypeImage] ) {
            interface = TIOTFLiteModelParseTIOPixelBufferDescription(output, isInput, isQuantized);
        }
        
        if ( interface == nil ) {
            error = YES;
            *stop = YES;
            return;
        }
        
        [indexedOutputInterfaces addObject:interface];
        namedOutputInterfaces[name] = interface;
        namedOutputToIndex[name] = @(idx);
    }];
    
    _indexedOutputInterfaces = indexedOutputInterfaces.copy;
    _namedOutputInterfaces = namedOutputInterfaces.copy;
    _namedOutputToIndex = namedOutputToIndex.copy;
    
    return !error;
}

/**
 * Parses the train dict if this model includes "train" as one of its supported modes.
 *
 * @param train A JSON dictionary describing the model's training options.
 *
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
    std::unordered_set<std::string> tags;
    
    if ( _modes.trains ) {
        tags = {tensorflow::kSavedModelTagTrain};
    } else if ( _modes.predicts ) {
        tags = {tensorflow::kSavedModelTagServe};
    } else {
        NSLog(@"No support model modes, i.e. predict, train, or eval");
        *error = TIOTensorFlowModelModeError;
        return NO;
    }
    
    tensorflow::SessionOptions session_opts;
    tensorflow::RunOptions run_opts;
    tensorflow::Status status;
    
    status = LoadSavedModel(session_opts, run_opts, model_dir, tags, &_saved_model_bundle);
    
    if ( status != tensorflow::Status::OK() ) {
        NSLog(@"Unable to load saved model, status: %@", [NSString stringWithUTF8String:status.ToString().c_str()]);
        *error = TIOTensorFlowModelLoadSavedModelError;
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

// MARK: - Input and Output Features

- (NSArray<TIOLayerInterface*>*)inputs {
    return _indexedInputInterfaces;
}

- (NSArray<TIOLayerInterface*>*)outputs {
    return _indexedOutputInterfaces;
}

- (id<TIOLayerDescription>)descriptionOfInputAtIndex:(NSUInteger)index {
    return _indexedInputInterfaces[index].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfInputWithName:(NSString*)name {
    return _namedInputInterfaces[name].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfOutputAtIndex:(NSUInteger)index {
    return _indexedOutputInterfaces[index].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfOutputWithName:(NSString*)name {
    return _namedOutputInterfaces[name].dataDescription;
}

// MARK: - Perform Inference

- (id<TIOData>)runOn:(id<TIOData>)input {
    return [self runOn:input error:nil];
}

- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError**)error {
    NSError *loadError;
    NSError *inferenceError;
    
    [self load:&loadError];
    
    if (loadError != nil) {
        NSLog(@"There was a problem loading the model from runOn, error: %@", loadError);
        if (error) {
            *error = loadError;
        }
        return @{};
    }
    
    const NamedTensors inputs = [self _prepareInput:input];
    
    const Tensors outputs = [self _runInference:inputs error:&inferenceError];
    if (inferenceError != nil ) {
        NSLog(@"There was a problem running inference, error: %@", inferenceError);
        if (error) {
            *error = inferenceError;
        }
        return @{};
    }
    
    const id<TIOData> results = [self _captureOutput:outputs];
    
    return results;
}

- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error {
    assert(NO);
    
    // TODO: bypass _prepareInput: and go straight to _prepareInput:interface:
}

/**
 * Iterates through the provided `TIOData` inputs, matching them to the model's input layers, and
 * prepares tensors with them.
 *
 * @param data Any class conforming to the `TIOData` protocol
 * @return NamedTensors Tensors ready to be passing to an inference session
 */

- (NamedTensors)_prepareInput:(id<TIOData>)data  {
    NamedTensors inputs;
    
    // When preparing inputs we take into account the type of input provided
    // and the number of inputs that are available
    
    if ( [data isKindOfClass:NSDictionary.class] ) {
        
        // With a dictionary input, regardless the count, iterate through the keys and values, mapping them to indices,
        // and prepare the indexed tensors with the values
    
        NSDictionary<NSString*,id<TIOData>> *dictionaryData = (NSDictionary*)data;
        
        for ( NSString *name in dictionaryData ) {
            assert([_namedInputInterfaces.allKeys containsObject:name]);
        
            TIOLayerInterface *interface = _namedInputInterfaces[name];
            id<TIOData> inputData = dictionaryData[name];
        
            NamedTensor input = [self _prepareInput:inputData interface:interface];
            inputs.push_back(input);
        }
    } else if ( _indexedInputInterfaces.count == 1 ) {
    
        // If there is a single input available, simply take the input as it is
        
        TIOLayerInterface *interface = _indexedInputInterfaces[0];
        id<TIOData> inputData = data;
        
        NamedTensor input = [self _prepareInput:inputData interface:interface];
        inputs.push_back(input);
    } else {
        
        // With more than one input, we must accept an array
        
        assert( [data isKindOfClass:NSArray.class] );
        
        // With an array input, iterate through its entries, preparing the indexed tensors with their values
        
        NSArray<id<TIOData>> *arrayData = (NSArray*)data;
        assert(arrayData.count == _indexedInputInterfaces.count);
        
        for ( NSUInteger index = 0; index < arrayData.count; index++ ) {
            TIOLayerInterface *interface = _indexedInputInterfaces[index];
            id<TIOData> inputData = arrayData[index];
            NamedTensor input = [self _prepareInput:inputData interface:interface];
            inputs.push_back(input);
        }
    }
    
    return inputs;
}

/**
 * Prepares a tensor from an input
 *
 * @param input The data whose bytes will be copied to the tensor
 * @param interface A description of the data which the tensor expects
 */

- (NamedTensor)_prepareInput:(id<TIOData>)input interface:(TIOLayerInterface*)interface {
    __block NamedTensor named_tensor;
    
    [interface
        matchCasePixelBuffer:^(TIOPixelBufferLayerDescription *pixelBufferDescription) {
            
            assert( [input isKindOfClass:TIOPixelBuffer.class] );
            
            tensorflow::Tensor tensor = [(id<TIOTensorFlowData>)input tensorWithDescription:pixelBufferDescription];
            std::string name = interface.name.UTF8String;
            
            named_tensor = NamedTensor(name, tensor);
            
        } caseVector:^(TIOVectorLayerDescription *vectorDescription) {
            
            assert( [input isKindOfClass:NSArray.class]
                ||  [input isKindOfClass:NSData.class]
                ||  [input isKindOfClass:NSNumber.class] );
            
            tensorflow::Tensor tensor = [(id<TIOTensorFlowData>)input tensorWithDescription:vectorDescription];
            std::string name = interface.name.UTF8String;
            
            named_tensor = NamedTensor(name, tensor);
        }];
    
    return named_tensor;
}

/**
 * Runs inference on the model with prepared inputs.
 *
 * @param inputs `NamedTensors` that are ready to be passed to an inference session
 * @return Tensors The output tensors that are a result of running inference
 */

- (Tensors)_runInference:(NamedTensors)inputs error:(NSError**)error {
    TensorNames output_names;
    Tensors outputs;
    
    for (TIOLayerInterface *interface in _indexedOutputInterfaces) {
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

    for ( int index = 0; index < _indexedOutputInterfaces.count; index++ ) {
        TIOLayerInterface *interface = _indexedOutputInterfaces[index];
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

- (id<TIOData>)_captureOutput:(tensorflow::Tensor)tensor interface:(TIOLayerInterface*)interface {
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
        }];
    
    return data;
}

@end

// MARK: - Training

@implementation TIOTensorFlowModel (TIOTrainableModel)

- (id<TIOData>)train:(TIOBatch*)batch {
    return [self train:batch error:nil];
}

- (id<TIOData>)train:(TIOBatch*)batch error:(NSError**)error {
    NSError *loadError;
    NSError *trainError;
    
    [self load:&loadError];
    
    if (loadError != nil) {
        NSLog(@"There was a problem loading the model from runOn, error: %@", loadError);
        if (*error) {
            *error = loadError;
        }
        return @{};
    }
    
    const NamedTensors inputs = [self _prepareTrainingInput:batch];
    const Tensors outputs = [self _runTraining:inputs error:&trainError];
    
    if (trainError != nil) {
        NSLog(@"There was a problem training the model from train:, error: %@", trainError);
        if (*error) {
            *error = trainError;
        }
        return @{};
    }
    
    const id<TIOData> results = [self _captureTrainingOutput:outputs];
    return results;
}

/**
 * Iterates through the contents of batch, matching them to the model's training
 * input layers, and prepares tensors with them.
 *
 * @param batch A batch of training data
 * @return NamedTensors Tensors ready to be passing to a training session
 */

- (NamedTensors)_prepareTrainingInput:(TIOBatch*)batch  {
    NamedTensors inputs;
    
    for ( NSString *key in batch.keys ) {
        TIOLayerInterface *interface = _namedInputInterfaces[key];
        NamedTensor input = [self _prepareTrainingInput:batch interface:interface];
        inputs.push_back(input);
    }
    
    return inputs;
}

/**
 * Prepares a tensor from a training input
 *
 * @param batch The data whose bytes will be copied to the tensor
 * @param interface A description of the data which the tensor expects
 */

- (NamedTensor)_prepareTrainingInput:(TIOBatch*)batch interface:(TIOLayerInterface*)interface {
    __block NamedTensor named_tensor;
    
    NSArray<id<TIOTensorFlowData>> *column = (NSArray<id<TIOTensorFlowData>>*)[batch valuesForKey:interface.name];
    
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
    }];
    
    return named_tensor;
}

/**
 * Runs training on the model with prepared inputs.
 *
 * @param inputs `NamedTensors` that are ready to be passed to a training session
 * @return Tensors The output tensors that are a result of running training
 */

- (Tensors)_runTraining:(NamedTensors)inputs error:(NSError**)error {
    TensorNames training_names;
    TensorNames output_names;
    Tensors outputs;
    
    // Output names
    
    for (TIOLayerInterface *interface in _indexedOutputInterfaces) {
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

    for ( int index = 0; index < _indexedOutputInterfaces.count; index++ ) {
        TIOLayerInterface *interface = _indexedOutputInterfaces[index];
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

- (id<TIOData>)_captureTrainingOutput:(tensorflow::Tensor)tensor interface:(TIOLayerInterface*)interface {
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
        }];
    
    return data;
}

- (BOOL)exportTo:(NSURL*)fileURL error:(NSError**)error {
    NSFileManager *fm = NSFileManager.defaultManager;
    BOOL isDirectory;
    
    if ( !fileURL.isFileURL ) {
        *error = TIOTensorFlowModelExportURLNotFilePath;
        return NO;
    }
    
    if ( ![fm fileExistsAtPath:fileURL.path isDirectory:&isDirectory] || !isDirectory ) {
        *error = TIOTensorFlowModelExportURLDoesNotExist;
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
        *error = TIOTensorFlowModelExportError;
        return NO;
    }
    
    return YES;
}

@end
