//
//  NSArray+TIOTFLiteData.mm
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

#import "NSArray+TIOTFLiteData.h"

#import "TIOVectorLayerDescription.h"
#import "TIOScalarLayerDescription.h"

#import "TFLTensorFlowLite.h"

@implementation NSArray (TIOTFLiteData)

- (nullable instancetype)initWithBytes:(TFLTensor *)tensor description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription *)description).dequantizer;
    NSUInteger length = ((TIOVectorLayerDescription *)description).length;
    NSMutableArray *array = NSMutableArray.array;
    
    NSError *liteError = nil;
    NSData *data = [tensor dataWithError:&liteError];
    
    if (!data) {
        NSLog(@"There was a problem reading the data buffer from the tensor, error: %@", liteError);
        return nil;
    }
    
    const void *bytes = data.bytes;
    
    if ( description.isQuantized && dequantizer != nil ) {
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(dequantizer(((uint8_t *)bytes)[i]))];
        }
    } else if ( description.isQuantized && dequantizer == nil ) {
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(((uint8_t *)bytes)[i])];
        }
    } else {
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(((float_t *)bytes)[i])];
        }
    }

    return [self initWithArray:array];
}

- (void)getBytes:(TFLTensor *)tensor description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]
        || [description isKindOfClass:TIOScalarLayerDescription.class]);
    
    if ([description isKindOfClass:TIOScalarLayerDescription.class]) {
        assert(self.count == 1);
    }

    TIODataQuantizer quantizer = ((TIOVectorLayerDescription *)description).quantizer;

    // TODO: Cache data object so we aren't always mallocing and freeing memory
    // This is the what we do in the JNI implementation on Android: NSMutableData.mutableData
    // The model instance manages buffers and passes them to the data converters
    
    NSMutableData *data = [NSArray dataForDescription:description];
    void *buffer = data.mutableBytes;
    
//    size_t length = self.count;
//    size_t size = 0;
//
//    if ( description.isQuantized && quantizer != nil ) {
//        size = length * sizeof(uint8_t);
//    } else  if ( description.isQuantized && quantizer == nil ) {
//        size = length * sizeof(uint8_t);
//    } else {
//        size = length * sizeof(float_t);
//    }
//
//    void *buffer = malloc(size);

    if ( description.isQuantized && quantizer != nil ) {
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((uint8_t *)buffer)[i] = quantizer(((NSNumber *)self[i]).floatValue);
        }
    } else  if ( description.isQuantized && quantizer == nil ) {
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((uint8_t *)buffer)[i] = ((NSNumber *)self[i]).unsignedCharValue;
        }
    } else {
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((float_t *)buffer)[i] = ((NSNumber *)self[i]).floatValue;
        }
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
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription *)description).quantizer;
    
    size_t length = 0;
    size_t size = 0;
    
    if ( [description isKindOfClass:TIOVectorLayerDescription.class] ) {
        length = ((TIOVectorLayerDescription *)description).length;
    } else if ( [description isKindOfClass:TIOScalarLayerDescription.class] ) {
        length = 1;
    }
    
    if ( description.isQuantized && quantizer != nil ) {
        size = length * sizeof(uint8_t);
    } else  if ( description.isQuantized && quantizer == nil ) {
        size = length * sizeof(uint8_t);
    } else {
        size = length * sizeof(float_t);
    }
    
    return [NSMutableData dataWithLength:size];
}

@end
