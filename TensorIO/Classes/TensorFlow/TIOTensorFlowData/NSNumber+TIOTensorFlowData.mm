//
//  NSNumber+TIOTensorFlowData.m
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

//  TODO: Must be able to support other data types, specifically tensorflow::int32

#import "NSNumber+TIOTensorFlowData.h"
#import "TIOVectorLayerDescription.h"

#include <vector>

@implementation NSNumber (TIOTensorFlowData)

- (tensorflow::Tensor)tensorWithDescription:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;
    tensorflow::TensorShape shape = tensorflow::TensorShape({1,1});
    
    if ( description.isQuantized && quantizer != nil ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto labels_mapped = tensor.tensor<tensorflow::int8, 2>();
        labels_mapped(0,0) = quantizer(self.floatValue);
        return tensor;
    } else if ( description.isQuantized && quantizer == nil ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        auto labels_mapped = tensor.tensor<tensorflow::int8, 2>();
        labels_mapped(0,0) = self.unsignedCharValue;
        return tensor;
    } else {
        tensorflow::Tensor tensor(tensorflow::DT_FLOAT, shape);
        auto labels_mapped = tensor.tensor<float, 2>();
        labels_mapped(0,0) = self.floatValue;
        return tensor;
    }
}

@end
