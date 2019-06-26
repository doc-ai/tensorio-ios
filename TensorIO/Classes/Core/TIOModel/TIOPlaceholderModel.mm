//
//  TIOPlaceholderModel.m
//  TensorIO
//
//  Created by Philip Dow on 1/11/19.
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

#import "TIOPlaceholderModel.h"

#import "TIOLayerInterface.h"
#import "TIOModelBundle.h"
#import "TIOData.h"
#import "TIOLayerInterface.h"
#import "TIOLayerDescription.h"
#import "TIOPixelBufferLayerDescription.h"
#import "TIOVectorLayerDescription.h"
#import "TIOModelJSONParsing.h"
#import "TIOModelIO.h"

@implementation TIOPlaceholderModel

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
        
        NSArray<TIOLayerInterface*> *inputInterfaces = [self _parseIO:bundle.info[@"inputs"] isInput:YES];
        
        if ( !inputInterfaces ) {
            NSLog(@"Unable to parse input field in model.json");
            return nil;
        }
        
        NSArray<TIOLayerInterface*> *outputInterfaces = [self _parseIO:bundle.info[@"outputs"] isInput:NO];
        
        if ( !outputInterfaces ) {
            NSLog(@"Unable to parse output field in model.json");
            return nil;
        }
        
        _io = [[TIOModelIO alloc] initWithInputInterfaces:inputInterfaces ouputInterfaces:outputInterfaces];
    }
    
    return self;
}

// MARK: - JSON Parsing
// TODO: Move JSON Parsing to an external function or to the model bundle class

/**
 * Enumerates through the JSON description of a model's inputs or outputs and
 * constructs a `TIOLayerInterface` for each one.
 *
 * @param io An array of dictionaries describing the model's input or output layers
 * @param isInput A boolean value indicating if the io descriptions or for the input or output
 * @return NSArray An array of `TIOLayerInterface` matching the descriptions, or `nil` if parsing failed
 */

- (nullable NSArray<TIOLayerInterface*> *)_parseIO:(NSArray<NSDictionary<NSString*,id>*>*)io isInput:(BOOL)isInput {
    
    static NSString * const kTensorTypeVector = @"array";
    static NSString * const kTensorTypeImage = @"image";
    
    NSMutableArray<TIOLayerInterface*> *interfaces = NSMutableArray.array;
    BOOL isQuantized = self.quantized;
    
    __block BOOL error = NO;
    [io enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull input, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *type = input[@"type"];
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
        
        [interfaces addObject:interface];
    }];
    
    return error ? nil : interfaces.copy;
}

// MARK: - Model Memory Management

/**
 * Loads a model into memory and sets `loaded` = `YES`. A placeholder model does nothing here.
 */

- (BOOL)load:(NSError**)error {
    _loaded = YES;
    return YES;
}

/**
 * Unloads the model and sets `loaded` =`NO`. A placeholder model doest nothing here.
 */

- (void)unload {
    _loaded = NO;
}

// MARK: - Input and Output Features

- (NSArray<TIOLayerInterface*>*)inputs {;
    return self.io.inputs.all;
}

- (NSArray<TIOLayerInterface*>*)outputs {
    return self.io.outputs.all;
}

- (id<TIOLayerDescription>)descriptionOfInputAtIndex:(NSUInteger)index {
    return self.io.inputs[index].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfInputWithName:(NSString*)name {
    return self.io.inputs[name].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfOutputAtIndex:(NSUInteger)index {
    return self.io.outputs[index].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfOutputWithName:(NSString*)name {
    return self.io.outputs[name].dataDescription;
}

// MARK: - Perform Inference

/**
 * A placeholder model performs no inference and returns an empty dictionary
 */

- (id<TIOData>)runOn:(id<TIOData>)input {
    return @{};
}

@end
