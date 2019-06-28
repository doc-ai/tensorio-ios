//
//  TIOMockModelBundle.h
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/28/19.
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
#import <TensorIO/TensorIO-umbrella.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOMockModelBundle : TIOModelBundle

/**
 * Mock initializer but must still pass a valid bundle path thanks to the
 * designated initializer in the superclass.
 */

- (instancetype)initWithMockedModel:(id<TIOModel>)model path:(NSString *)path;

/**
 * Overrides newModel to return the mocked model
 */

- (nullable id<TIOModel>)newModel;

@end

NS_ASSUME_NONNULL_END
