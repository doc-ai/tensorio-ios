//
//  TIOFleaTaskDownload.m
//  TensorIO
//
//  Created by Phil Dow on 5/24/19.
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

#import "TIOFleaTaskDownload.h"

@implementation TIOFleaTaskDownload

- (instancetype)initWithURL:(NSURL*)URL taskId:(NSString*)taskId {
    if ((self=[super init])) {
        _taskId = taskId;
        _URL = URL;
    }
    return self;
}

- (NSString*)description {
    NSString *ts = [NSString stringWithFormat:@"Task ID: %@", self.taskId];
    NSString *us = [NSString stringWithFormat:@"URL: %@", self.URL];
    return [NSString stringWithFormat:@"%@\n%@", ts, us];
}

@end
