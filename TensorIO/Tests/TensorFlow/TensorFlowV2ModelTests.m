//
//  TensorFlowV2ModelTests.m
//  TensorFlowExampleTests
//
//  Created by Phil Dow on 4/14/20.
//  Copyright © 2020 doc.ai. All rights reserved.
//

@import XCTest;
@import TensorIO;

@interface TensorFlowV2ModelTests : XCTestCase

@property NSString *modelsPath;

@end

@implementation TensorFlowV2ModelTests

- (void)setUp {
    self.modelsPath = [[NSBundle bundleForClass:self.class] pathForResource:@"models-tests" ofType:nil];
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

- (UIImage *)imageNamed:(NSString *)name {
    NSString *filename = name.stringByDeletingPathExtension;
    NSString *ext = name.pathExtension;
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:filename ofType:ext];
    
    return [UIImage imageWithContentsOfFile:path];
}

// MARK: -

- (void)testPredictCatsDogsV2V1CompatModel {
    TIOModelBundle *bundle = [self bundleWithName:@"cats-vs-dogs-v2-v1-compat-predict.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    TIOPixelBuffer *cat = [[TIOPixelBuffer alloc] initWithPixelBuffer:[self imageNamed:@"cat.jpg"].pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    NSDictionary *inputs = @{
        @"image": cat
    };
    
    NSError *error;
    NSDictionary *results = (NSDictionary *)[model runOn:inputs error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(results[@"sigmoid"]);
    XCTAssert([results[@"sigmoid"] isKindOfClass:NSNumber.class]);
}

- (void)testTrainCatsDogsV2V1CompatModel {
    TIOModelBundle *bundle = [self bundleWithName:@"cats-vs-dogs-v2-v1-compat-train.tiobundle"];
    id<TIOTrainableModel> model = (id<TIOTrainableModel>)[self loadModelFromBundle:bundle];
    
    XCTAssertNotNil(bundle);
    XCTAssertNotNil(model);
    
    TIOPixelBuffer *cat = [[TIOPixelBuffer alloc] initWithPixelBuffer:[self imageNamed:@"cat.jpg"].pixelBuffer orientation:kCGImagePropertyOrientationUp];
    TIOPixelBuffer *dog = [[TIOPixelBuffer alloc] initWithPixelBuffer:[self imageNamed:@"dog.jpg"].pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
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
        XCTAssertNotNil(results[@"sigmoid_cross_entropy_loss/value"]); // at epoch 0 ~ 5.958329e-11, this is retrained model with 10,000 epochs
        XCTAssert([results[@"sigmoid_cross_entropy_loss/value"] isKindOfClass:NSNumber.class]);
    }
}

@end
