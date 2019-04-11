//
//  TIOPixelBuffer+TIOTensorFlowData.m
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

#import "TIOPixelBuffer+TIOTensorFlowData.h"
#import "TIOPixelBufferLayerDescription.h"
#import "TIOVisionPipeline.h"

template <typename T>
void TIOCopyCVPixelBufferToTensorFlowTensor(CVPixelBufferRef pixelBuffer, tensorflow::Tensor tensor, TIOImageVolume shape, _Nullable TIOPixelNormalizer normalizer) {
    auto image_mapped = tensor.tensor<T, 4>();
    
    CFRetain(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    
    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    const int bytes_per_row = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int image_width = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int image_height = (int)CVPixelBufferGetHeight(pixelBuffer);
    const int image_channels = 4; // by definition (ARGB, BGRA)
    const int tensor_channels = shape.channels; // should be 3 by definition (ARG, BGR)
    const int channel_offset = sourcePixelFormat == kCVPixelFormatType_32ARGB
        ? 1
        : 0;
    
    assert(sourcePixelFormat == kCVPixelFormatType_32ARGB
        || sourcePixelFormat == kCVPixelFormatType_32BGRA);
    
    assert(image_width == shape.width);
    assert(image_height == shape.height);
    assert(image_channels >= shape.channels);
    
    uint8_t* in = (uint8_t*)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    if ( normalizer == nil ) {
        for (int y = 0; y < image_height; y++) {
            for (int x = 0; x < image_width; x++) {
                auto* in_pixel = in + (y * bytes_per_row) + (x * image_channels);
                for (int c = 0; c < tensor_channels; ++c) {
                    image_mapped(0, y, x, c) = in_pixel[c+channel_offset];
                }
            }
        }
    } else {
        for (int y = 0; y < image_height; y++) {
            for (int x = 0; x < image_width; x++) {
                auto* in_pixel = in + (y * bytes_per_row) + (x * image_channels);
                for (int c = 0; c < tensor_channels; ++c) {
                    image_mapped(0, y, x, c) = normalizer(in_pixel[c+channel_offset],c);
                }
            }
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    CFRelease(pixelBuffer);
}

// MARK: -

@interface TIOPixelBuffer (TIOTensorFlowData_Protected)

@property (readwrite) CVPixelBufferRef transformedPixelBuffer;

@end

@implementation TIOPixelBuffer (TIOTensorFlowData)

- (nullable instancetype)initWithTensor:(tensorflow::Tensor)tensor description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOPixelBufferLayerDescription.class]);
    #warning implement
    return nil;
}

- (tensorflow::Tensor)tensorWithDescription:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOPixelBufferLayerDescription.class]);
    
    TIOPixelBufferLayerDescription *pixelBufferDescription = (TIOPixelBufferLayerDescription*)description;
    
    // If the pixel buffer is already the right size, format, and orientation simpy copy it to the tensor.
    // Otherwise, run it through the vision pipeline
    
    CVPixelBufferRef pixelBuffer = self.pixelBuffer;
    CGImagePropertyOrientation orientation = self.orientation;
    
    CVPixelBufferRef transformedPixelBuffer;
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    
    // Transform image using vision pipeline
    
    if ( width == pixelBufferDescription.shape.width
        && height == pixelBufferDescription.shape.height
        && pixelFormat == pixelBufferDescription.pixelFormat
        && orientation == kCGImagePropertyOrientationUp ) {
        transformedPixelBuffer = pixelBuffer;
    } else {
        TIOVisionPipeline *pipeline = [[TIOVisionPipeline alloc] initWithTIOPixelBufferDescription:pixelBufferDescription];
        transformedPixelBuffer = [pipeline transform:self.pixelBuffer orientation:self.orientation];
    }
    
    CVPixelBufferRetain(transformedPixelBuffer);
    self.transformedPixelBuffer = transformedPixelBuffer;
    
    // Tensor shape

    const int t_channels = pixelBufferDescription.shape.channels;
    const int t_width = pixelBufferDescription.shape.width;
    const int t_height = pixelBufferDescription.shape.height;
    const int t_batch_size = 1;
    
    tensorflow::TensorShape shape = tensorflow::TensorShape({t_batch_size, t_height, t_width, t_channels});

    // Copy pixels to tensor

    if ( description.isQuantized ) {
        tensorflow::Tensor tensor(tensorflow::DT_UINT8, shape);
        TIOCopyCVPixelBufferToTensorFlowTensor<uint8_t>(
            transformedPixelBuffer,
            tensor,
            pixelBufferDescription.shape,
            pixelBufferDescription.normalizer
            );
        return tensor;
    } else {
        tensorflow::Tensor tensor(tensorflow::DT_FLOAT, shape);
        TIOCopyCVPixelBufferToTensorFlowTensor<float_t>(
            transformedPixelBuffer,
            tensor,
            pixelBufferDescription.shape,
            pixelBufferDescription.normalizer
            );
        return tensor;
    }
}

@end
