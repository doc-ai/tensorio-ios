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
#import "TIOPixelBufferToTensorHelpers.h"
#import "TIOVisionPipeline.h"

@interface TIOPixelBuffer (TIOTensorFlowData_Protected)

@property (readwrite) CVPixelBufferRef transformedPixelBuffer;

@end

@implementation TIOPixelBuffer (TIOTensorFlowData)

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
    
    // TODO: helpers for copying a pixel buffer to a TensorFlow Tensor
    
//    if ( description.isQuantized ) {
//        TIOCopyCVPixelBufferToTensor(
//            transformedPixelBuffer,
//            (uint8_t *)buffer,
//            pixelBufferDescription.shape,
//            pixelBufferDescription.normalizer
//        );
//    } else {
//        TIOCopyCVPixelBufferToTensor(
//            transformedPixelBuffer,
//            (float_t *)buffer,
//            pixelBufferDescription.shape,
//            pixelBufferDescription.normalizer
//        );
//    }

    tensorflow::Tensor image(tensorflow::DT_FLOAT, tensorflow::TensorShape({1, 128, 128, 3})); // {1, ... zeroeth index is batch size
    auto image_mapped = image.tensor<float, 4>();

{
    CVPixelBufferRef pixelBuffer = transformedPixelBuffer;
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    
    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    const int bytes_per_row = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int image_width = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int image_height = (int)CVPixelBufferGetHeight(pixelBuffer);
    const int image_channels = 4; // by definition (ARGB, BGRA)
    const int tensor_channels = 3; // by definition (ARG, BGR)
    const int channel_offset = sourcePixelFormat == kCVPixelFormatType_32ARGB
        ? 1
        : 0;
    
    uint8_t* in = (uint8_t*)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    for (int y = 0; y < image_height; y++) {
        for (int x = 0; x < image_width; x++) {
            auto* in_pixel = in + (y * bytes_per_row) + (x * image_channels);
            for (int c = 0; c < tensor_channels; ++c) {
                image_mapped(0, y, x, c) = in_pixel[c+channel_offset] / 255.0;
            }
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
}
    
    return image;
}

@end
