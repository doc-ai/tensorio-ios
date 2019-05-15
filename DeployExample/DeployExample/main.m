//
//  main.m
//  DeployExample
//
//  Created by Phil Dow on 5/2/19.
//  Copyright © 2019 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface NSFileManager (TestUtils)

- (void)clearTemporaryDirectory;

@end

@implementation NSFileManager (TestUtils)

- (void)clearTemporaryDirectory {
    NSArray* tmpDirectory = [self contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [self removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        [NSFileManager.defaultManager clearTemporaryDirectory];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
