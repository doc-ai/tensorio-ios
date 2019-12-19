//
//  SwiftTensorFlowExampleTests.swift
//  SwiftTensorFlowExampleTests
//
//  Created by Phil Dow on 7/15/19.
//  Copyright © 2019 doc.ai. All rights reserved.
//

import XCTest
import TensorIO

class SwiftTensorFlowExampleTests: XCTestCase {

    let testModelsDir = Bundle(for: SwiftTensorFlowExampleTests.self).path(forResource: "models-tests", ofType: nil)!
    
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
    
    func image(named name: String) -> UIImage {
        let components = name.components(separatedBy: ".")
        let filename = components[0]
        let ext = components[1]
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: filename, ofType: ext)!
        let image = UIImage(contentsOfFile: path)!
        
        return image
    }
    
    // MARK: -
    
    override func setUp() { }
    override func tearDown() { }

    // MARK: - Swift Sanity Checks

    func testCatsVsDogsPredict() {
        
        let image = self.image(named: "cat.jpg")
        let pixels = image.pixelBuffer()!
        let value = pixels.takeUnretainedValue() as CVPixelBuffer
        let buffer = TIOPixelBuffer(pixelBuffer: value, orientation: .up)
        
        guard let bundle = self.bundle(named: "cats-vs-dogs-predict.tiobundle"),
              let model = self.model(with: bundle) else {
            XCTFail()
            return
        }
        
        let classification = model.run(on: buffer, error: nil)
        XCTAssertNotNil(classification)
        
        let sigmoid = ((classification as! NSDictionary)["sigmoid"] as! Float)
        XCTAssertNotNil(sigmoid)
    }
    
    func testCatsVsDogsTrainWithPlaceholders() {

        guard let bundle = self.bundle(named: "cats-vs-dogs-train-with-placeholder.tiobundle"),
              let model = self.model(with: bundle) as? TIOTrainableModel else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(bundle);
        XCTAssertNotNil(model);
       
        // Prepare Data
       
        let cat = TIOPixelBuffer(pixelBuffer: self.image(named: "cat.jpg").pixelBuffer()!.takeUnretainedValue() as CVPixelBuffer, orientation: .up)
        let dog = TIOPixelBuffer(pixelBuffer: self.image(named: "dog.jpg").pixelBuffer()!.takeUnretainedValue() as CVPixelBuffer, orientation: .up)
        
        // labels: 0=cat, 1=dog
        
        let batch = TIOBatch(keys: ["image", "labels"])
        
        batch.addItem([
            "image": cat,
            "labels": 0 as NSNumber
        ])
        
        batch.addItem([
            "image": dog,
            "labels": 1 as NSNumber
        ])
        
        // Train with two sets of placeholder values and test that changing the placeholder
        // actually has an effect
        
        let placeholders1 = [
            "placeholder_adam_learning_rate": 0.0001 as NSNumber
        ]
    
        let placeholders2 = [
            "placeholder_adam_learning_rate": 0.001 as NSNumber
        ]
        
        var results1: [Float] = []
        var results2: [Float] = []
        
        for _ in 1...10 {
            var error: NSError?
            let results = model.train(batch, placeholders: placeholders1, error: &error) as! NSDictionary
            let loss = results["sigmoid_cross_entropy_loss/value"]
            
            XCTAssertNil(error);
            XCTAssertNotNil(loss); // at epoch 0 ~ 0.2232
            XCTAssert(loss is NSNumber);
            
            results1.append(loss as! Float)
        }
        
        for _ in 1...10 {
            var error: NSError?
            let results = model.train(batch, placeholders: placeholders2, error: &error) as! NSDictionary
            let loss = results["sigmoid_cross_entropy_loss/value"]
            
            XCTAssertNil(error);
            XCTAssertNotNil(loss); // at epoch 0 ~ 0.2232
            XCTAssert(loss is NSNumber);
            
            results2.append(loss as! Float)
        }
        
        XCTAssertNotEqual(results1, results2)
    }
}
