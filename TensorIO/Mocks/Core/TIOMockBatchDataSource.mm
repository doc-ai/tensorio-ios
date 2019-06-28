//
//  TIOMockBatchDataSource.m
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

#import "TIOMockBatchDataSource.h"

@implementation TIOMockBatchDataSource {
    NSUInteger _itemCount;
}

- (instancetype)initWithItemCount:(NSUInteger)count {
    if ((self=[super init])) {
        _itemAtIndexCount = [[NSMutableArray alloc] init];
        _itemCount = count;
        
        for (NSUInteger i = 0; i < _itemCount; i++) {
            ((NSMutableArray *)_itemAtIndexCount)[i] = @(0);
        }
    }
    return self;
}

- (NSUInteger)itemAtIndexCountAtIndex:(NSUInteger)index {
    return _itemAtIndexCount[index].unsignedIntegerValue;
}

// MARK: - TIOBatchDataSource

- (NSArray<NSString*>*)keys {
    return @[@"foo"];
}

- (NSUInteger)numberOfItems {
    return _itemCount;
}

- (TIOBatchItem *)itemAtIndex:(NSUInteger)index {
    ((NSMutableArray *)_itemAtIndexCount)[index] = @(_itemAtIndexCount[index].unsignedIntegerValue+1);
    
    return @{
        @"foo": @[@(1)]
    };
}

@end
