//
//  ViewController.swift
//  SwiftTensorFlowExample
//
//  Created by Phil Dow on 7/15/19.
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

import UIKit
import TensorIO

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoView: ResultInfoView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare the image
        
        let image = UIImage(named: "cat.jpg")!
        let pixels = image.pixelBuffer()!
        let value = pixels.takeUnretainedValue() as CVPixelBuffer
        let buffer = TIOPixelBuffer(pixelBuffer: value, orientation: .up)
        
        // Load the model
        
        let path = Bundle.main.path(forResource: "cats-vs-dogs", ofType: "tiobundle", inDirectory: "models")!
        let model = TIOTensorFlowModel.withBundleAtPath(path)!
        
        // Predict
        
        let classification = model.run(on: buffer, error: nil)
        let sigmoid = (classification as! NSDictionary)["sigmoid"] as! Float
        
        // Show results
        
        self.imageView.image = image
        infoView.classifications = classification.description
        
        // Log the results
    
        print(sigmoid);
    
        if (sigmoid < 0.5) {
            print("*** It's a cat! ***)");
        } else {
            print("*** It's a dog! ***)");
        }
    }

}

