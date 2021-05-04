//
//  NSData+TIOTFLiteData.mm
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
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

#import "NSData+TIOTFLiteData.h"

#import "TIOVectorLayerDescription.h"
#import "TIOStringLayerDescription.h"
#import "TIOScalarLayerDescription.h"
#import "TIODataTypes.h"

@implementation NSData (TIOTFLiteData)

- (nullable instancetype)initWithData:(NSData *)data description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOStringLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    const void *bytes = data.bytes;
    
    if ( [description isKindOfClass:TIOVectorLayerDescription.class] ) {
        TIODataDequantizer dequantizer = ((TIOVectorLayerDescription *)description).dequantizer;
        NSUInteger length = ((TIOVectorLayerDescription *)description).length;

        if ( description.isQuantized && dequantizer != nil ) {
            size_t dest_size = length * sizeof(float_t);
            float_t *buffer = (float_t *)malloc(dest_size);
            for ( NSInteger i = 0; i < length; i++ ) {
                ((float_t *)buffer)[i] = dequantizer(((uint8_t *)bytes)[i]);
            }
            NSData *data = [[NSData alloc] initWithBytes:buffer length:dest_size];
            free(buffer);
            return data;
        } else if ( description.isQuantized && dequantizer == nil ) {
            size_t dest_size = length * sizeof(uint8_t);
            return [[NSData alloc] initWithBytes:bytes length:dest_size];
        } else {
            size_t dest_size = length * sizeof(float_t);
            return [[NSData alloc] initWithBytes:bytes length:dest_size];
        }

    } else if ( [description isKindOfClass:TIOStringLayerDescription.class] ) {
        NSUInteger length = ((TIOStringLayerDescription *)description).length;
        TIODataType dtype = ((TIOStringLayerDescription *)description).dtype;

        switch (dtype) {
        case TIODataTypeUInt8: {
            size_t dest_size = length * sizeof(uint8_t);
            return [[NSData alloc] initWithBytes:bytes length:dest_size];
        }
        break;
        case TIODataTypeFloat32: {
            size_t dest_size = length * sizeof(float_t);
            return [[NSData alloc] initWithBytes:bytes length:dest_size];
        }
        break;
        default: {
            @throw [NSException exceptionWithName:@"Unsupported Data Type" reason:nil userInfo:nil];
            return nil;
        }
        break;
        }

    } else if ( [description isKindOfClass:TIOScalarLayerDescription.class] ) {
        TIODataDequantizer dequantizer = ((TIOVectorLayerDescription *)description).dequantizer;
        NSUInteger length = ((TIOVectorLayerDescription *)description).length;

        if ( description.isQuantized && dequantizer != nil ) {
            size_t dest_size = length * sizeof(float_t);
            float_t *buffer = (float_t *)malloc(dest_size);
            for ( NSInteger i = 0; i < length; i++ ) {
                ((float_t *)buffer)[i] = dequantizer(((uint8_t *)bytes)[i]);
            }
            NSData *data = [[NSData alloc] initWithBytes:buffer length:dest_size];
            free(buffer);
            return data;
        } else if ( description.isQuantized && dequantizer == nil ) {
            size_t dest_size = length * sizeof(uint8_t);
            return [[NSData alloc] initWithBytes:bytes length:dest_size];
        } else {
            size_t dest_size = length * sizeof(float_t);
            return [[NSData alloc] initWithBytes:bytes length:dest_size];
        }
    }

    else {
        @throw [NSException exceptionWithName:@"Unsupported Layer Description" reason:nil userInfo:nil];
        return nil;
    }
}

- (NSData *)dataForDescription:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOStringLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    // TODO: Cache data object so we aren't always mallocing and freeing memory
    // This is the what we do in the JNI implementation on Android: NSMutableData.mutableData
    // The model instance manages buffers and passes them to the data converters
    
    NSMutableData *data = [NSData bufferForDescription:description];
    void *buffer = data.mutableBytes;
    
    if ( [description isKindOfClass:TIOVectorLayerDescription.class] ) {
        TIODataQuantizer quantizer = ((TIOVectorLayerDescription *)description).quantizer;
        NSUInteger length = ((TIOVectorLayerDescription *)description).length;

        if ( description.isQuantized && quantizer != nil ) {
            float_t *bytes = (float_t *)self.bytes;
            for ( NSInteger i = 0; i < length; i++ ) {
                ((uint8_t *)buffer)[i] = quantizer(bytes[i]);
            }
        } else if ( description.isQuantized && quantizer == nil ) {
            size_t src_size = length * sizeof(uint8_t);
            [self getBytes:buffer length:src_size];
        } else {
            size_t src_size = length * sizeof(float_t);
            [self getBytes:buffer length:src_size];
        }

    } else if ( [description isKindOfClass:TIOStringLayerDescription.class] ) {
        NSUInteger length = ((TIOStringLayerDescription *)description).length;
        TIODataType dtype = ((TIOStringLayerDescription *)description).dtype;

        switch (dtype) {
        case TIODataTypeUInt8: {
            size_t src_size = length * sizeof(uint8_t);
            [self getBytes:buffer length:src_size];
        }
        break;
        case TIODataTypeFloat32: {
            size_t src_size = length * sizeof(float_t);
            [self getBytes:buffer length:src_size];
        }
        break;
        default: {
            @throw [NSException exceptionWithName:@"Unsupported Data Type" reason:nil userInfo:nil];
        }
        break;
        }

    } else if ( [description isKindOfClass:TIOScalarLayerDescription.class] ) {
        TIODataQuantizer quantizer = ((TIOVectorLayerDescription *)description).quantizer;
        NSUInteger length = ((TIOVectorLayerDescription *)description).length;

        if ( description.isQuantized && quantizer != nil ) {
            float_t *bytes = (float_t *)self.bytes;
            for ( NSInteger i = 0; i < length; i++ ) {
                ((uint8_t *)buffer)[i] = quantizer(bytes[i]);
            }
        } else if ( description.isQuantized && quantizer == nil ) {
            size_t src_size = length * sizeof(uint8_t);
            [self getBytes:buffer length:src_size];
        } else {
            size_t src_size = length * sizeof(float_t);
            [self getBytes:buffer length:src_size];
        }
    } else {
        @throw [NSException exceptionWithName:@"Unsupported Layer Description" reason:nil userInfo:nil];
    }
    
    return data;
}

+ (NSMutableData *)bufferForDescription:(id<TIOLayerDescription>)description {
    
    size_t size = 0;
    
    if ( [description isKindOfClass:TIOVectorLayerDescription.class] ) {
        TIODataQuantizer quantizer = ((TIOVectorLayerDescription *)description).quantizer;
        size_t length = ((TIOVectorLayerDescription *)description).length;
        
        if ( description.isQuantized && quantizer != nil ) {
            size = length * sizeof(uint8_t);
        } else if ( description.isQuantized && quantizer == nil ) {
            size = length * sizeof(uint8_t);
        } else {
            size = length * sizeof(float_t);
        }
        
    } else if ( [description isKindOfClass:TIOStringLayerDescription.class] ) {
        TIODataType dtype = ((TIOStringLayerDescription *)description).dtype;
        size_t length = ((TIOStringLayerDescription *)description).length;
        
        switch (dtype) {
        case TIODataTypeUInt8: {
            size = length * sizeof(uint8_t);
        }
        break;
        case TIODataTypeFloat32: {
            size = length * sizeof(float_t);
        }
        break;
        default: {
            @throw [NSException exceptionWithName:@"Unsupported Data Type" reason:nil userInfo:nil];
        }
        break;
        }
        
    } else if ( [description isKindOfClass:TIOScalarLayerDescription.class] ) {
        TIODataQuantizer quantizer = ((TIOVectorLayerDescription *)description).quantizer;
        size_t length = ((TIOVectorLayerDescription *)description).length;
        
        if ( description.isQuantized && quantizer != nil ) {
            size = length * sizeof(uint8_t);
        } else if ( description.isQuantized && quantizer == nil ) {
            size = length * sizeof(uint8_t);
        } else {
            size = length * sizeof(float_t);
        }
    } else {
        @throw [NSException exceptionWithName:@"Unsupported Data Type" reason:nil userInfo:nil];
    }
    
    return [NSMutableData dataWithLength:size];
}

@end
