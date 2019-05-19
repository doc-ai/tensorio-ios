//
//  TIOModelTrainer.h
//  TensorIO
//
//  Created by Phil Dow on 5/18/19.
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

NS_ASSUME_NONNULL_BEGIN

/**
 * Responsible for actually executing training passes on a model, iterating
 * over a specified number of epochs and preparing batches of a specified size.
 * The trainer receives either a single batch for training or is instantiated
 * with a `TIOBatchDataSource` which will provide data as needed during the
 * training loop.
 */

@interface TIOModelTrainer : NSObject

@end

NS_ASSUME_NONNULL_END
