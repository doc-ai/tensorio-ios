//
//  NSDictionary+TIOTensorFlowData.h
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

#import <Foundation/Foundation.h>

#import "TIOTensorFlowData.h"

namespace tensorflow {
    class Tensor;
}

NS_ASSUME_NONNULL_BEGIN

/**
 * `NSDictionary` conforms to `TIOTensorFlowData` so that it may be passed as input to a
 * model and returned as output from a model.
 *
 * @warning
 * A dictionary can neither provide bytes directly to nor capture bytes directly
 * from a TensorFlow tensor. Instead the named entries of the dictionary must be able
 * to do so.
 */

@interface NSDictionary (TIOTensorFlowData) <TIOTensorFlowData>

/**
 * Initializes an `NSDictionary` object with bytes from a TensorFlow tensor.
 *
 * @param tensor The tensor to read from.
 * @param description A description of the data this tensor produces.
 *
 * @return instancetype An empty dictionary.
 *
 * @warning This method is unimplemented. A dictionary cannot be constructed directly from a tensor.
 */

- (nullable instancetype)initWithTensor:(tensorflow::Tensor)tensor description:(id<TIOLayerDescription>)description;

/**
 * Request to fill a TensorFlow tensor with bytes.
 *
 * @param description A description of the data this tensor expects.
 *
 * @return tensorflow::Tensor A tensor with data from the dictionary.
 *
 * @warning This method is unimplemented. A dictionary cannot provide bytes directly to a tensor.
 */

- (tensorflow::Tensor)tensorWithDescription:(id<TIOLayerDescription>)description;

// MARK: - Batch (Training)

/**
 * Request to fill a TensorFlow tensor with bytes.
 *
 * @param column A batch of dictionaries.
 * @param description A description of the data this tensor expects.
 *
 * @return tensorflow::Tensor A tensor with data from the dictionary.
 *
 * @warning This method is unimplemented. A dictionary cannot provide bytes directly to a tensor.
 */

+ (tensorflow::Tensor)tensorWithColumn:(NSArray<id<TIOTensorFlowData>>*)column description:(id<TIOLayerDescription>)description;

@end

NS_ASSUME_NONNULL_END
