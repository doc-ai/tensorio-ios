//
//  TIOMockFederatedManagerDelegate.m
//  FederatedExampleTests
//
//  Created by Phil Dow on 5/28/19.
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

#import "TIOMockFederatedManagerDelegate.h"

@implementation TIOMockFederatedManagerDelegate {
    NSMutableDictionary<NSString*,NSNumber*> *_willBeginProcessingTaskWithIdCount;
    NSMutableDictionary<NSString*,NSNumber*> *_didCompleteTaskWithIdCount;
    NSMutableDictionary<NSNumber*,NSNumber*> *_didBeginActionCount;
    NSMutableDictionary<NSNumber*,NSNumber*> *_didFailWithErrorCount;
}

- (instancetype)initWithExpectation:(XCTestExpectation *)expectation {
    if ((self=[super init])) {
        _willBeginProcessingTaskWithIdCount = NSMutableDictionary.dictionary;
        _didCompleteTaskWithIdCount = NSMutableDictionary.dictionary;
        _didBeginActionCount = NSMutableDictionary.dictionary;
        _didFailWithErrorCount = NSMutableDictionary.dictionary;
        _expectation = expectation;
    }
    return self;
}

// MARK: - Mock Count Tracking

- (NSUInteger)willBeginProcessingTaskWithIdCountForTaskId:(NSString *)taskId {
    if ( _willBeginProcessingTaskWithIdCount[taskId] == nil ) {
        return 0;
    }
    
    return _willBeginProcessingTaskWithIdCount[taskId].unsignedIntegerValue;
}

- (NSUInteger)didCompleteTaskWithIdCountForTaskId:(NSString *)taskId {
    if ( _didCompleteTaskWithIdCount[taskId] == nil ) {
        return 0;
    }
    
    return _didCompleteTaskWithIdCount[taskId].unsignedIntegerValue;
}

- (NSUInteger)didBeginActionCountForAction:(TIOFederatedManagerAction)action {
    if ( _didBeginActionCount[@(action)] == nil ) {
        return 0;
    }
    
    return _didBeginActionCount[@(action)].unsignedIntegerValue;
    
}

- (NSUInteger)didFailWithErrorCountForAction:(TIOFederatedManagerAction)action {
    if ( _didFailWithErrorCount[@(action)] == nil ) {
        return 0;
    }
    
    return _didFailWithErrorCount[@(action)].unsignedIntegerValue;
}

// MARK: - Delegate Methods

- (void)federatedManager:(TIOFederatedManager *)manager willBeginProcessingTaskWithId:(NSString *)taskId {
    if ( _willBeginProcessingTaskWithIdCount[taskId] == nil ) {
        _willBeginProcessingTaskWithIdCount[taskId] = @(0);
    }
    
    _willBeginProcessingTaskWithIdCount[taskId] = @(_willBeginProcessingTaskWithIdCount[taskId].unsignedIntegerValue+1);
}

- (void)federatedManager:(TIOFederatedManager *)manager didCompleteTaskWithId:(NSString *)taskId {
    [self.expectation fulfill];
    
    if ( _didCompleteTaskWithIdCount[taskId] == nil ) {
        _didCompleteTaskWithIdCount[taskId] = @(0);
    }
    
    _didCompleteTaskWithIdCount[taskId] = @(_didCompleteTaskWithIdCount[taskId].unsignedIntegerValue+1);
}

- (void)federatedManager:(TIOFederatedManager *)manager didBeginAction:(TIOFederatedManagerAction)action {
    if ( _didBeginActionCount[@(action)] == nil ) {
        _didBeginActionCount[@(action)] = @(0);
    }
    
    _didBeginActionCount[@(action)] = @(_didBeginActionCount[@(action)].unsignedIntegerValue+1);
}

- (void)federatedManager:(TIOFederatedManager *)manager didFailWithError:(NSError *)error forAction:(TIOFederatedManagerAction)action {
    [self.expectation fulfill];
    
    if ( _didFailWithErrorCount[@(action)] == nil ) {
        _didFailWithErrorCount[@(action)] = @(0);
    }
    
    _didFailWithErrorCount[@(action)] = @(_didFailWithErrorCount[@(action)].unsignedIntegerValue+1);
}

@end
