//
//  TIOModelUpdaterDelegate.h
//  TensorIO
//
//  Created by Phil Dow on 6/7/19.
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

NS_ASSUME_NONNULL_BEGIN;

@class TIOModelRepositoryClient;

@protocol TIOModelUpdaterDelegate <NSObject>

/**
 * Informs the delegate that some amount of progress has been made during a
 * model update.
 *
 * Progress will be a value between 0 and 1. This method will only be called
 * to indicate progress when you use a `TIOMRClientSessionDelegate` with the
 * `TIOModelRepositoryClient` that is injected into a model updater. Refer to
 * additional instructions for `TIOModelRepositoryClient`.
 */

- (void)modelUpdater:(TIOModelRepositoryClient*)client didProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
