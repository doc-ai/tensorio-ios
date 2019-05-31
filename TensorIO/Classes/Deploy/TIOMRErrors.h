//
//  TIOMRErrors.h
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

#ifndef TIOMRErrors_h
#define TIOMRErrors_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TIOMRErrorDomain;

extern NSInteger const TIOMRURLRequestErrorCode;
extern NSInteger const TIOMRURLResponseErrorCode;

extern NSInteger const TIOMRNoDataErrorCode;
extern NSInteger const TIOMRJSONError;
extern NSInteger const TIOMRDeserializationError;

extern NSInteger const TIOMRHealthStatusNotServingError;
extern NSInteger const TIOMRDownloadError;

NSError * TIOMRJSONParsingError(Class klass, NSString *attribute, NSDictionary * _Nullable JSON);

NS_ASSUME_NONNULL_END

#endif /* TIOMRErrors_h */
