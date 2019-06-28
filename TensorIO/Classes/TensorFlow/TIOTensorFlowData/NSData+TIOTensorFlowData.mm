//
//  NSData+TIOTensorFlowData.m
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

#import "NSData+TIOTensorFlowData.h"
#import "TIOVectorLayerDescription.h"
#import "NSArray+TIOExtensions.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#include "tensorflow/core/framework/tensor.h"
#pragma clang diagnostic pop

@implementation NSData (TIOTensorFlowData)

- (nullable instancetype)initWithTensor:(tensorflow::Tensor)tensor description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription *)description).dequantizer;
    NSUInteger length = ((TIOVectorLayerDescription *)description).length;
    TIODataType dtype = ((TIOVectorLayerDescription *)description).dtype;
    
    if ( description.isQuantized && dequantizer != nil ) {
        size_t byte_count = length * sizeof(float_t);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto tensor_data = flat_tensor.data();
        float_t *buffer = (float_t *)malloc(byte_count);
        for ( NSInteger i = 0; i < length; i++ ) {
            ((float_t *)buffer)[i] = dequantizer(((uint8_t *)tensor_data)[i]);
        }
        NSData *data = [[NSData alloc] initWithBytes:buffer length:byte_count];
        free(buffer);
        return data;
    } else if ( description.isQuantized && dequantizer == nil ) {
        size_t tensor_byte_count = length * sizeof(uint8_t);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto tensor_data = flat_tensor.data();
        return [[NSData alloc] initWithBytes:tensor_data length:tensor_byte_count];
    } else if ( dtype == TIODataTypeInt32 ) {
        size_t tensor_byte_count = length * sizeof(int32_t);
        auto flat_tensor = tensor.flat<int32_t>();
        auto tensor_data = flat_tensor.data();
        return [[NSData alloc] initWithBytes:tensor_data length:tensor_byte_count];
    } else if ( dtype == TIODataTypeInt64 ) {
        size_t tensor_byte_count = length * sizeof(int64_t);
        auto flat_tensor = tensor.flat<int64_t>();
        auto tensor_data = flat_tensor.data();
        return [[NSData alloc] initWithBytes:tensor_data length:tensor_byte_count];
    } else {
        size_t tensor_byte_count = length * sizeof(float_t);
        auto flat_tensor = tensor.flat<float_t>();
        auto tensor_data = flat_tensor.data();
        return [[NSData alloc] initWithBytes:tensor_data length:tensor_byte_count];
    }
}

- (tensorflow::Tensor)tensorWithDescription:(id<TIOLayerDescription>)description {
    return [NSData tensorWithColumn:@[self] description:description];
}

// MARK: - Batch (Training)

+ (tensorflow::Tensor)tensorWithColumn:(NSArray<id<TIOTensorFlowData>>*)column description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription *)description).quantizer;
    TIODataType dtype = ((TIOVectorLayerDescription *)description).dtype;
    NSUInteger length = ((TIOVectorLayerDescription *)description).length;
    int32_t batch_size = (int32_t)column.count;
    
    // Establish shape
    
    std::vector<tensorflow::int64> dims;
    
    if ( description.isBatched ) {
        dims.push_back(batch_size);
    }
    
    for ( NSNumber *dim in description.shape.excludingBatch ) {
        dims.push_back(dim.integerValue);
    }
    
    tensorflow::gtl::ArraySlice<tensorflow::int64> dim_sizes(dims);
    tensorflow::TensorShape shape = tensorflow::TensorShape(dim_sizes);
    
    // Typed enumeration over the column
    
    if ( description.isQuantized && quantizer != nil ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *dataobj = (NSData *)obj;
            size_t offset = idx * length;
            float_t *bytes = (float_t *)dataobj.bytes;
            for ( NSInteger i = 0; i < length; i++ ) {
                ((uint8_t *)buffer)[offset+i] = quantizer(bytes[i]);
            }
        }];
        
        return tensor;
    } else if ( description.isQuantized && quantizer == nil ) {
        size_t tensor_byte_count = length * sizeof(uint8_t);
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto flat_tensor = tensor.flat<uint8_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *dataobj = (NSData *)obj;
            size_t offset = idx * length;
            [dataobj getBytes:(buffer+offset) length:tensor_byte_count];
        }];
        
        return tensor;
    } else if ( dtype == TIODataTypeInt32 ) {
        size_t tensor_byte_count = length * sizeof(int32_t);
        tensorflow::Tensor tensor(tensorflow::DT_INT32, shape);
        auto flat_tensor = tensor.flat<int32_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *dataobj = (NSData *)obj;
            size_t offset = idx * length;
            [dataobj getBytes:(buffer+offset) length:tensor_byte_count];
        }];
        
        return tensor;
    } else if ( dtype == TIODataTypeInt64 ) {
        size_t tensor_byte_count = length * sizeof(int64_t);
        tensorflow::Tensor tensor(tensorflow::DT_INT64, shape);
        auto flat_tensor = tensor.flat<int64_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *dataobj = (NSData *)obj;
            size_t offset = idx * length;
            [dataobj getBytes:(buffer+offset) length:tensor_byte_count];
        }];
        
        return tensor;
    } else {
        size_t tensor_byte_count = length * sizeof(float_t);
        tensorflow::Tensor tensor(tensorflow::DT_FLOAT, shape);
        auto flat_tensor = tensor.flat<float_t>();
        auto buffer = flat_tensor.data();
        
        [column enumerateObjectsUsingBlock:^(id<TIOTensorFlowData> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *dataobj = (NSData *)obj;
            size_t offset = idx * length;
            [dataobj getBytes:(buffer+offset) length:tensor_byte_count];
        }];
        
        return tensor;
    }
}

@end
