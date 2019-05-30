//
//  TIOFleaErrors.h
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

#ifndef TIOFleaErrors_h
#define TIOFleaErrors_h

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TIOFleaErrorDomain;

extern NSInteger const TIOFleaURLRequestErrorCode;
extern NSInteger const TIOFleaURLResponseErrorCode;

extern NSInteger const TIOFleaNoDataErrorCode;
extern NSInteger const TIOFleaJSONError;
extern NSInteger const TIOFleaDeserializationError;

extern NSInteger const TIOFleaHealthStatusNotServingError;
extern NSInteger const TIOFleaJobStatusNotApprovedError;
extern NSInteger const TIOFleaDownloadError;
extern NSInteger const TIOFleaUploadError;
extern NSInteger const TIOFleaUploadSourceDoesNotExistsError;

NSError * TIOFleaJSONParsingError(Class klass, NSString *attribute, NSDictionary * _Nullable JSON);

NS_ASSUME_NONNULL_END

#endif /* TIOFleaErrors_h */
