//
//  TIOScalarLayerDescription.h
//  TensorIO
//
//  Created by Philip Dow on 2/4/21.
//  Copyright © 2021 doc.ai (http://doc.ai)
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

#import <Foundation/Foundation.h>

#import "TIOLayerDescription.h"
#import "TIOVector.h"
#import "TIOQuantization.h"
#import "TIODataTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOScalarLayerDescription : NSObject <TIOLayerDescription>

/**
 * `YES` if the layer is quantized, `NO` otherwise
 */

@property (readonly, getter=isQuantized) BOOL quantized;

/**
 * The shape of the underlying tensor, which may include a `-1` along the first or last axis
 * to indicate the batch dimension. A scalar layer's shape will always be either `[1]` or `[-1,1]`
 */

@property (readonly) NSArray<NSNumber*> *shape;

/**
 * `YES` if this tensor includes a dimension for the batch, `NO` otherwise.
 */

@property (readonly, getter=isBatched) BOOL batched;

// MARK: - TIOScalarLayerDescription Properties

/**
 * The layer's data type
 *
 * @warning
 * There are complex interactions between backends, data types, and quantization
 * that will be addressed and validated in later releases.
 */

@property (readonly) TIODataType dtype;

/**
 * The length of the vector in terms of its total number of elements. Calculated
 * as the product of the dimensions in `shape`. A dimension of -1 which acts as
 * placeholder for a batch size will be interpreted as a 1. The length of a scalar
 * layer will always be 1.
 */

@property (readonly) NSUInteger length;

/**
 * A function that converts a vector from unquantized values to quantized values
 */

@property (nullable, readonly) TIODataQuantizer quantizer;

/**
 * A function that converts a vector from quantized values to unquantized values
 */

@property (nullable, readonly) TIODataDequantizer dequantizer;

// MARK: - Init

/**
 * Designated initializer. Creates a vector description from the properties parsed in a model.json
 * file.
 *
 * @param shape The shape of the underlying tensor
 * @param batched `YES` if the underlying tensor supports batching
 * @param dtype The type of data this layer expects or produces
 * @param quantized `YES` if the underlying model is quantized, `NO` otherwise
 * @param quantizer A function that transforms unquantized values to quantized input
 * @param dequantizer A function that transforms quantized output to unquantized values
 *
 * @return instancetype A read-only instance of `TIOVectorLayerDescription`
 */

- (instancetype)initWithShape:(NSArray<NSNumber*>*)shape
    batched:(BOOL)batched
    dtype:(TIODataType)dtype
    quantized:(BOOL)quantized
    quantizer:(nullable TIODataQuantizer)quantizer
    dequantizer:(nullable TIODataDequantizer)dequantizer
    NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
