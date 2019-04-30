//
//  TIOModelBackendsTests.m
//  TensorFlowExampleTests
//
//  Created by Phil Dow on 4/18/19.
//  Copyright © 2019 doc.ai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TensorIO/TensorIO-umbrella.h>

@interface TIOModelBackendsTests : XCTestCase

@end

@implementation TIOModelBackendsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testReturnsTFLiteBackendClassName {
    XCTAssertEqualObjects([TIOModelBackend classNameForBackend:@"tflite"], @"TIOTFLiteModel");
}

- (void)testReturnsTensorFlowBackendClassName {
    XCTAssertEqualObjects([TIOModelBackend classNameForBackend:@"tensorflow"], @"TIOTensorFlowModel");
}

- (void)testReturnsNilClassNameForUnknownBackend {
    XCTAssertNil([TIOModelBackend classNameForBackend:@""]);
}

- (void)testAvailableBackendIsTFLite {
    XCTAssertEqualObjects(TIOModelBackend.availableBackend, @"tensorflow");
}

@end
