//
//  TIOFederatedTaskBundle.m
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

#import "TIOFederatedTaskBundle.h"
#import "TIOFederatedTask.h"

NSString * const TIOFederatedTaskBundleExtension = @"tiotask";
NSString * const TIOTaskInfoFile = @"task.json";

@implementation TIOFederatedTaskBundle

- (nullable instancetype)initWithPath:(NSString *)path {
    if ((self=[super init])) {
        
        NSFileManager *fm = NSFileManager.defaultManager;
        BOOL isDir;
        
        // Valid bundle path
        
        if ( ![fm fileExistsAtPath:path isDirectory:&isDir] || !isDir ) {
            NSLog(@"No tiotask bundle exists at path %@", path);
            return nil;
        }
        
        // Valid JSON path
        
        NSString *JSONPath = [path stringByAppendingPathComponent:TIOTaskInfoFile];
        
        if ( ![fm fileExistsAtPath:JSONPath] ) {
            NSLog(@"No task.json exists at path %@", JSONPath);
            return nil;
        }
        
        // Valid JSON
        
        NSError *JSONError;
        NSData *JSONData = [NSData dataWithContentsOfFile:JSONPath];
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&JSONError];
        
        if ( JSON == nil ) {
            NSLog(@"Error reading json file at path %@, error %@", JSONPath, JSONError);
            return nil;
        }
        
        // Bundle properties
        
        _task = [[TIOFederatedTask alloc] initWithJSON:JSON];
        _path = path;
    }
    return self;
}

@end
