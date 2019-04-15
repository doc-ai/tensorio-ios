//
//  NSNumber+TIOTensorFlowData.m
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

#import "NSNumber+TIOTensorFlowData.h"
#import "TIOVectorLayerDescription.h"

#include <vector>

@implementation NSNumber (TIOTensorFlowData)

- (nullable instancetype)initWithTensor:(tensorflow::Tensor)tensor description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription*)description).dequantizer;
    
    if ( description.isQuantized && dequantizer != nil ) {
        auto flat_tensor = tensor.flat<uint8_t>();
        auto tensor_data = flat_tensor.data();
        uint8_t value = tensor_data[0];
        return [self initWithFloat:dequantizer(value)];
    } else if ( description.isQuantized && dequantizer == nil ) {
        auto flat_tensor = tensor.flat<uint8_t>();
        auto tensor_data = flat_tensor.data();
        uint8_t value = tensor_data[0];
        return [self initWithUnsignedChar:value];
    } else {
        auto flat_tensor = tensor.flat<float_t>();
        auto tensor_data = flat_tensor.data();
        float_t value = tensor_data[0];
        return [self initWithFloat:value];
    }
}

- (tensorflow::Tensor)tensorWithDescription:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    // TODO: verify that the shape is either [1] or [-1,1] if batched
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;
    NSArray<NSNumber*> *dshape = ((TIOVectorLayerDescription*)description).shape;
    
    // Establish shape
    
    std::vector<tensorflow::int64> dims;
    
    // When the zeroeth dimension is -1 then this model expects a batch size to be included in its dimensions
    // Inference batch size is 1 by default
    
    for (NSNumber *dim in dshape) {
        if ( dim.integerValue == -1 ) {
            dims.push_back(1); // batch size of 1
        } else {
            dims.push_back(dim.integerValue);
        }
    }
    
    tensorflow::gtl::ArraySlice<tensorflow::int64> dim_sizes(dims);
    tensorflow::TensorShape shape = tensorflow::TensorShape(dim_sizes);
    
    if ( description.isQuantized && quantizer != nil ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto buffer = flat_tensor.data();
        buffer[0] = quantizer(self.floatValue);
        return tensor;
    } else if ( description.isQuantized && quantizer == nil ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto buffer = flat_tensor.data();
        buffer[0] = self.unsignedCharValue;
        return tensor;
    } else {
        tensorflow::Tensor tensor(tensorflow::DT_FLOAT, shape);
        auto flat_tensor = tensor.flat<float>();
        auto buffer = flat_tensor.data();
        buffer[0] = self.floatValue;
        return tensor;
    }
}

@end
