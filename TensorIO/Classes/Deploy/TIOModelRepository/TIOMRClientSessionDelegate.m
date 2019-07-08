//
//  TIOMRClientSessionDelegate.m
//  TensorIO
//
//  Created by Phil Dow on 6/7/19.
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

#import "TIOMRClientSessionDelegate.h"

@implementation TIOMRClientSessionDelegate

// MARK: - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    // NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
    [self.client URLSessionDidFinishEventsForBackgroundURLSession:session];
}

// MARK: - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // NSLog(@"URLSession:task:didCompleteWithError:");
    [self.client URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    // UPLOAD PROGRESS
    // NSLog(@"URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:");
    [self.client URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
}

// MARK: - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    // NSLog(@"URLSession:downloadTask:didFinishDownloadingToURL:");
    [self.client URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    // NSLog(@"URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:");
    [self.client URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // DOWNLOAD PROGRESS
    // NSLog(@"URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:");
    [self.client URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

// MARK: - NSURLSessionDataDelegate

// ...

@end
