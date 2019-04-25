//
//  TIOTrainableModel.h
//  TensorIO
//
//  Created by Phil Dow on 4/24/19.
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
#import "TIOModel.h"
#import "TIOBatch.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A trainable model extends the `TIOModel` protocol with support for training.
 */

@protocol TIOTrainableModel <TIOModel, NSObject>

/**
 * Calls the underlying training op with a single batch.
 *
 * A complete round of training will involve iterating over all the available
 * batches for a certain number of epochs. It is the responsibility of other
 * objects to execute those loops and prepare batches for calls to this method.
 */

- (id<TIOData>)train:(TIOBatch*)batch;

@end

NS_ASSUME_NONNULL_END
