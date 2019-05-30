//
//  TIOFleaTasks.h
//  TensorIO
//
//  Created by Phil Dow on 5/23/19.
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
 * Encapsulates information about the tasks available from a flea server. May
 * contain information about all task available or only a subset of tasks
 * available for particular model.
 */

@interface TIOFleaTasks : NSObject

/**
 * The id of the first task, by date, encapsulated by this list.
 */

@property (readonly) NSString *startTaskId;

/**
 * The maximum number of task ids in this list.
 */

@property (readonly) NSUInteger maxItems;

/**
 * The task ids and models they refer to. The dictionaries in the array contain
 * the `TIOFleaTasksArrayTaskId` key pointing to a string value and the
 * `TIOFleaTasksArrayModelURL` key pointing to a URL.
 */

@property (readonly) NSArray<NSString*> *taskIds;

/**
 * The designated initializer. You should not need to instantiate instances of
 * this class yourself.
 */

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON error:(NSError**)error NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
