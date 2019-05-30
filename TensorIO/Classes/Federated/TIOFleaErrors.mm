//
//  TIOFleaErrors.c
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

#import "TIOFleaErrors.h"

NSString * const TIOFleaErrorDomain = @"ai.doc.tensorio.flea";

NSInteger const TIOFleaURLRequestErrorCode = 0;
NSInteger const TIOFleaURLResponseErrorCode = 1;

NSInteger const TIOFleaNoDataErrorCode = 11;
NSInteger const TIOFleaJSONError = 12;
NSInteger const TIOFleaDeserializationError = 13;

NSInteger const TIOFleaHealthStatusNotServingError = 100;
NSInteger const TIOFleaJobStatusNotApprovedError = 200;
NSInteger const TIOFleaDownloadError = 300;
NSInteger const TIOFleaUploadError = 400;
NSInteger const TIOFleaUploadSourceDoesNotExistsError = 401;

NSError * TIOFleaJSONParsingError(Class klass, NSString *attribute, NSDictionary * _Nullable JSON) {
    return [[NSError alloc] initWithDomain:TIOFleaErrorDomain code:TIOFleaDeserializationError userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"There was a problem parsing JSON attribute %@ for class %@ with JSON %@", attribute, NSStringFromClass(klass), JSON]
    }];
}
