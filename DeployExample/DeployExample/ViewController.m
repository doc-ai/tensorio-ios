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
    
    NSURL *URL = [NSURL URLWithString:@"https://tio-models-test.dev.docai.beer/rest/v1/repository"];
    self.repository = [[TIOModelRepository alloc] initWithBaseURL:URL session:nil];
    
//    [self.repository GETHealthStatus:^(TIOMRStatus * _Nullable response, NSError * _Nonnull error) {
//        if (error) {
//            NSLog(@"There was an error getting status");
//            return;
//        }
//
//        NSLog(@"HEALTH STATUS: %lu", (unsigned long)response.status);
//    }];
    
//    [self.repository GETModels:^(TIOMRModels * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error getting models");
//            return;
//        }
//
//        NSLog(@"MODELS: %@", response.modelIds);
//    }];

//    [self.repository GETModelWithId:@"TestModel-1557962403" callback:^(TIOMRModel * _Nullable model, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error getting model");
//            return;
//        }
//
//        NSLog(@"MODEL: %@", model);
//    }];
    
//    [self.repository GETHyperparametersForModelWithId:@"TestModel-1557962403" callback:^(TIOMRHyperparameters * _Nullable hyperparameters, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error getting model");
//            return;
//        }
//
//        NSLog(@"HYPERPARAMETERS: %@", hyperparameters.hyperparametersIds);
//    }];
    
//    [self.repository GETHyperparameterForModelWithId:@"TestModel-1557962403" hyperparametersId:@"hyperparameters-1" callback:^(TIOMRHyperparameter * _Nullable hyperparameter, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error getting model");
//            return;
//        }
//
//        NSLog(@"HYPERPARAMETER: %@", hyperparameter.hyperparametersId);
//    }];
    
//    [self.repository GETCheckpointsForModelWithId:@"TestModel-1557962403" hyperparametersId:@"hyperparameters-1" callback:^(TIOMRCheckpoints * _Nullable checkpoints, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error getting model");
//            return;
//        }
//
//        NSLog(@"CHECKPOINTS: %@", checkpoints.checkpointIds);
//    }];
    
    [self.repository GETCheckpointForModelWithId:@"TestModel-1557962403" hyperparametersId:@"hyperparameters-1" checkpointId:@"checkpoint-1" callback:^(TIOMRCheckpoint * _Nullable checkpoint, NSError * _Nullable error) {
        if (error) {
            NSLog(@"There was an error getting model");
            return;
        }

        NSLog(@"CHECKPOINT: %@", checkpoint.checkpointId);
    }];
}

@end
