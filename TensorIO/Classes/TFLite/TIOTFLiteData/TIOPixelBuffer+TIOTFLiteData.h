//
//  TIOPixelBuffer+TIOTFLiteData.h
//  TensorIO
//
//  Created by Phil Dow on 4/8/19.
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
#import "TIOPixelBuffer.h"
#import "TIOTFLiteData.h"

@class TFLTensor;

NS_ASSUME_NONNULL_BEGIN

/**
 * An `TIOPixelBuffer` can provide pixel buffers to a TFLite tensor or read
 * pixel values from one.
 */

@interface TIOPixelBuffer (TIOTFLiteData) <TIOTFLiteData>

/**
 * Initializes `TIOPixelBuffer` with bytes from a TFLite tensor.
 *
 * @param tensor The output tensor to read from.
 * @param description A description of the data this buffer produces.
 *
 * @return instancetype An instance of `TIOPixelBuffer`
 */

- (nullable instancetype)initWithBytes:(TFLTensor *)tensor description:(id<TIOLayerDescription>)description;

/**
 * Request to fill a TFLite tensor with bytes.
 *
 * @param tensor The input tensor to copy bytes to.
 * @param description A description of the data this buffer expects.
 */

- (void)getBytes:(TFLTensor *)tensor description:(id<TIOLayerDescription>)description;

/**
 * Returns a reusable data object for a given description. Call `mutableBytes` on the returned object to
 * acquire a pointer to the underlying data buffer, which you can fill with bytes.
 *
 *  @param description A description of the data this buffer expects.
 *  @return A re-usable data buffer.
 */

+ (NSMutableData *)dataForDescription:(id<TIOLayerDescription>)description;


@end

NS_ASSUME_NONNULL_END
