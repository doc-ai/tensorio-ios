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

// Note that other information encapsulated in the placeholder dictionary, such
// as type, dtype, and shape, are currently ignored but should match the
// placeholder description in the target model.

- (void)parsePlacholders:(nullable NSArray *)JSON {
    if ( JSON == nil ) {
        _placeholders = nil;
        return;
    }
    
    NSMutableDictionary *placeholders = NSMutableDictionary.dictionary;
    
    for ( NSDictionary *item in JSON ) {
        placeholders[item[@"name"]] = item[@"value"];
    }
    
    if ( placeholders.count == 0 ) {
        _placeholders = nil;
        return;
    }
    
    _placeholders = placeholders.copy;
}

@end
