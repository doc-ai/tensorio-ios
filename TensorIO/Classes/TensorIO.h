//
//  TensorIO.h
//  TensorIO
//
//  Created by Philip Dow on 7/10/18.
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

// TIO Model

#import "TIOModelBundleManager.h"
#import "TIOModelBundle.h"
#import "TIOModel.h"

#import "TIOModelOptions.h"
#import "TIOModelJSONParsing.h"
#import "TIOPixelNormalization.h"
#import "TIOQuantization.h"
#import "TIOVisionModelHelpers.h"
#import "TIOVisionPipeline.h"

// TFLite Model

#import "TIOTFLiteModel.h"
#import "TIOTFLiteErrors.h"

// TIO Data

#import "TIOData.h"
#import "TIOVector.h"
#import "TIOPixelBuffer.h"
#import "NSArray+TIOData.h"
#import "NSData+TIOData.h"
#import "NSDictionary+TIOData.h"
#import "NSNumber+TIOData.h"

// TIO Utilities

#import "NSArray+TIOExtensions.h"
#import "NSDictionary+TIOExtensions.h"
#import "UIImage+TIOCVPixelBufferExtensions.h"
#import "TIOCVPixelBufferHelpers.h"
#import "TIOObjcDefer.h"
