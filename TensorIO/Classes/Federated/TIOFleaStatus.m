//
//  TIOFleaStatus.m
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

#import "TIOFleaStatus.h"

@implementation TIOFleaStatus

- (instancetype)initWithJSON:(NSDictionary*)JSON {
    if ((self=[super init])) {
        if ( JSON[@"status"] == nil || ![JSON[@"status"] isKindOfClass:NSString.class] ) {
            return nil;
        }
        if ( [JSON[@"status"] isEqualToString:@"SERVING"] ) {
            _status = TIOFleaStatusValueServing;
        } else {
            _status = TIOFleaStatusValueUnknown;
        }
    }
    return self;
}

- (NSString*)description {
    switch (self.status) {
    case TIOFleaStatusValueUnknown:
         return @"TIOFleaStatusValueUnknown";
    case TIOFleaStatusValueServing:
        return @"TIOFleaStatusValueServing";
    default:
        return @"Uknown status";
    }
}

@end
