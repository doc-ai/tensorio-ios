//
//  NSDictionary+TIOTensorFlowData.m
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

#import "NSDictionary+TIOTensorFlowData.h"

@implementation NSDictionary (TIOTensorFlowData)

- (nullable instancetype)initWithTensor:(tensorflow::Tensor)tensor description:(id<TIOLayerDescription>)description {
    NSAssert(NO, @"This method is unimplemented. A dictionary cannot be constructed directly from a tensor.");
    return [self init];
}

- (tensorflow::Tensor)tensorWithDescription:(id<TIOLayerDescription>)description {
    NSAssert(NO, @"This method is unimplemented. Tensor bytes cannot be captured from a dictionary.");
    return tensorflow::Tensor(tensorflow::DT_FLOAT, {});
}

@end
