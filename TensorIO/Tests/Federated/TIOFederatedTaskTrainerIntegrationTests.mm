//
//  TIOFederatedTaskTrainerIntegrationTests.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/22/19.
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

@interface TIOFederatedTaskAndTrainerTests : XCTestCase

@property NSString *modelsPath;
@property NSString *tasksPath;

@end

@implementation TIOFederatedTaskAndTrainerTests

- (void)setUp {
    self.modelsPath = [[NSBundle mainBundle] pathForResource:@"model-tests" ofType:nil];
    self.tasksPath = [[NSBundle mainBundle] pathForResource:@"task-tests" ofType:nil];
}

- (void)tearDown { }

// MARK: -

- (TIOModelBundle *)modelBundleWithName:(NSString *)filename {
    NSString *path = [self.modelsPath stringByAppendingPathComponent:filename];
    return [[TIOModelBundle alloc] initWithPath:path];
}

- (id<TIOModel>)loadModelFromBundle:(nonnull TIOModelBundle *)bundle {
    
    id<TIOModel> model = (id<TIOModel>)[bundle newModel];
    NSError *modelError;
    
    if ( model == nil ) {
        NSLog(@"Unable to find and instantiate model with id %@", bundle.identifier);
        model = nil;
        return nil;
    }
    
    if ( ![model load:&modelError] ) {
        NSLog(@"Model does could not be loaded, id: %@, error: %@", bundle.identifier, modelError);
        model = nil;
        return nil;
    }
    
    return model;
}

- (TIOFederatedTaskBundle *)taskBundleWithName:(NSString *)filename {
    NSString *path = [self.tasksPath stringByAppendingPathComponent:filename];
    TIOFederatedTaskBundle *bundle = [[TIOFederatedTaskBundle alloc] initWithPath:path];
    return bundle;
}

// MARK: -

- (void)testInstantiatesTrainerWithTask {
    TIOModelBundle *modelBundle = [self modelBundleWithName:@"cats-vs-dogs-train.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:modelBundle];
    
    TIOFederatedTaskBundle *taskBundle = [self taskBundleWithName:@"cats-vs-dogs-train.tiotask"];
    TIOFederatedTask *task = taskBundle.task;
    
    XCTAssertNotNil(modelBundle);
    XCTAssertNotNil(model);
    
    XCTAssertNotNil(taskBundle);
    XCTAssertNotNil(task);
    
    TIOInMemoryBatchDataSource *dataSource = [[TIOInMemoryBatchDataSource alloc] initWithItem:@{
        @"foo": @[@(1)],
        @"bar": @[@(1)]
    }];
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model task:task dataSource:dataSource];
    
    XCTAssert(trainer.epochs == task.epochs);
    XCTAssert(trainer.batchSize == task.batchSize);
    
    XCTAssert(trainer.epochs == 10);
    XCTAssert(trainer.batchSize == 2);
}

- (void)testTrainerWithTaskIntegration {
    TIOModelBundle *modelBundle = [self modelBundleWithName:@"cats-vs-dogs-train.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:modelBundle];
    
    TIOFederatedTaskBundle *taskBundle = [self taskBundleWithName:@"cats-vs-dogs-train.tiotask"];
    TIOFederatedTask *task = taskBundle.task;
    
    XCTAssertNotNil(modelBundle);
    XCTAssertNotNil(model);
    
    XCTAssertNotNil(taskBundle);
    XCTAssertNotNil(task);
    
    TIOPixelBuffer *cat = [[TIOPixelBuffer alloc] initWithPixelBuffer:[UIImage imageNamed:@"cat.jpg"].pixelBuffer orientation:kCGImagePropertyOrientationUp];
    TIOPixelBuffer *dog = [[TIOPixelBuffer alloc] initWithPixelBuffer:[UIImage imageNamed:@"dog.jpg"].pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    TIOBatch *batch = [[TIOBatch alloc] initWithKeys:@[@"image", @"labels"]];
    
    [batch addItem:@{
        @"image": cat,
        @"labels": @(0)
    }];
    
    [batch addItem:@{
        @"image": dog,
        @"labels": @(1)
    }];
    
    TIOInMemoryBatchDataSource *dataSource = [[TIOInMemoryBatchDataSource alloc] initWithBatch:batch];
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model task:task dataSource:dataSource];
    NSDictionary *results = (NSDictionary *)[trainer train];
    
    XCTAssertNotNil(results[@"sigmoid_cross_entropy_loss/value"]); // at epoch 0 ~ 0.2232
    XCTAssert([results[@"sigmoid_cross_entropy_loss/value"] isKindOfClass:NSNumber.class]);
}

@end
