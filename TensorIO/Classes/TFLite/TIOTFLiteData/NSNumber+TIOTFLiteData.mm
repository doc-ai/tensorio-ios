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

#import "TFLTensorFlowLite.h"

@implementation NSNumber (TIOTFLiteData)

- (nullable instancetype)initWithBytes:(TFLTensor *)tensor description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    TIODataDequantizer dequantizer;
    
    if ([description isKindOfClass:TIOVectorLayerDescription.class]) {
         dequantizer = ((TIOVectorLayerDescription *)description).dequantizer;
    } else if ([description isKindOfClass:TIOScalarLayerDescription.class]) {
        dequantizer = ((TIOScalarLayerDescription *)description).dequantizer;
    }
    
    NSError *liteError = nil;
    NSData *data = [tensor dataWithError:&liteError];
    
    if (!data) {
        NSLog(@"There was a problem reading the data buffer from the tensor, error: %@", liteError);
        return nil;
    }
    
    const void *bytes = data.bytes;
    
    if ( description.isQuantized && dequantizer != nil ) {
        return [self initWithFloat:dequantizer(((uint8_t *)bytes)[0])];
    } else if ( description.isQuantized && dequantizer == nil ) {
        return [self initWithUnsignedChar:((uint8_t *)bytes)[0]];
    } else {
        return [self initWithFloat:((float_t *)bytes)[0]];
    }
}

- (void)getBytes:(TFLTensor *)tensor description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    TIODataQuantizer quantizer;
    
    if ([description isKindOfClass:TIOVectorLayerDescription.class]) {
        quantizer = ((TIOVectorLayerDescription *)description).quantizer;
    } else if ([description isKindOfClass:TIOScalarLayerDescription.class]) {
        quantizer = ((TIOScalarLayerDescription *)description).quantizer;
    }
    
    // TODO: Cache data object so we aren't always mallocing and freeing memory
    // This is the what we do in the JNI implementation on Android: NSMutableData.mutableData
    // The model instance manages buffers and passes them to the data converters
    
    NSMutableData *data = [NSNumber dataForDescription:description];
    void *buffer = data.mutableBytes;
    
//    size_t length = 1;
//    size_t size = 0;
//
//    if ( description.isQuantized && quantizer != nil ) {
//        size = length * sizeof(uint8_t);
//    } else if ( description.isQuantized && quantizer == nil ) {
//        size = length * sizeof(uint8_t);
//    } else {
//        size = length * sizeof(float_t);
//    }
//
//    void *buffer = malloc(size);
    
    if ( description.isQuantized && quantizer != nil ) {
        ((uint8_t *)buffer)[0] = quantizer(self.floatValue);
    } else if ( description.isQuantized && quantizer == nil ) {
        ((uint8_t *)buffer)[0] = self.unsignedCharValue;
    } else {
        ((float_t *)buffer)[0] = self.floatValue;
    }
    
//    NSData *data = [NSData dataWithBytes:buffer length:size];
    NSError *liteError = nil;
    
    if ( ![tensor copyData:data error:&liteError] ) {
        NSLog(@"There was a problem writing the data buffer to the tensor, error: %@", liteError);
    }

//    free(buffer);
}

+ (NSMutableData *)dataForDescription:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    TIODataQuantizer quantizer;
    
    if ([description isKindOfClass:TIOVectorLayerDescription.class]) {
        quantizer = ((TIOVectorLayerDescription *)description).quantizer;
    } else if ([description isKindOfClass:TIOScalarLayerDescription.class]) {
        quantizer = ((TIOScalarLayerDescription *)description).quantizer;
    }
    
    size_t length = 1;
    size_t size = 0;
    
    if ( description.isQuantized && quantizer != nil ) {
        size = length * sizeof(uint8_t);
    } else if ( description.isQuantized && quantizer == nil ) {
        size = length * sizeof(uint8_t);
    } else {
        size = length * sizeof(float_t);
    }
    
    return [NSMutableData dataWithLength:size];
}

@end
