//
//  NSNumber+TIOTFLiteData.mm
//  TensorIO
//
//  Created by Philip Dow on 8/4/18.
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

#import "NSNumber+TIOTFLiteData.h"

#import "TIOVectorLayerDescription.h"
#import "TIOScalarLayerDescription.h"

@implementation NSNumber (TIOTFLiteData)

- (nullable instancetype)initWithData:(NSData *)data description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    TIODataType dtype = TIODataTypeUnknown;
    TIODataDequantizer dequantizer;
    
    if ([description isKindOfClass:TIOVectorLayerDescription.class]) {
         dequantizer = ((TIOVectorLayerDescription *)description).dequantizer;
         dtype = ((TIOVectorLayerDescription *)description).dtype;
    } else if ([description isKindOfClass:TIOScalarLayerDescription.class]) {
        dequantizer = ((TIOScalarLayerDescription *)description).dequantizer;
        dtype = ((TIOScalarLayerDescription *)description).dtype;
    }
    
    const void *bytes = data.bytes;
    
    if ( description.isQuantized && dequantizer != nil ) {
        return [self initWithFloat:dequantizer(((uint8_t *)bytes)[0])];
    } else if ( description.isQuantized && dequantizer == nil ) {
        return [self initWithUnsignedChar:((uint8_t *)bytes)[0]];
    } else if ( dtype == TIODataTypeInt32 ) {
        return [self initWithLong:((uint32_t *)bytes)[0]];
    } else if ( dtype == TIODataTypeInt64 ) {
        return [self initWithLongLong:((uint64_t *)bytes)[0]];
    } else {
        return [self initWithFloat:((float_t *)bytes)[0]];
    }
}

- (NSData *)dataForDescription:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    TIODataType dtype = TIODataTypeUnknown;
    TIODataQuantizer quantizer;
    
    if ([description isKindOfClass:TIOVectorLayerDescription.class]) {
        quantizer = ((TIOVectorLayerDescription *)description).quantizer;
        dtype = ((TIOVectorLayerDescription *)description).dtype;
    } else if ([description isKindOfClass:TIOScalarLayerDescription.class]) {
        quantizer = ((TIOScalarLayerDescription *)description).quantizer;
        dtype = ((TIOScalarLayerDescription *)description).dtype;
    }
    
    // TODO: Cache data object so we aren't always mallocing and freeing memory
    // This is the what we do in the JNI implementation on Android: NSMutableData.mutableData
    // The model instance manages buffers and passes them to the data converters
    
    NSMutableData *data = [NSNumber bufferForDescription:description];
    void *buffer = data.mutableBytes;
    
    if ( description.isQuantized && quantizer != nil ) {
        ((uint8_t *)buffer)[0] = quantizer(self.floatValue);
    } else if ( description.isQuantized && quantizer == nil ) {
        ((uint8_t *)buffer)[0] = self.unsignedCharValue;
    } else if ( dtype == TIODataTypeInt32 ) {
        ((int32_t *)buffer)[0] = (int32_t)self.longValue;
    } else if ( dtype == TIODataTypeInt64 ) {
        ((int64_t *)buffer)[0] = (int64_t)self.longLongValue;
    } else {
        ((float_t *)buffer)[0] = self.floatValue;
    }
    
    return data;
}

+ (NSMutableData *)bufferForDescription:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    TIODataType dtype = TIODataTypeUnknown;
    TIODataQuantizer quantizer;
    
    // TODO: Just refactor this up to the TIOLayerDescription
    
    if ([description isKindOfClass:TIOVectorLayerDescription.class]) {
        quantizer = ((TIOVectorLayerDescription *)description).quantizer;
        dtype = ((TIOVectorLayerDescription *)description).dtype;
    } else if ([description isKindOfClass:TIOScalarLayerDescription.class]) {
        quantizer = ((TIOScalarLayerDescription *)description).quantizer;
        dtype = ((TIOScalarLayerDescription *)description).dtype;
    }
    
    size_t length = 1;
    size_t size = 0;
    
    if ( description.isQuantized && quantizer != nil ) {
        size = length * sizeof(uint8_t);
    } else if ( description.isQuantized && quantizer == nil ) {
        size = length * sizeof(uint8_t);
    } else if ( dtype == TIODataTypeInt32 ) {
        size = length * sizeof(int32_t);
    } else if ( dtype == TIODataTypeInt64 ) {
        size = length * sizeof(int64_t);
    } else {
        size = length * sizeof(float_t);
    }
    
    return [NSMutableData dataWithLength:size];
}

@end
