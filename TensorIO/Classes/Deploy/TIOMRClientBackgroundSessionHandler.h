//
//  TIOMRClientBackgroundSessionHandler.h
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

NS_ASSUME_NONNULL_BEGIN

typedef void (^TIOMRClientBackgroundCompletionHandler)(void);

/**
 * A shared singleton for sharing background URL session completion handlers
 * between an application delegate and a `TIOModelRepositoryClient`.
 */

@interface TIOMRClientBackgroundSessionHandler : NSObject

/**
 * The background completion handler. Set this value from your app delegate's
 * `application:handleEventsForBackgroundURLSession:completionHandler:` method.
 */

@property (nullable) TIOMRClientBackgroundCompletionHandler handler;

/**
 * The shared instance. Access the shared instance from your app delegate to
 * set the handler value.
 */

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
