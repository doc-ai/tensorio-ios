//
//  ViewController.swift
//  SwiftExample
//
//  Created by Phil Dow on 2/13/19.
//  Copyright © 2019 doc.ai. All rights reserved.
//

import UIKit
import TensorIO

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoView: ResultInfoView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "example-image")!
        let pixels = image.pixelBuffer()!
        let value = pixels.takeUnretainedValue() as CVPixelBuffer
        let buffer = TIOPixelBuffer(pixelBuffer:value, orientation: .up)
        
        let path = Bundle.main.path(forResource: "mobilenet_v2_1.4_224", ofType: "tiobundle", inDirectory: "models")!
        let model = TIOTFLiteModel.withBundleAtPath(path)!
        
        let classification = model.run(on: buffer)
        // print(classification)
        
        let top5 = ((classification as! NSDictionary)["classification"] as! NSDictionary).topN(5, threshold: 0.1)
        print(top5)
        
        imageView.image = image
        infoView.classifications = (top5 as NSDictionary).description
    }

}
