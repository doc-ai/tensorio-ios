//
//  ViewController.m
//  DeployExample
//
//  Created by Phil Dow on 5/2/19.
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

#import "ViewController.h"

@interface ViewController ()

@property TIOModelRepository *repository;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    // Live Tests, uncomment as you go
    
    // Install docker
    // In tensorio-models: $ make run-models
    // In tensorio-models: $ ./e2e/setup.sh
    
    // Copy the testsetup.tiobundle three times to some directory, rename it to h1c1.tiobundle.zip, h2c1.tiobundle.zip and h2c2.tiobundle.zip
    // Then run python -m SimpleHTTPServer from that directory
    
//    NSString *modelId = @"TestModel-1558049870";
//    NSString *hyp1Id = @"hyperparameters-1";
//    NSString *hyp2Id = @"hyperparameters-2";
//    NSString *checkpoint1 = @"checkpoint-1";
//    NSString *checkpoint2 = @"checkpoint-2";
    
//    NSURL *URL = [NSURL URLWithString:@"http://localhost:8081/v1/repository"];
//    self.repository = [[TIOModelRepository alloc] initWithBaseURL:URL session:nil];
    
//    [self.repository GETHealthStatus:^(TIOMRStatus * _Nullable response, NSError * _Nonnull error) {
//        if (error) {
//            NSLog(@"There was an error");
//            return;
//        }
//
//        NSLog(@"HEALTH STATUS: %lu", (unsigned long)response.status);
//    }];
    
//    [self.repository GETModels:^(TIOMRModels * _Nullable models, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error");
//            return;
//        }
//
//        NSLog(@"MODELS: %@", models);
//    }];

//    [self.repository GETModelWithId:modelId callback:^(TIOMRModel * _Nullable model, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error");
//            return;
//        }
//
//        NSLog(@"MODEL: %@", model);
//    }];
    
//    [self.repository GETHyperparametersForModelWithId:modelId callback:^(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error");
//            return;
//        }
//
//        NSLog(@"HYPERPARAMETERS: %@", hyperparameters);
//    }];
    
//    [self.repository GETHyperparameterForModelWithId:modelId hyperparametersId:hyp1Id callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error");
//            return;
//        }
//
//        NSLog(@"HYPERPARAMETER: %@", hyperparameter);
//    }];
    
//    [self.repository GETCheckpointsForModelWithId:modelId hyperparametersId:hyp2Id callback:^(TIOMRCheckpoints * _Nullable checkpoints, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error");
//            return;
//        }
//
//        NSLog(@"CHECKPOINTS: %@", checkpoints);
//    }];
    
//    [self.repository GETCheckpointForModelWithId:modelId hyperparametersId:hyp2Id checkpointId:checkpoint1 callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error");
//            return;
//        }
//
//        NSLog(@"CHECKPOINT: %@", checkpoint);
//    }];

    
//    NSURL *upgradableURL = [NSBundle.mainBundle URLForResource:@"testsetup" withExtension:@"tiobundle"];
//    TIOModelBundle *bundle = [[TIOModelBundle alloc] initWithPath:upgradableURL.path];
//
//    TIOModelUpdater *updater = [[TIOModelUpdater alloc] initWithModelBundle:bundle repository:self.repository];
//    [updater updateWithValidator:nil callback:^(BOOL updated, NSURL * _Nullable updatedBundleURL, NSError * _Nullable error) {
//        NSLog(@"%i", updated);
//        NSLog(@"%@", error);
//        NSLog(@"%@", updatedBundleURL);
//    }];
}

@end
