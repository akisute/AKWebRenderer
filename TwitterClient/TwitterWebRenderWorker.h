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

@class TwitterWebRenderWorker;
@protocol TwitterWebRenderWorkerDelegate <NSObject>
@required
// no required methods
@optional
- (void)renderWorker:(TwitterWebRenderWorker *)renderWorker didFinishRenderingSnapshotView:(UIView *)view forURL:(NSURL *)url;
@end

@interface TwitterWebRenderWorker : NSObject
@property (nonatomic, readonly) TwitterWebRenderWorkerStatus status;
@property (nonatomic, weak) id<TwitterWebRenderWorkerDelegate> delegate;
- (BOOL)startRenderingWithURL:(NSURL *)url;
@end
