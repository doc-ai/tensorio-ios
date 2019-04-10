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

static NSString * const kTensorTypeVector = @"array";
static NSString * const kTensorTypeImage = @"image";

typedef std::pair<std::string, tensorflow::Tensor> NamedTensor;
typedef std::vector<NamedTensor> NamedTensors;
typedef std::vector<tensorflow::Tensor> Tensors;
typedef std::vector<std::string> TensorNames;

@implementation TIOTensorFlowModel {
    @protected
    tensorflow::SavedModelBundle _saved_model_bundle;
    // tensorflow::MetaGraphDef _meta_graph_def;
    // std::unique_ptr<tensorflow::Session> _session;
    
    // Index to Interface Description
    NSArray<TIOLayerInterface*> *_indexedInputInterfaces;
    NSArray<TIOLayerInterface*> *_indexedOutputInterfaces;
    
    // Name to Interface Description
    NSDictionary<NSString*,TIOLayerInterface*> *_namedInputInterfaces;
    NSDictionary<NSString*,TIOLayerInterface*> *_namedOutputInterfaces;
    
    // Name to Index
    NSDictionary<NSString*,NSNumber*> *_namedInputToIndex;
    NSDictionary<NSString*,NSNumber*> *_namedOutputToIndex;
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
        
        // Input and output parsing
        
        NSArray<NSDictionary<NSString*,id>*> *inputs = bundle.info[@"inputs"];
        NSArray<NSDictionary<NSString*,id>*> *outputs = bundle.info[@"outputs"];
        
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
    
    // tensorflow::SavedModelBundle bundle;
    tensorflow::SessionOptions session_opts;
    tensorflow::RunOptions run_opts;
    
    TF_CHECK_OK(LoadSavedModel(session_opts, run_opts, model_dir, tags, &_saved_model_bundle));
    //_meta_graph_def = bundle.meta_graph_def;
    //_session = bundle.session.get();
    
    _loaded = YES;
    
    return YES;
}

/**
 * Unloads the model and sets loaded=NO
 */

- (void)unload {
    TF_CHECK_OK(_saved_model_bundle.session.get()->Close());
    
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
    const NamedTensors inputs = [self _prepareInput:input];
    const Tensors outputs = [self _runInference:inputs];
    return [self _captureOutput:outputs];
}

/**
 * Iterates through the provided `TIOData` inputs, matching them to the model's input layers, and
 * copies their bytes to those input layers.
 *
 * @param data Any class conforming to the `TIOData` protocol
 */

- (NamedTensors)_prepareInput:(id<TIOData>)data  {
    NamedTensors inputs;
    
    // Assuming data is a dictionary, which I may enforce in an api change
    
    NSDictionary<NSString*,id<TIOData>> *dictionaryData = (NSDictionary*)data;
    
    for ( NSString *name in dictionaryData ) {
        assert([_namedInputInterfaces.allKeys containsObject:name]);
    
        TIOLayerInterface *interface = _namedInputInterfaces[name];
        id<TIOData> inputData = dictionaryData[name];
    
        NamedTensor input = [self _prepareInput:inputData interface:interface];
        inputs.push_back(input);
    }
    
    return inputs;
}

/**
 * Requests the input to copy its bytes to the tensor
 *
 * @param input The data whose bytes will be copied to the tensor
 * @param interface A description of the data which the tensor expects
 */

- (NamedTensor)_prepareInput:(id<TIOData>)input interface:(TIOLayerInterface*)interface {
    __block NamedTensor named_tensor;
    
    // size_t byteSize = self.quantized ? sizeof(uint8_t) : sizeof(float_t);

    [interface
        matchCasePixelBuffer:^(TIOPixelBufferLayerDescription *pixelBufferDescription) {
            
            assert( [input isKindOfClass:TIOPixelBuffer.class] );
            
            // size_t byteCount
            //     = pixelBufferDescription.shape.width
            //     * pixelBufferDescription.shape.height
            //     * pixelBufferDescription.shape.channels
            //     * byteSize;
            
            // [(id<TIOTFLiteData>)input getBytes:tensor length:byteCount description:pixelBufferDescription];
            
            tensorflow::Tensor tensor = [(id<TIOTensorFlowData>)input tensorWithDescription:pixelBufferDescription];
            std::string name = interface.name.UTF8String;
            
            named_tensor = NamedTensor(name, tensor);
            
        } caseVector:^(TIOVectorLayerDescription *vectorDescription) {
            
            assert( [input isKindOfClass:NSArray.class]
                ||  [input isKindOfClass:NSData.class]
                ||  [input isKindOfClass:NSNumber.class] );
            
            // size_t byteCount
            //     = vectorDescription.length
            //     * byteSize;
            
            // [(id<TIOTFLiteData>)input getBytes:tensor length:byteCount description:vectorDescription];
        }];
    
    return named_tensor;
}

/**
 * Runs inference on the model. Inputs must be copied to the input tensors prior to calling this method
 */

- (Tensors)_runInference:(NamedTensors)inputs {
    TensorNames output_names;
    Tensors outputs;
    
    // TODO: Construct output names from json names
    
    output_names.push_back("sigmoid");
    
    tensorflow::Session *session = _saved_model_bundle.session.get();
    TF_CHECK_OK(session->Run(inputs, output_names, {}, &outputs));
    
    return outputs;
}

/**
 * Captures outputs from the model.
 *
 * @return TIOData A class that is appropriate to the model output. Currently all outputs are
 * wrapped in an instance of `NSDictionary` whose keys are taken from the json description of the
 * model outputs.
 */

- (id<TIOData>)_captureOutput:(Tensors)outputs {
    
    // TODO: Properly capture outputs, supporting quantization
    
    float sigmoid = outputs[0].scalar<float>()(0);
    
    return @{
        @"sigmoid": @(sigmoid)
    };
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
