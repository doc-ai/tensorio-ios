//
//  TIOModelBackendsTests.m
//  TensorIO_Tests
//
//  Created by Phil Dow on 4/18/19.
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

@import XCTest;
@import TensorIO;

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
    XCTAssertEqualObjects(TIOModelBackend.availableBackend, @"tflite");
}

@end
