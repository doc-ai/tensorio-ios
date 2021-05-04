//
//  NSDictionary+TIOTFLiteData.h
//  TensorIO
//
//  Created by Philip Dow on 8/6/18.
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

@class TFLTensor;

NS_ASSUME_NONNULL_BEGIN

/**
 * `NSDictionary` conforms to `TIOTFLiteData` so that it may be passed as input to a
 * model and returned as output from a model.
 *
 * @warning
 * A dictionary can neither provide bytes directly to nor capture bytes directly
 * from a TFLite tensor. Instead the named entries of the dictionary must be able
 * to do so.
 */

@interface NSDictionary (TIOTFLiteData) <TIOTFLiteData>

/**
 * Initializes an `NSDictionary` object with bytes from a TFLite tensor.
 *
 * @param tensor The output tensor to read from.
 * @param description A description of the data this buffer produces.
 *
 * @return instancetype An empty dictionary.
 *
 * @warning This method is unimplemented. A dictionary cannot be constructed directly from a tensor.
 */

- (nullable instancetype)initWithBytes:(TFLTensor *)tensor description:(id<TIOLayerDescription>)description;

/**
 * Request to fill a TFLite tensor with bytes.
 *
 * @param tensor The input tensor to copy bytes to.
 * @param description A description of the data this buffer expects.
 *
 * @warning This method is unimplemented. A dictionary cannot provide bytes directly to a tensor.
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
