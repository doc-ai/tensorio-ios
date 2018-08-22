//
//  MainViewController.m
//  TensorIO
//
//  Created by Philip Dow on 08/21/2018.
//  Copyright © 2018 doc.ai (http://doc.ai)
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

#import "MainViewController.h"

#import "TensorIO.h"
#import "ResultInfoView.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Acquire am example image
 
    UIImage *image = [UIImage imageNamed:@"example-image"];
    
    // TIOModels take inputs and produce outputs that conform to the TIOData protocol
    // Because a CVPixelBufferRef is not an Obj-C object, we wrap it in a TIOPixelBuffer, which does conform to that protocol
    
    TIOPixelBuffer *buffer = [[TIOPixelBuffer alloc] initWithPixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    // The TIOModelBundleManager returns instances of TIOModelBundle, which we can call newModel on to acquire a TIOModel
    // We previously loaded the models folder in the AppDelegate, see application:didFinishLaunchingWithOptions:
    // A model can also be loaded directly from a path
    
    id<TIOModel> model = [TIOModelBundleManager.sharedManager bundleWithId:@"mobilenet-v2-100-224-unquantized"].newModel;
    
    // Would be nice if that were [TIOModel modelWithId:@""]
    
    // Acquire the named results from performing inference on the model
    // This returns a dictionary whose entries corresponding to the names of the model outputs in the model.json file
    // This is a classification model, so take the top 5 probabilities whose values are over 0.1
    
    NSDictionary *classification = [((NSDictionary*)[model runOn:buffer])[@"classification"] topN:5 threshold:0.1];
    
    // Show the results
    
    self.imageView.image = image;
    self.infoView.classifications = classification.description;
    
    NSLog(@"Classification: %@", classification);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
