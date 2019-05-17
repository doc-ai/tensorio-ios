//
//  TIOMRCheckpoint.m
//  TensorIO
//
//  Created by Phil Dow on 5/6/19.
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

#import "TIOMRCheckpoint.h"

@implementation TIOMRCheckpoint

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON {
    if ((self=[super init])) {
        if ( JSON[@"checkpointId"] == nil || ![JSON[@"checkpointId"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _checkpointId = JSON[@"checkpointId"];
        }
        if ( JSON[@"hyperparametersId"] == nil || ![JSON[@"hyperparametersId"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _hyperparametersId = JSON[@"hyperparametersId"];
        }
        if ( JSON[@"modelId"] == nil || ![JSON[@"modelId"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _modelId = JSON[@"modelId"];
        }
        if ( JSON[@"createdAt"] == nil || ![JSON[@"createdAt"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            NSDateFormatter *RFC3339DateFormatter = [[NSDateFormatter alloc] init];
            RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            
            _createdAt = [RFC3339DateFormatter dateFromString:JSON[@"createdAt"]];
            if ( _createdAt == nil ) { // bad dates
                return nil;
            }
        }
        if ( JSON[@"info"] == nil || ![JSON[@"info"] isKindOfClass:NSDictionary.class] ) {
            return nil;
        } else {
            _info = JSON[@"info"];
        }
        if ( JSON[@"link"] == nil || ![JSON[@"link"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _link = [NSURL URLWithString:JSON[@"link"]];
            if ( _link == nil ) {
                return nil;
            }
        }
    }
    return self;
}

- (NSString*)description {
    NSString *ms = [NSString stringWithFormat:@"Model ID: %@", self.modelId];
    NSString *hs = [NSString stringWithFormat:@"Hyperparameters ID: %@", self.hyperparametersId];
    NSString *cs = [NSString stringWithFormat:@"Checkpoint IDs: %@", self.checkpointId];
    NSString *ds = [NSString stringWithFormat:@"Created At: %@", self.createdAt];
    NSString *is = [NSString stringWithFormat:@"Info: %@", self.info];
    NSString *ls = [NSString stringWithFormat:@"Link: %@", self.link];
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@", ms, hs, cs, ds, is, ls];
}

@end
