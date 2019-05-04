//
//  TIOMRHyperparameter.h
//  TensorIO
//
//  Created by Phil Dow on 5/3/19.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A model repository hyperparameter uniquely identifies the hyperparameters
 * with which a given model has been trained.
 */

@interface TIOMRHyperparameter : NSObject

/**
 * The id of the model with which this hyperparameter is associated
 */

@property (readonly) NSString *modelId;

/**
 * The hyperparameter id
 */

@property (readonly) NSString *hyperparameterId;

/**
 * The id of the hyperparmater this (model, hyperparameter) upgrades to
 */

@property (nullable, readonly) NSString *upgradeTo;

/**
 * Human readable hyperparameters
 */

@property (readonly) NSDictionary<NSString*,NSString*> *hyperparameters;

/**
 * The canonical checkpoint for the model trained with these hyperparameters
 */

@property (readonly) NSString *canonicalCheckpoint;

- (nullable instancetype)initWithJSON:(NSDictionary*)JSON NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
