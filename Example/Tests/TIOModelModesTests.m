//
//  TIOModelModesTests.m
//  TensorIO_Tests
//
//  Created by Phil Dow on 4/30/19.
//  Copyright © 2019 doc.ai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>

@interface TIOModelModesTests : XCTestCase

@end

@implementation TIOModelModesTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testNoModesDefaultsToPredict {
    TIOModelModes *modes = [[TIOModelModes alloc] initWithArray:nil];
    XCTAssertTrue(modes.predicts);
}

- (void)testParsesOnlyPredict {
    TIOModelModes *modes = [[TIOModelModes alloc] initWithArray:@[@"predict"]];
    XCTAssertTrue(modes.predicts);
    XCTAssertFalse(modes.trains);
    XCTAssertFalse(modes.evals);
}

- (void)testParsesOnlyTraing {
    TIOModelModes *modes = [[TIOModelModes alloc] initWithArray:@[@"train"]];
    XCTAssertFalse(modes.predicts);
    XCTAssertTrue(modes.trains);
    XCTAssertFalse(modes.evals);
}

- (void)testParsesOnlyEval {
    TIOModelModes *modes = [[TIOModelModes alloc] initWithArray:@[@"eval"]];
    XCTAssertFalse(modes.predicts);
    XCTAssertFalse(modes.trains);
    XCTAssertTrue(modes.evals);
}

- (void)testParsesMultipleModes {
    TIOModelModes *modes = [[TIOModelModes alloc] initWithArray:@[@"predict", @"train"]];
    XCTAssertTrue(modes.predicts);
    XCTAssertTrue(modes.trains);
    XCTAssertFalse(modes.evals);
}

@end
