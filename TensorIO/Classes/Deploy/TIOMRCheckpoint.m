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
            _createdAt = [NSDate dateWithTimeIntervalSince1970:[JSON[@"createdAt"] doubleValue]];
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

@end
