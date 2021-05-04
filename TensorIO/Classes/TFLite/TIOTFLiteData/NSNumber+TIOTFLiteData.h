//
//  NSNumber+TIOTFLiteData.h
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

#import <Foundation/Foundation.h>

#import "TIOLayerDescription.h"
#import "TIOTFLiteData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An `NSNumber` can provide a single value to a TFLite tensor or accepts a
 * single value from a TFLite tensor.
 */

@interface NSNumber (TIOTFLiteData) <TIOTFLiteData>

/**
 * Initializes an `NSNumber` with bytes from a TFLite tensor.
 *
 * Bytes are copied according to the following rules, with information about quantization taken
 * from the description:
 *
 * - If the layer is unquantized, the tensor's bytes are copied directly into a numeric object
 *   (the bytes are implicitly interpreted as `float_t` values)
 *
 * - If the layer is quantized and no dequantizer block is provided, the tensor's bytes are copied
 *   directly into a numeric object (the bytes are implicitly interpreted as `uint8_t` values)
 *
 * - If the layer is quantized and a dequantizer block is provided, the tensor's bytes are
 *   interpreted as `uint8_t` values, passed to the dequantizer block, and the resulting `float_t`
 *   bytes are copied into a numeric object
 *
 * @param data NSData to read from taken from an output tensor.
 * @param description A description of the data this buffer produces.
 *
 * @return instancetype An instance of `NSNumber`.
 */

- (nullable instancetype)initWithData:(NSData *)data description:(id<TIOLayerDescription>)description;

/**
 * Requests that a conforming object fill an NSData object with bytes that can later be copied to a TFLTensor
 *
 * Bytes are copied according to the following rules, with information about quantization taken
 * from the description:
 *
 * - If the layer is unquantized, the number's `float_t` value is copied directly to the buffer
 *
 * - If the layer is quantized and no quantizer block is provided, the number's `uint8_t` value is
 *   copied directly to the buffer
 *
 * - If the layer is quantized and a quantizer block is provided, the number's `float_t` vlaue
 *   is passed to the quantizer block and the `uint8_t` value it returns is copied to the buffer
 *
 * @param description A description of the data this buffer expects.
 * @return NSData object filled with bytes that can be copied to a TFLTensor
 */

- (NSData *)dataForDescription:(id<TIOLayerDescription>)description;

/**
 * Returns a reusable data object for a given description. Call `mutableBytes` on the returned object to
 * acquire a pointer to the underlying data buffer, which you can fill with bytes.
 *
 *  @param description A description of the data this buffer expects.
 *  @return A re-usable data buffer.
 */

+ (NSMutableData *)bufferForDescription:(id<TIOLayerDescription>)description;

@end

NS_ASSUME_NONNULL_END
