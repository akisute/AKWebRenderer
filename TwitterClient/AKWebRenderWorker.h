//
//  AKWebRenderWorker.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/29.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <UIKit/UIKit.h> // Requires UIKit and views, might not work in XCTest environment
#import "AKWebRenderRequest.h"

typedef enum AKWebRenderWorkerStatus_ {
    AKWebRenderWorkerStatusUnknown = 0,
    AKWebRenderWorkerStatusReady,
    AKWebRenderWorkerStatusExecuting,
} AKWebRenderWorkerStatus;

typedef void (^AKWebRenderWorkerCompletionHandler)(UIView *view, NSURL *url);

@interface AKWebRenderWorker : NSObject
@property (nonatomic, readonly) AKWebRenderWorkerStatus status;
- (BOOL)startRenderingWithURL:(NSURL *)url completionHandler:(AKWebRenderWorkerCompletionHandler)completionHandler;
- (BOOL)startRenderingWithRenderRequest:(AKWebRenderRequest *)renderRequest completionHandler:(AKWebRenderWorkerCompletionHandler)completionHandler;
@end
