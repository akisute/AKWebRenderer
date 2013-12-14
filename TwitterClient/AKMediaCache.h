//
//  AKMediaCache.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/18.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <UIKit/UIKit.h> // Requires UIKit and views, might not work in XCTest environment
#import "AKWebRenderRequest.h"

typedef void (^AKMediaCacheImageCompletionHandler)(UIImage *image);
typedef void (^AKMediaCacheSnapshotViewCompletionHandler)(UIView *view);

@interface AKMediaCache : NSObject

+ (id)sharedCache;

- (BOOL)imageWithURL:(NSURL *)url completionHandler:(AKMediaCacheImageCompletionHandler)completionHandler;

- (BOOL)snapshotViewWithURL:(NSURL *)url completionHandler:(AKMediaCacheSnapshotViewCompletionHandler)completionHandler;
- (BOOL)snapshotViewWithRenderRequest:(AKWebRenderRequest *)renderRequest completionHandler:(AKMediaCacheSnapshotViewCompletionHandler)completionHandler;
- (void)cancelSnapshotViewRequestWithRequestID:(NSString *)requestID;

@end
