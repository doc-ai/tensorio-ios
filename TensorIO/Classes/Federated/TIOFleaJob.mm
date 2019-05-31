//
//  TIOFleaJob.m
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

#import "TIOFleaJob.h"
#import "TIOFleaErrors.h"

@implementation TIOFleaJob

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON error:(NSError**)error {
    if ((self=[super init])) {
        if ( JSON[@"status"] == nil || ![JSON[@"status"] isKindOfClass:NSString.class] ) {
            *error = TIOFleaJSONParsingError(self.class, @"status", JSON);
            return nil;
        } else if ( [JSON[@"status"] isEqualToString:@"APPROVED"] ) {
            _status = TIOFleaJobStatusApproved;
        } else {
            _status = TIOFleaJobStatusUnknown;
        }
        
        if ( JSON[@"jobId"] == nil || ![JSON[@"jobId"] isKindOfClass:NSString.class] ) {
            *error = TIOFleaJSONParsingError(self.class, @"jobId", JSON);
            return nil;
        } else {
            _jobId = JSON[@"jobId"];
        }
        
        if ( JSON[@"uploadTo"] == nil || ![JSON[@"uploadTo"] isKindOfClass:NSString.class] ) {
            *error = TIOFleaJSONParsingError(self.class, @"uploadTo", JSON);
            return nil;
        } else {
            _uploadTo = [NSURL URLWithString:JSON[@"uploadTo"]];
            if ( _uploadTo == nil ) {
                *error = TIOFleaJSONParsingError(self.class, @"uploadTo", JSON);
                return nil;
            }
        }
    }
    return self;
}

- (NSString*)description {
    NSString *js = [NSString stringWithFormat:@"Job ID: %@", self.jobId];
    NSString *ss = [NSString stringWithFormat:@"Status: %@", self.status==TIOFleaJobStatusApproved?@"APPROVED":@"UNKNOWN"];
    NSString *us = [NSString stringWithFormat:@"Upload To: %@", self.uploadTo];
    return [NSString stringWithFormat:@"%@\n%@\n%@", js, ss, us];
}

@end
