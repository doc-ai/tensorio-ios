//
//  TIOMockTrainableModel.m
//  TensorIO_Example
//
//  Created by Phil Dow on 5/20/19.
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

#import "TIOMockTrainableModel.h"

@implementation TIOMockTrainableModel

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)initMock {
    if ((self=[super init])) {
    
    }
    return self;
}

#pragma GCC diagnostic pop

+ (nullable instancetype)modelWithBundleAtPath:(NSString*)path {
    return [[TIOMockTrainableModel alloc] initWithBundle:[[TIOModelBundle alloc] initWithPath:path]];
}

- (nullable instancetype)initWithBundle:(TIOModelBundle*)bundle {
    if ((self=[super init])) {
        _runCount = 0;
        _trainCount = 0;
    }
    return self;
}

- (BOOL)load:(NSError**)error {
    return YES;
}

- (void)unload {

}

- (id<TIOData>)runOn:(id<TIOData>)input {
    _runCount++;
    
    // Dummy value
    return @{};
}

- (id<TIOLayerDescription>)descriptionOfInputAtIndex:(NSUInteger)index {
    // Dummy value
    return [[TIOVectorLayerDescription alloc] initWithShape:@[] batched:NO dtype:(TIODataTypeFloat32) labels:nil quantized:NO quantizer:nil dequantizer:nil];
}
- (id<TIOLayerDescription>)descriptionOfInputWithName:(NSString*)name {
    // Dummy value
    return [[TIOVectorLayerDescription alloc] initWithShape:@[] batched:NO dtype:(TIODataTypeFloat32) labels:nil quantized:NO quantizer:nil dequantizer:nil];
}
- (id<TIOLayerDescription>)descriptionOfOutputAtIndex:(NSUInteger)index {
    // Dummy value
    return [[TIOVectorLayerDescription alloc] initWithShape:@[] batched:NO dtype:(TIODataTypeFloat32) labels:nil quantized:NO quantizer:nil dequantizer:nil];
}
- (id<TIOLayerDescription>)descriptionOfOutputWithName:(NSString*)name {
    // Dummy value
    return [[TIOVectorLayerDescription alloc] initWithShape:@[] batched:NO dtype:(TIODataTypeFloat32) labels:nil quantized:NO quantizer:nil dequantizer:nil];
}

- (id<TIOData>)train:(TIOBatch*)batch {
    _trainCount++;
    
    // Dummy value
    return @{};
}

- (BOOL)exportTo:(NSURL*)fileURL error:(NSError**)error {
    return YES;
}

@end
