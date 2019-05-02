//
//  TIOModelRepository.h
//  TensorIO
//
//  Created by Philip Dow on 7/6/18.
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

@interface TIOModelRepository : NSObject

/**
 * The base URL of the model repository
 */

@property (readonly) NSURL *URL;

/**
 * Initializes a model repository with a base URL
 */

- (instancetype)initWithURL:(NSURL*)URL NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Checks if the repository is up and correctly running
 */

- (BOOL)GETHealthStatus;

@end
