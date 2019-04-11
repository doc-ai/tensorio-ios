//
//  NSArray+TIOTensorFlowData.m
//  TensorIO
//
//  Created by Phil Dow on 4/10/19.
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

//  TODO: Must be able to support other data types, specifically tensorflow::int32

#import "NSArray+TIOTensorFlowData.h"
#import "TIOVectorLayerDescription.h"

#include <vector>

@implementation NSArray (TIOTensorFlowData)

- (nullable instancetype)initWithTensor:(tensorflow::Tensor)tensor description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription*)description).dequantizer;
    NSUInteger length = ((TIOVectorLayerDescription*)description).length;
    NSMutableArray *array = NSMutableArray.array;
    
    if ( description.isQuantized && dequantizer != nil ) {
        auto flat_tensor = tensor.flat<uint8_t>();
        auto tensor_data = flat_tensor.data();
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(dequantizer(((uint8_t *)tensor_data)[i]))];
        }
    } else if ( description.isQuantized && dequantizer == nil ) {
        auto flat_tensor = tensor.flat<uint8_t>();
        auto tensor_data = flat_tensor.data();
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(((uint8_t *)tensor_data)[i])];
        }
    } else {
        auto flat_tensor = tensor.flat<float_t>();
        auto tensor_data = flat_tensor.data();
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(((float_t *)tensor_data)[i])];
        }
    }
    
    return [self initWithArray:array];
}

- (tensorflow::Tensor)tensorWithDescription:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);

    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;
    NSArray<NSNumber*> *dshape = ((TIOVectorLayerDescription*)description).shape;
    
    // Establish shape
    
    std::vector<tensorflow::int64> dims;
    dims.push_back(1); // batch size
    
    for (NSNumber *dim in dshape) {
        dims.push_back(dim.integerValue);
    }
    
    tensorflow::gtl::ArraySlice<tensorflow::int64> dim_sizes(dims);
    tensorflow::TensorShape shape = tensorflow::TensorShape(dim_sizes);
    
    // Traverse array and copy bytes
    
    if ( description.isQuantized && quantizer != nil ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto buffer = flat_tensor.data();
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((uint8_t *)buffer)[i] = quantizer(((NSNumber*)self[i]).floatValue);
        }
        return tensor;
    } else if ( description.isQuantized && quantizer == nil ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto buffer = flat_tensor.data();
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((uint8_t *)buffer)[i] = ((NSNumber*)self[i]).unsignedCharValue;
        }
        return tensor;
    } else {
        tensorflow::Tensor tensor(tensorflow::DT_FLOAT, shape);
        auto flat_tensor = tensor.flat<float>();
        auto buffer = flat_tensor.data();
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((float_t *)buffer)[i] = ((NSNumber*)self[i]).floatValue;
        }
        return tensor;
    }
}

@end
