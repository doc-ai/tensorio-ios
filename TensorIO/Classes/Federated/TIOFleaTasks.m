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

NSString * const TIOFleaTasksArrayTaskId = @"taskId";
NSString * const TIOFleaTasksArrayModelURL = @"modelURL";

@implementation TIOFleaTasks

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON {
    if ((self=[super init])) {
        if ( JSON[@"startTaskId"] == nil || ![JSON[@"startTaskId"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _startTaskId = JSON[@"startTaskId"];
        }
        
        if ( JSON[@"maxItems"] == nil || ![JSON[@"maxItems"] isKindOfClass:NSNumber.class] ) {
            return nil;
        } else {
            _maxItems = ((NSNumber*)JSON[@"maxItems"]).unsignedIntegerValue;
        }
        
        if ( JSON[@"repositoryBaseUrl"] == nil || ![JSON[@"repositoryBaseUrl"] isKindOfClass:NSString.class] ) {
            return nil;
        } else {
            _baseRepositoryURL = [NSURL URLWithString:JSON[@"repositoryBaseUrl"]];
        }
        
        if ( JSON[@"taskIds"] == nil || ![JSON[@"taskIds"] isKindOfClass:NSDictionary.class] ) {
            return nil;
        } else {
            _taskIds = [self _parseTaskIds:JSON[@"taskIds"]];
            if (_taskIds == nil) {
                return nil;
            }
        }
    }
    return self;
}

- (nullable NSArray<NSDictionary<NSString*,id>*>*)_parseTaskIds:(NSDictionary<NSString*,NSString*>*)taskIds; {
    NSMutableArray *array = NSMutableArray.array;
    
    for (NSString *key in [taskIds.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        NSURL *URL = [_baseRepositoryURL URLByAppendingPathComponent:taskIds[key]];
        
        if (URL == nil) {
            return nil;
        }
        
        [array addObject:@{
            TIOFleaTasksArrayTaskId: key,
            TIOFleaTasksArrayModelURL:URL
        }];
    }
    
    return array.copy;
}

- (NSString*)description {
    NSString *ss = [NSString stringWithFormat:@"Start Task ID: %@", self.startTaskId];
    NSString *ms = [NSString stringWithFormat:@"Max Items: %lu", (unsigned long)self.maxItems];
    NSString *ts = [NSString stringWithFormat:@"Task IDs: %@", self.taskIds];
    NSString *bs = [NSString stringWithFormat:@"Base Repository URL: %@", self.baseRepositoryURL];
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@", ss, ms, ts, bs];
}

@end
