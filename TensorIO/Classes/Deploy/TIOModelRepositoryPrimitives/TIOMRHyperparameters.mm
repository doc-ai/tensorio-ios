//
//  TIOMRHyperparameters.m
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

#import "TIOMRHyperparameters.h"
#import "TIOMRErrors.h"

@implementation TIOMRHyperparameters

- (nullable instancetype)initWithJSON:(NSDictionary *)JSON error:(NSError**)error {
    if ((self=[super init])) {
        if ( JSON[@"hyperparametersIds"] == nil || ![JSON[@"hyperparametersIds"] isKindOfClass:NSArray.class] ) {
            *error = TIOMRJSONParsingError(self.class, @"hyperparametersIds", JSON);
            return nil;
        } else {
            _hyperparametersIds = JSON[@"hyperparametersIds"];
        }
        
        if ( JSON[@"modelId"] == nil || ![JSON[@"modelId"] isKindOfClass:NSString.class] ) {
            *error = TIOMRJSONParsingError(self.class, @"modelId", JSON);
            return nil;
        } else {
            _modelId = JSON[@"modelId"];
        }
        
    }
    return self;
}

- (NSString *)description {
    NSString *ms = [NSString stringWithFormat:@"Model ID: %@", self.modelId];
    NSString *hs = [NSString stringWithFormat:@"Hyperparameters IDs: %@", self.hyperparametersIds];
    return [NSString stringWithFormat:@"%@\n%@", ms, hs];
}

@end
