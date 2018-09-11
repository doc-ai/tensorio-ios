//
//  TIOModelBundleManagerTests.m
//  TensorIO_Tests
//
//  Created by Philip Dow on 9/11/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TensorIO.h"

@interface TIOModelBundleManagerTests : XCTestCase

@end

@implementation TIOModelBundleManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testManagerReturnsErrorWhenPathDoesNotExist {
    NSError *error;
    BOOL success;
    
    success = [TIOModelBundleManager.sharedManager loadModelBundlesAtPath:@"/zxcv" error:&error];
    
    XCTAssertFalse(success);
    XCTAssertNotNil(error);
}

- (void)testManagerReturnsErrorWhenNoValidBundlesFound {
    NSError *error;
    BOOL success;
    
    success = [TIOModelBundleManager.sharedManager loadModelBundlesAtPath:[NSBundle.mainBundle bundlePath] error:&error];
    
    XCTAssertFalse(success);
    XCTAssertNotNil(error);
}

@end
