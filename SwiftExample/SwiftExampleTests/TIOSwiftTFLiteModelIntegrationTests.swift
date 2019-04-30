//
//  SwiftExampleTests.swift
//  SwiftExampleTests
//
//  Created by Phil Dow on 2/13/19.
//  Copyright © 2019 doc.ai. All rights reserved.
//

import XCTest
import TensorIO
@testable import SwiftExample

class SwiftExampleTests: XCTestCase {

    let testModelsDir = Bundle.main.path(forResource: "models-tests", ofType: nil)!
    
    func bundle(named name: String) -> TIOModelBundle? {
        let path = URL(fileURLWithPath: testModelsDir).appendingPathComponent(name).path
        return TIOModelBundle(path: path)
    }
    
    func model(with bundle: TIOModelBundle) -> TIOModel? {
        guard let model = bundle.newModel() else {
            print("There was a problem instantiating the model from the bundle")
            return nil
        }
        
        guard let _ = try? model.load() else {
            print("There was a problem loading the model")
            return nil
        }
        
        return model
    }
    
    override func setUp() { }
    override func tearDown() { }

    // Swift sanity check

    func testMobileNetModel() {
        
        let image = UIImage(named: "example-image")!
        let pixels = image.pixelBuffer()!
        let value = pixels.takeUnretainedValue() as CVPixelBuffer
        let buffer = TIOPixelBuffer(pixelBuffer:value, orientation: .up)
        
        guard let bundle = self.bundle(named: "mobilenet_v2_1.4_224.tiobundle"),
              let model = self.model(with: bundle) else {
            XCTFail()
            return
        }
        
        let classification = model.run(on: buffer)
        XCTAssertNotNil(classification)
        
        let top5 = ((classification as! NSDictionary)["classification"] as! NSDictionary).topN(5, threshold: 0.1)
        XCTAssertNotNil(top5)
    }
}
