//
//  TIOTensorFlowData.h
//  TensorIO
//
//  Created by Phil Dow on 4/10/19.
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

#import "TIOData.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#include "tensorflow/core/framework/tensor.h"

#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@protocol TIOTensorFlowData <NSObject, TIOData>

// MARK: - Inference

/**
 * Initializes a conforming object with bytes from a TensorFlow tensor.
 *
 * @param tensor The output tensor to read from.
 * @param description A description of the data this buffer produces.
 *
 * @return instancetype An instance of the conforming data type.
 */

- (nullable instancetype)initWithTensor:(tensorflow::Tensor)tensor description:(id<TIOLayerDescription>)description;

/**
 * Requests that a conforming object create a TensorFlow tensor from its data.
 *
 * @param description A description of the data this tensor expects.
 *
 * @return tensorflow::Tensor A tensor with data from the type conforming to
 *  this protocol.
 */

- (tensorflow::Tensor)tensorWithDescription:(id<TIOLayerDescription>)description;

// MARK: - Training

/**
 * Requests that a conforming object create a TensorFlow tensor from an array of
 * data of this type.
 *
 * @param column An array of data of the type conforming to this protocol.
 * @param description A description of the data this tensor expects.
 *
 * @return tensorflow::Tensor A tensor with data from the type conforming to
 *  this protocol.
 */

+ (tensorflow::Tensor)tensorWithColumn:(NSArray<id<TIOTensorFlowData>>*)column description:(id<TIOLayerDescription>)description;

@end

NS_ASSUME_NONNULL_END
