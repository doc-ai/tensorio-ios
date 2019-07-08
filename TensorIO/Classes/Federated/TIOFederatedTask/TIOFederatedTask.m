//
//  TIOFederatedTask.m
//  TensorIO
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

#import "TIOFederatedTask.h"

@implementation TIOFederatedTask

- (nullable instancetype)initWithJSON:(NSDictionary *)JSON {
    if ((self=[super init])) {
        _identifier = JSON[@"id"];
        _name = JSON[@"name"];
        _details = JSON[@"details"];
        _modelIdentifier = JSON[@"model"][@"id"];
        _epochs = ((NSNumber *)JSON[@"taskParameters"][@"numEpochs"]).unsignedIntegerValue;
        _batchSize = ((NSNumber *)JSON[@"taskParameters"][@"batchSize"]).unsignedIntegerValue;
        _shuffle = ((NSNumber *)JSON[@"taskParameters"][@"shuffle"]).boolValue;
        
        [self parsePlacholders:JSON[@"taskParameters"][@"placeholders"]];
    }
    return self;
}

- (void)parsePlacholders:(NSArray *)placeholders {
    // Currently unused
    _placeholders = nil;
}

@end
