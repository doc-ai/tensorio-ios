//
//  ViewController.m
//  FederatedExample
//
//  Created by Phil Dow on 5/18/19.
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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *taskId = @"b7";
    
    // Configure Client
    
    NSURL *URL = [NSURL URLWithString:@"https://flea-test.dev.docai.beer/rest/v1/flea"];
    
    NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
    configuration.HTTPAdditionalHeaders = @{
        @"Authorization": @"Bearer ClientToken"
    };

    NSURLSession *URLSession = [NSURLSession sessionWithConfiguration:configuration];
    
    TIOFleaClient *client = [[TIOFleaClient alloc] initWithBaseURL:URL session:URLSession];

    // Begin Tests

//    [client GETHealthStatus:^(TIOFleaStatus * _Nullable response, NSError * _Nonnull error) {
//        if (error) {
//            NSLog(@"There was an error, %@", error);
//            return;
//        }
//
//        NSLog(@"HEALTH STATUS: %@", response);
//    }];
    
//    [client GETTasksWithModelId:nil hyperparametersId:nil checkpointId:nil callback:^(TIOFleaTasks * _Nullable tasks, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error, %@", error);
//            return;
//        }
//
//        NSLog(@"Tasks are: %@", tasks);
//    }];

//    [client GETTaskWithTaskId:taskId callback:^(TIOFleaTask * _Nullable task, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error, %@", error);
//            return;
//        }
//
//        NSLog(@"Task is: %@", task);
//    }];

//    [client GETStartTaskWithTaskId:taskId callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error, %@", error);
//            return;
//        }
//
//        NSLog(@"Job is: %@", job);
//    }];

//    [client GETStartTaskWithTaskId:taskId callback:^(TIOFleaJob * _Nullable job, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"There was an error, %@", error);
//            return;
//        }
//
//        NSLog(@"Job is: %@", job);
//        
//        NSURL *testJobResultsFileURL = [NSBundle.mainBundle URLForResource:@"test-job-results" withExtension:@"zip"];
//
//        [client uploadJobResultsAtURL:testJobResultsFileURL toURL:job.uploadTo withJobId:job.jobId callback:^(TIOFleaJobUpload * _Nullable upload, double progress, NSError * _Nullable error) {
//            if (error) {
//                NSLog(@"There was an error, %@", error);
//                return;
//            }
//            
//            NSLog(@"Upload is: %@", upload);
//        }];
//    }];

}

@end
