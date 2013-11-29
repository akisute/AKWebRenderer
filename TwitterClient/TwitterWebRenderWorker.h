//
//  TwitterWebRenderWorker.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/29.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <UIKit/UIKit.h> // Requires UIKit and views, might not work in XCTest environment

typedef enum TwitterWebRenderWorkerStatus_ {
    TwitterWebRenderWorkerStatusUnknown = 0,
    TwitterWebRenderWorkerStatusReady,
    TwitterWebRenderWorkerStatusExecuting,
} TwitterWebRenderWorkerStatus;

typedef void (^TwitterWebRenderWorkerCompletionHandler)(UIView *view, NSURL *url);

@interface TwitterWebRenderWorker : NSObject
@property (nonatomic, readonly) TwitterWebRenderWorkerStatus status;
- (BOOL)startRenderingWithURL:(NSURL *)url completionHandler:(TwitterWebRenderWorkerCompletionHandler)completionHandler;
@end
