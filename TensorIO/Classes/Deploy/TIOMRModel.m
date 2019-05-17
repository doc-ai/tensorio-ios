//
//  TIOMRModel.m
//  TensorIO
//
//  Created by Phil Dow on 5/3/19.
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

#import "TIOMRModel.h"

@implementation TIOMRModel

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON {
    if ((self=[super init])) {
        if ( JSON[@"modelId"] == nil || ![JSON[@"modelId"] isKindOfClass:NSString.class] ) {
            return nil;
        }
        else {
            _modelId = JSON[@"modelId"];
        }
        
        if ( JSON[@"details"] == nil || ![JSON[@"details"] isKindOfClass:NSString.class] ) {
            return nil;
        }
        else {
            _details = JSON[@"details"];
        }
        
        if ( JSON[@"canonicalHyperparameters"] == nil || [JSON[@"canonicalHyperparameters"] isKindOfClass:NSNull.class] ) {
            _canonicalHyperparameters = nil;
        } else if ( ![JSON[@"canonicalHyperparameters"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _canonicalHyperparameters = JSON[@"canonicalHyperparameters"];
        }
    }
    return self;
}

- (NSString*)description {
    NSString *ms = [NSString stringWithFormat:@"Model ID: %@", self.modelId];
    NSString *ds = [NSString stringWithFormat:@"Details: %@", self.details];
    NSString *cs = [NSString stringWithFormat:@"Canonical Hyperparameters: %@", self.canonicalHyperparameters];
    return [NSString stringWithFormat:@"%@\n%@\n%@", ms, ds, cs];
}

@end
