//
//  TIOFleaTasks.m
//  TensorIO
//
//  Created by Phil Dow on 5/23/19.
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

#import "TIOFleaTasks.h"
#import "TIOFleaErrors.h"

@implementation TIOFleaTasks

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON error:(NSError**)error {
    if ((self=[super init])) {
        if ( JSON[@"startTaskId"] == nil || ![JSON[@"startTaskId"] isKindOfClass:NSString.class] ) {
            *error = TIOFleaJSONParsingError(self.class, @"startTaskId", JSON);
            return nil;
        } else {
            _startTaskId = JSON[@"startTaskId"];
        }
        
        if ( JSON[@"maxItems"] == nil || ![JSON[@"maxItems"] isKindOfClass:NSNumber.class] ) {
            *error = TIOFleaJSONParsingError(self.class, @"maxItems", JSON);
            return nil;
        } else {
            _maxItems = ((NSNumber*)JSON[@"maxItems"]).unsignedIntegerValue;
        }
        
        if ( JSON[@"taskIds"] == nil || ![JSON[@"taskIds"] isKindOfClass:NSArray.class] ) {
            *error = TIOFleaJSONParsingError(self.class, @"taskIds", JSON);
            return nil;
        } else {
            _taskIds = JSON[@"taskIds"];
        }
    }
    return self;
}

- (NSString*)description {
    NSString *ss = [NSString stringWithFormat:@"Start Task ID: %@", self.startTaskId];
    NSString *ms = [NSString stringWithFormat:@"Max Items: %lu", (unsigned long)self.maxItems];
    NSString *ts = [NSString stringWithFormat:@"Task IDs: %@", self.taskIds];
    return [NSString stringWithFormat:@"%@\n%@\n%@", ss, ms, ts];
}

@end
