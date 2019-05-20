//
//  TIOMockBatchDataSource.h
//  TensorIO_Tests
//
//  Created by Phil Dow on 5/20/19.
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

/**
 * The mock batch data source tracks the number of times `itemAtIndex:` is
 * called for each index and is used to validate `TIOModelTrainer` behavior.
 */

@interface TIOMockBatchDataSource : NSObject <TIOBatchDataSource>

// MARK: - Mock Properties

/**
 * Tracks number of times itemAtIndex has been called for a particular index.
 */

@property (readonly) NSArray<NSNumber*> *itemAtIndexCount;
- (NSUInteger)itemAtIndexCountAtIndex:(NSUInteger)index;

- (instancetype)initWithItemCount:(NSUInteger)count;

// MARK: - TIOBatchDataSource

@property (readonly) NSArray<NSString*> *keys;

- (NSUInteger)numberOfItems;
- (TIOBatchItem*)itemAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
