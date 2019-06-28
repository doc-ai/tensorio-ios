//
//  ViewController.m
//  TensorFlowExample
//
//  Created by Phil Dow on 4/9/19.
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

#import "ViewController.h"

#import <TensorIO/TensorIO-umbrella.h>
#import "ResultInfoView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Prepare the image
    
    UIImage *image = [UIImage imageNamed:@"cat.jpg"];
    TIOPixelBuffer *buffer = [[TIOPixelBuffer alloc] initWithPixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    // Load the model
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cats-vs-dogs" ofType:TIOModelBundleExtension inDirectory:@"models"];
    id<TIOModel> model = [TIOTensorFlowModel modelWithBundleAtPath:path];
    
    [model load:nil];
    
    // Run the model
    
    NSDictionary *inputs = @{
        @"image": buffer
    };
    
    NSDictionary *classification = (NSDictionary *)[model runOn:inputs error:nil];
    NSNumber *sigmoid = classification[@"sigmoid"];
    
    // Show the results
    
    self.imageView.image = image;
    self.infoView.classifications = classification.description;
    
    // Log the results
    
    NSLog(@"%@", sigmoid);
    
    if (sigmoid.floatValue < 0.5) {
        NSLog(@"*** It's a cat! ***)");
    } else {
        NSLog(@"*** It's a dog! ***)");
    }
}


@end
