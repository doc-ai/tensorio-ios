//
//  TIOModelTrainerTests.m
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

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>
#import "TIOMockBatchDataSource.h"
#import "TIOMockTrainableModel.h"

@interface TIOModelTrainerTests : XCTestCase

@end

@implementation TIOModelTrainerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// MARK: - Unshuffled Tests

- (void)testBaseCaseWithOneItemOneEpochBatchSizeOfOne {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:1 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
}

- (void)testOneItemOneEpochBatchSizeOfTwo {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:1 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
}

- (void)testOneItemOneEpochBatchSizeOfThree {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:3 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
}

- (void)testOneItemTwoEpochsBatchSizeOfThree {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:3 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
}

- (void)testOneItemTwoEpochsBatchSizeOfOne {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:1 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
}

- (void)testTwoItemsOneEpochBatchSizeOfOne {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:2];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:1 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 1);
}

- (void)testTwoItemsTwoEpochsBatchSizeOfOne {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:2];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:1 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 4);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
}

- (void)testTwoItemsTwoEpochBatchSizeOfTwo {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:2];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:2 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
}

- (void)testThreeItemsOneEpochBatchSizeOfOne {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:1 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 3);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 1);
}

- (void)testThreeItemsOneEpochBatchSizeOfTwo {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:2 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 1);
}

- (void)testThreeItemsOneEpochBatchSizeOfThree {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:3 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 1);
}

- (void)testThreeItemsTwoEpochsBatchSizeOfOne {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:1 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 6);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 2);
}

- (void)testThreeItemsTwoEpochsBatchSizeOfTwo {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:2 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 4);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 2);
}

- (void)testThreeItemsTwoEpochBatchSizeOfThree {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:3 shuffle:NO];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 2);
}

// MARK: - Shuffled Tests

- (void)testBaseCaseWithOneItemOneEpochBatchSizeOfOneShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:1 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
}

- (void)testOneItemOneEpochBatchSizeOfTwoShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:1 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
}

- (void)testOneItemOneEpochBatchSizeOfThreeShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:3 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
}

- (void)testOneItemTwoEpochsBatchSizeOfThreeShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:3 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
}

- (void)testOneItemTwoEpochsBatchSizeOfOneShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:1];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:1 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
}

- (void)testTwoItemsOneEpochBatchSizeOfOneShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:2];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:1 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 1);
}

- (void)testTwoItemsTwoEpochsBatchSizeOfOneShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:2];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:1 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 4);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
}

- (void)testTwoItemsTwoEpochBatchSizeOfTwoShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:2];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:2 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
}

- (void)testThreeItemsOneEpochBatchSizeOfOneShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:1 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 3);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 1);
}

- (void)testThreeItemsOneEpochBatchSizeOfTwoShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:2 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 1);
}

- (void)testThreeItemsOneEpochBatchSizeOfThreeShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:1 batchSize:3 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 1);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 1);
}

- (void)testThreeItemsTwoEpochsBatchSizeOfOneShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:1 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 6);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 2);
}

- (void)testThreeItemsTwoEpochsBatchSizeOfTwoShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:2 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 4);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 2);
}

- (void)testThreeItemsTwoEpochBatchSizeOfThreeShuffled {
    TIOMockBatchDataSource *dataSource = [[TIOMockBatchDataSource alloc] initWithItemCount:3];
    TIOMockTrainableModel *model = [[TIOMockTrainableModel alloc] initMock];
    
    XCTAssertNotNil(dataSource);
    XCTAssertNotNil(model);
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:2 batchSize:3 shuffle:YES];
    
    [trainer train];
    
    XCTAssert(model.trainCount == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:0] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:1] == 2);
    XCTAssert([dataSource itemAtIndexCountAtIndex:2] == 2);
}

@end
