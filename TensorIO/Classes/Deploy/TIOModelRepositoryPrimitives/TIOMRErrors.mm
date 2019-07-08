//
//  TIOMRErrors.c
//  TensorIO
//
//  Created by Phil Dow on 5/30/19.
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

#import "TIOMRErrors.h"

NSString * const TIOMRErrorDomain = @"ai.doc.tensorio.model-repo";

NSInteger const TIOMRURLRequestErrorCode = 0;
NSInteger const TIOMRURLResponseErrorCode = 1;

NSInteger const TIOMRNoDataErrorCode = 11;
NSInteger const TIOMRJSONError = 12;
NSInteger const TIOMRDeserializationError = 13;

NSInteger const TIOMRHealthStatusNotServingError = 100;
NSInteger const TIOMRDownloadError = 200;

NSError * TIOMRJSONParsingError(Class klass, NSString *attribute, NSDictionary * _Nullable JSON) {
    return [[NSError alloc] initWithDomain:TIOMRErrorDomain code:TIOMRDeserializationError userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"There was a problem parsing JSON attribute %@ for class %@ with JSON %@", attribute, NSStringFromClass(klass), JSON]
    }];
}
