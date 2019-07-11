//
//  TIOTrainingTests.m
//  TensorFlowExampleTests
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

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>

@interface TIOTrainingTests : XCTestCase

@property NSString *modelsPath;

@end

@implementation TIOTrainingTests

- (void)setUp {
    self.modelsPath = [[NSBundle mainBundle] pathForResource:@"models-tests" ofType:nil];
}

- (void)tearDown {
    
}

// MARK: -

- (TIOModelBundle *)bundleWithName:(NSString *)filename {
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

// MARK: - Model Train Method

- (void)testConformsToModel {
    TIOModelBundle *bundle = [self bundleWithName:@"cats-vs-dogs-train.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:bundle];
    XCTAssert([model conformsToProtocol:@protocol(TIOModel)]);
}

- (void)testConformsToTrainable {
    TIOModelBundle *bundle = [self bundleWithName:@"cats-vs-dogs-train.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:bundle];
    XCTAssert([model conformsToProtocol:@protocol(TIOTrainableModel)]);
}

- (void)testTrainCatsDogsModel {
    TIOModelBundle *bundle = [self bundleWithName:@"cats-vs-dogs-train.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    TIOPixelBuffer *cat = [[TIOPixelBuffer alloc] initWithPixelBuffer:[UIImage imageNamed:@"cat.jpg"].pixelBuffer orientation:kCGImagePropertyOrientationUp];
    TIOPixelBuffer *dog = [[TIOPixelBuffer alloc] initWithPixelBuffer:[UIImage imageNamed:@"dog.jpg"].pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    // labels: 0=cat, 1=dog
    
    TIOBatch *batch = [[TIOBatch alloc] initWithKeys:@[@"image", @"labels"]];
    
    [batch addItem:@{
        @"image": cat,
        @"labels": @(0)
    }];
    
    [batch addItem:@{
        @"image": dog,
        @"labels": @(1)
    }];
    
    for (NSUInteger epoch = 0; epoch < 10; epoch++) {
        NSError *error;
        NSDictionary *results = (NSDictionary *)[model train:batch error:&error];
        
        XCTAssertNil(error);
        XCTAssertNotNil(results[@"sigmoid_cross_entropy_loss/value"]); // at epoch 0 ~ 0.2232
        XCTAssert([results[@"sigmoid_cross_entropy_loss/value"] isKindOfClass:NSNumber.class]);
    }
}

- (void)testTrainCatsDogsWithPlaceholderModel {
    TIOModelBundle *bundle = [self bundleWithName:@"cats-vs-dogs-train-with-placeholder.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    TIOPixelBuffer *cat = [[TIOPixelBuffer alloc] initWithPixelBuffer:[UIImage imageNamed:@"cat.jpg"].pixelBuffer orientation:kCGImagePropertyOrientationUp];
    TIOPixelBuffer *dog = [[TIOPixelBuffer alloc] initWithPixelBuffer:[UIImage imageNamed:@"dog.jpg"].pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    // labels: 0=cat, 1=dog
    
    TIOBatch *batch = [[TIOBatch alloc] initWithKeys:@[@"image", @"labels"]];
    
    [batch addItem:@{
        @"image": cat,
        @"labels": @(0)
    }];
    
    [batch addItem:@{
        @"image": dog,
        @"labels": @(1)
    }];
    
    // Train with two sets of placeholder values and test that changing the placeholder
    // actually has an effect
    
    NSDictionary *placeholders1 = @{
        @"placeholder_adam_learning_rate": @(0.0001)
    };
    
    NSDictionary *placeholders2 = @{
        @"placeholder_adam_learning_rate": @(0.001)
    };
    
    NSMutableArray *results1 = NSMutableArray.array;
    NSMutableArray *results2 = NSMutableArray.array;
    
    for (NSUInteger epoch = 0; epoch < 10; epoch++) {
        NSError *error;
        NSDictionary *results = (NSDictionary *)[model train:batch placeholders:placeholders1 error:&error];
        
        XCTAssertNil(error);
        XCTAssertNotNil(results[@"sigmoid_cross_entropy_loss/value"]); // at epoch 0 ~ 0.2232
        XCTAssert([results[@"sigmoid_cross_entropy_loss/value"] isKindOfClass:NSNumber.class]);
        
        [results1 addObject:results[@"sigmoid_cross_entropy_loss/value"]];
    }
    
    for (NSUInteger epoch = 0; epoch < 10; epoch++) {
        NSError *error;
        NSDictionary *results = (NSDictionary *)[model train:batch placeholders:placeholders2 error:&error];
        
        XCTAssertNil(error);
        XCTAssertNotNil(results[@"sigmoid_cross_entropy_loss/value"]); // at epoch 0 ~ 0.2232
        XCTAssert([results[@"sigmoid_cross_entropy_loss/value"] isKindOfClass:NSNumber.class]);
        
        [results2 addObject:results[@"sigmoid_cross_entropy_loss/value"]];
    }
    
    XCTAssertNotEqualObjects(results1, results2);
}

- (void)testExportsModel {
    TIOModelBundle *bundle = [self bundleWithName:@"cats-vs-dogs-train.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    NSURL *directory = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSError *error;
    BOOL success;
    
    // The method call should return successfully
    
    success = [model exportTo:directory error:&error];
    
    XCTAssertTrue(success);
    XCTAssertNil(error);
    
    // The directory should have something added to it
    
    NSError *fmError;
    NSArray<NSString*> *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:directory.path error:&fmError];
    
    XCTAssertNil(fmError);
    XCTAssert(contents.count > 0);
    
    XCTAssert([contents containsObject:@"checkpoint.index"]);
    XCTAssert([contents containsObject:@"checkpoint.data-00000-of-00001"]);
}

// MARK: - Model Trainer

- (void)testModelTrainer {
    TIOModelBundle *bundle = [self bundleWithName:@"cats-vs-dogs-train.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
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
    
    TIOModelTrainer *trainer = [[TIOModelTrainer alloc] initWithModel:model dataSource:dataSource placeholders:nil epochs:10 batchSize:2 shuffle:NO];
    NSDictionary *results = (NSDictionary *)[trainer train];
    
    XCTAssertNotNil(results[@"sigmoid_cross_entropy_loss/value"]); // at epoch 0 ~ 0.2232
    XCTAssert([results[@"sigmoid_cross_entropy_loss/value"] isKindOfClass:NSNumber.class]);
}

@end
