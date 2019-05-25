//
//  TIOFleaTask.m
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

#import "TIOFleaTask.h"

@implementation TIOFleaTask

+ (NSDateFormatter*)JSONDateFormatter {
    static NSDateFormatter *RFC3339DateFormatter;
    
    if ( RFC3339DateFormatter == nil ) {
        RFC3339DateFormatter = [[NSDateFormatter alloc] init];
        RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    
    return RFC3339DateFormatter;
}

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON {
    if ((self=[super init])) {
        if ( JSON[@"modelId"] == nil || ![JSON[@"modelId"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _modelId = JSON[@"modelId"];
        }
        
        if ( JSON[@"hyperparametersId"] == nil || ![JSON[@"hyperparametersId"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _hyperparametersId = JSON[@"hyperparametersId"];
        }
        
        if ( JSON[@"checkpointId"] == nil || ![JSON[@"checkpointId"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _checkpointId = JSON[@"checkpointId"];
        }
        
        if ( JSON[@"taskId"] == nil || ![JSON[@"taskId"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _taskId = JSON[@"taskId"];
        }
        
        if ( JSON[@"active"] == nil || ![JSON[@"active"] isKindOfClass:NSNumber.class] ) {
            return nil;
        } else {
            _active = ((NSNumber*)JSON[@"active"]).boolValue;
        }
        
        if ( JSON[@"deadline"] == nil || ![JSON[@"deadline"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _deadline = [[TIOFleaTask JSONDateFormatter] dateFromString:JSON[@"deadline"]];
            if ( _deadline == nil ) { // bad dates
                return nil;
            }
        }
        
        if ( JSON[@"link"] == nil || ![JSON[@"link"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _link = [NSURL URLWithString:JSON[@"link"]];
            if ( _link == nil ) {
                return nil;
            }
        }
        
        if ( JSON[@"checkpointLink"] == nil || ![JSON[@"checkpointLink"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _checkpointLink = [NSURL URLWithString:JSON[@"checkpointLink"]];
            if ( _checkpointLink == nil ) {
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
    NSString *ts = [NSString stringWithFormat:@"Task ID: %@", self.taskId];
    NSString *as = [NSString stringWithFormat:@"Active: %@", self.active?@"YES":@"NO"];
    NSString *ds = [NSString stringWithFormat:@"Deadline: %@", self.deadline];
    NSString *ls = [NSString stringWithFormat:@"Link: %@", self.link];
    NSString *chs = [NSString stringWithFormat:@"Checkpoint: %@", self.checkpointLink];
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@", ms, hs, cs, ts, as, ds, ls, chs];
}

@end
