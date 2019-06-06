//
//  TIOTensorFlowErrors.h
//  TensorIO
//
//  Created by Phil Dow on 4/26/19.
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

NS_ASSUME_NONNULL_BEGIN

/**
 * Set the `TIOModel` load error to `TIOTensorFlowModelModeError` when the no
 * supported modes have been recognized (i.e. predict, train, or eval).
 */

extern NSError * const TIOTensorFlowModelModeError;

/**
 * Set the `TIOTrainableModel` export error to `TIOTensorFlowModelExportURLNotFilePath`
 * when the URL is not a file URL.
 */

extern NSError * const TIOTensorFlowModelExportURLNotFilePath;

/**
 * Set the `TIOTrainableModel` export error to `TIOTensorFlowModelExportURLDoesNotExist`
 * when the path at URL does not exist or is not a directory.
 */

extern NSError * const TIOTensorFlowModelExportURLDoesNotExist;

/**
 * Occurs when the `LoadSavedModel` command fails.
 */

extern NSError * const TIOTensorFlowModelLoadSavedModelError;

/**
 * Occurs when the meta_graph_def saver fails to export the model
 */

extern NSError * const TIOTensorFlowModelExportError;

/**
 * Occurs when an inference session->run error occurs.
 */

extern NSError * const TIOTensorFlowModelSessionInferenceError;

/**
 * Occurs when an training session->run error occurs.
 */
 
extern NSError * const TIOTensorFlowModelSessionTrainError;

NS_ASSUME_NONNULL_END
