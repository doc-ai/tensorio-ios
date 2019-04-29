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

//  TODO: Consider using templated c++ helpers
//  TODO: Refactor similarity between batched and unbatched tensor preparation (#62)

#import "NSNumber+TIOTensorFlowData.h"
#import "TIOVectorLayerDescription.h"

#include <vector>

@implementation NSNumber (TIOTensorFlowData)

- (nullable instancetype)initWithTensor:(tensorflow::Tensor)tensor description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription*)description).dequantizer;
    TIODataType dtype = ((TIOVectorLayerDescription*)description).dtype;
    
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
    } else if ( dtype == TIODataTypeInt32 ) {
        auto flat_tensor = tensor.flat<int32_t>();
        auto tensor_data = flat_tensor.data();
        int32_t value = tensor_data[0];
        return [self initWithLong:value];
    } else if ( dtype == TIODataTypeInt64 ) {
        auto flat_tensor = tensor.flat<int64_t>();
        auto tensor_data = flat_tensor.data();
        int64_t value = tensor_data[0];
        return [self initWithLongLong:value];
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
    TIODataType dtype = ((TIOVectorLayerDescription*)description).dtype;
    
    // Establish shape
    
    std::vector<tensorflow::int64> dims;
    
    // When the zeroeth dimension is -1 then this model expects a batch size to be included in its dimensions
    // Inference batch size is 1 by default
    
    for (NSNumber *dim in dshape) {
        if ( dim.integerValue == -1 ) {
            dims.push_back(1);
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
    } else if ( dtype == TIODataTypeInt32 ) {
        tensorflow::Tensor tensor(tensorflow::DT_INT32, shape);
        auto flat_tensor = tensor.flat<int32_t>();
        auto buffer = flat_tensor.data();
        buffer[0] = (int32_t)self.longValue;
        return tensor;
    } else if ( dtype == TIODataTypeInt64 ) {
        tensorflow::Tensor tensor(tensorflow::DT_INT64, shape);
        auto flat_tensor = tensor.flat<int64_t>();
        auto buffer = flat_tensor.data();
        buffer[0] = (int64_t)self.longLongValue;
        return tensor;
    } else {
        tensorflow::Tensor tensor(tensorflow::DT_FLOAT, shape);
        auto flat_tensor = tensor.flat<float_t>();
        auto buffer = flat_tensor.data();
        buffer[0] = self.floatValue;
        return tensor;
    }
}

// MARK: - Batch (Training)

+ (tensorflow::Tensor)tensorWithColumn:(NSArray<id<TIOTensorFlowData>>*)column description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    int32_t batch_size = (int32_t)column.count;
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;
    NSArray<NSNumber*> *dshape = ((TIOVectorLayerDescription*)description).shape;
    TIODataType dtype = ((TIOVectorLayerDescription*)description).dtype;
    NSUInteger length = ((TIOVectorLayerDescription*)description).length;
    
    // Establish shape
    
    std::vector<tensorflow::int64> dims;
    
    // When the zeroeth dimension is -1 convert the batch size placeholder to the actual batch size
    
    for (NSNumber *dim in dshape) {
        if ( dim.integerValue == -1 ) {
            dims.push_back(batch_size);
        } else {
            dims.push_back(dim.integerValue);
        }
    }
    
    tensorflow::gtl::ArraySlice<tensorflow::int64> dim_sizes(dims);
    tensorflow::TensorShape shape = tensorflow::TensorShape(dim_sizes);
    
    // Typed enumeration over the column
    
    if ( description.isQuantized && quantizer != nil ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            size_t offset = idx * length;
            buffer[offset] = quantizer(((NSNumber*)obj).floatValue);
        }];
        
        return tensor;
    } else if ( description.isQuantized && quantizer == nil ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            size_t offset = idx * length;
            buffer[offset] = ((NSNumber*)obj).unsignedCharValue;
        }];
        
        return tensor;
    } else if ( dtype == TIODataTypeInt32 ) {
        tensorflow::Tensor tensor(tensorflow::DT_INT32, shape);
        auto flat_tensor = tensor.flat<int32_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            size_t offset = idx * length;
            buffer[offset] = (int32_t)((NSNumber*)obj).longValue;
        }];
        
        return tensor;
    } else if ( dtype == TIODataTypeInt64 ) {
        tensorflow::Tensor tensor(tensorflow::DT_INT64, shape);
        auto flat_tensor = tensor.flat<int64_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            size_t offset = idx * length;
            buffer[offset] = (int64_t)((NSNumber*)obj).longLongValue;
        }];
        
        return tensor;
    } else {
        tensorflow::Tensor tensor(tensorflow::DT_FLOAT, shape);
        auto flat_tensor = tensor.flat<float_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            size_t offset = idx * length;
            buffer[offset] = ((NSNumber*)obj).floatValue;
        }];
        
        return tensor;
    }
}

@end
