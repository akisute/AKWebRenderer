//
//  AKMediaCache.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/18.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "AKMediaCache.h"
#import "AKWebRenderWorker.h"

@interface AKWebRenderRequestItem : NSObject
@property (nonatomic, copy) NSString *requestID;                                        // should be read-only
@property (nonatomic, strong) AKWebRenderRequest *renderRequest;                   // should be read-only
@property (nonatomic, strong) AKMediaCacheSnapshotViewCompletionHandler callback;  // should be read-only. Stores copied block (Heap Block), not Stack Block
+ (AKWebRenderRequestItem *)infoWithRenderRequest:(AKWebRenderRequest *)renderRequest completionHandler:(AKMediaCacheSnapshotViewCompletionHandler)completionHandler;
@end
@implementation AKWebRenderRequestItem
+ (AKWebRenderRequestItem *)infoWithRenderRequest:(AKWebRenderRequest *)renderRequest completionHandler:(AKMediaCacheSnapshotViewCompletionHandler)completionHandler
{
    AKWebRenderRequestItem *item = [[AKWebRenderRequestItem alloc] init];
    item.renderRequest = renderRequest;
    item.callback = [completionHandler copy];
    
    NSUUID *uuid = [NSUUID UUID];
    item.requestID = [uuid UUIDString];
    
    return item;
}
@end

#pragma mark -

@interface AKMediaCache ()
@property (nonatomic) NSURLSession *mediaSession;
@property (nonatomic) AKWebRenderWorker *webRenderWorker;
@property (nonatomic) NSMutableArray *webRenderRequestQueue;    // V=AKWebRenderRequestItem. Must be locked before read/write.
@property (nonatomic) NSCache *webSnapshotCache;                // V=UIView, K=AKWebRenderRequest.
@end

@implementation AKMediaCache

+ (id)sharedCache
{
    static AKMediaCache* sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[AKMediaCache alloc] init];
    });
    return sharedCache;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Setup image session
        // Cookie Storage and Credential Storage is always shared
        // Create own Cache Storage for Media (images, possibly videos, anything that can be handled by NSData fetch)
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:20*1000*1000 diskCapacity:100*1000*1000 diskPath:@"Media"];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.URLCache = cache;
        configuration.timeoutIntervalForRequest = 10.0f;
        configuration.timeoutIntervalForResource = 45.0f;
        self.mediaSession = [NSURLSession sessionWithConfiguration:configuration];
        
        // Setup web render worker and queue
        self.webRenderWorker = [[AKWebRenderWorker alloc] init];
        self.webRenderRequestQueue = [NSMutableArray array];
        self.webSnapshotCache = [[NSCache alloc] init];
        self.webSnapshotCache.totalCostLimit = 20*1000*1000;
    }
    return self;
}

#pragma mark - Public

- (BOOL)imageWithURL:(NSURL *)url completionHandler:(AKMediaCacheImageCompletionHandler)completionHandler
{
    AKMediaCacheImageCompletionHandler callback = [completionHandler copy];
    [[self.mediaSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            callback(nil);
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        callback(image);
    }] resume];
    return YES;
}

- (BOOL)snapshotViewWithURL:(NSURL *)url completionHandler:(AKMediaCacheSnapshotViewCompletionHandler)completionHandler
{
    return [self snapshotViewWithRenderRequest:[AKWebRenderRequest renderRequestWithURL:url mode:AKWebRenderRequestModeFullscreen]
                             completionHandler:completionHandler];
}

- (BOOL)snapshotViewWithRenderRequest:(AKWebRenderRequest *)renderRequest completionHandler:(AKMediaCacheSnapshotViewCompletionHandler)completionHandler
{
    /*
     Strategy:
     1. Place UIWebView instance silently on window, hiding behind any views. They are treated as 'render workers'.
     2. Queue URL requests
     3. Dequeue URL requests into render workers whenever they are available
     4. When URL requests are finished in render workers, call resizableSnapshotViewFromRect:afterScreenUpdates:withCapInsets: to grab the snapshot, then return it
     
     For current implementation, only 1 render worker is available at a time.
     
     For current implementation, only portrait mode is available. The UIWebView doesn't handle view rotation itself without any support of UIViewControllers, so we need some solutions to this
     */
    
    UIView *cachedView = [self __cachedSnapshotViewForRenderRequest:renderRequest];
    if (cachedView) {
        AKMediaCacheSnapshotViewCompletionHandler callback = [completionHandler copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            callback(cachedView);
        });
    } else {
        [self __enqueueSnapshotViewRenderRequest:renderRequest completionHandler:completionHandler];
        [self __popSnapshotViewRenderRequest:NO];
    }
    return YES;
}

- (void)cancelSnapshotViewRequestWithRequestID:(NSString *)requestID
{
    /*
     For now, just simply removing item from queue
     Should cancel more aggressively by canceling render worker if the current render job has specified ID
     (ID/worker table should be managed by this class. Do not add ID property on render worker)
     */
    @synchronized(_webRenderRequestQueue) {
        AKWebRenderRequestItem *itemToRemove = nil;
        for (AKWebRenderRequestItem *item in self.webRenderRequestQueue) {
            if ([item.requestID isEqualToString:requestID]) {
                itemToRemove = item;
                break;
            }
        }
        if (itemToRemove) {
            [self.webRenderRequestQueue removeObject:itemToRemove];
        }
    }
}

#pragma mark - Private

- (void)__enqueueSnapshotViewRenderRequest:(AKWebRenderRequest *)renderRequest completionHandler:(AKMediaCacheSnapshotViewCompletionHandler)completionHandler
{
    NSLog(@"enqueueing render request: %@", renderRequest.url);
    AKWebRenderRequestItem *item = [AKWebRenderRequestItem infoWithRenderRequest:renderRequest completionHandler:completionHandler];
    @synchronized(_webRenderRequestQueue) {
        [self.webRenderRequestQueue addObject:item];
    }
}

- (void)__popSnapshotViewRenderRequest:(BOOL)force
{
    if (!force && self.webRenderWorker.status != AKWebRenderWorkerStatusReady) {
        NSLog(@"ignoring pop: render worker not available right now");
        return;
    }
    
    AKWebRenderRequestItem *item = nil;
    @synchronized(_webRenderRequestQueue) {
        if (self.webRenderRequestQueue.count > 0) {
            item = self.webRenderRequestQueue.firstObject;
            [self.webRenderRequestQueue removeObjectAtIndex:0];
        }
    }
    if (!item) {
        NSLog(@"ignoring pop: no render request queued");
        return;
    }
    
    NSLog(@"consuming render request: %@", item.renderRequest.url);
    UIView *cachedView = [self __cachedSnapshotViewForRenderRequest:item.renderRequest];
    if (cachedView) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            item.callback(cachedView);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self __popSnapshotViewRenderRequest:YES];
            });
        });
    } else {
        [self.webRenderWorker startRenderingWithRenderRequest:item.renderRequest completionHandler:^(UIView *view, NSURL *url) {
            NSLog(@"render request completed: %@", url);
            [self __storeSnapshotView:view forRenderRequest:item.renderRequest];
            item.callback(view);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self __popSnapshotViewRenderRequest:YES];
            });
        }];
    }
}

- (void)__storeSnapshotView:(UIView *)view forRenderRequest:(AKWebRenderRequest *)renderRequest
{
    [self.webSnapshotCache setObject:view forKey:renderRequest cost:(view.bounds.size.width * view.bounds.size.height * 8)];
}

- (UIView *)__cachedSnapshotViewForRenderRequest:(AKWebRenderRequest *)renderRequest
{
    UIView *cachedView = [self.webSnapshotCache objectForKey:renderRequest];
    if (cachedView) {
        CALayer *layer = cachedView.layer;
        while (layer.sublayers.count > 0) {
            layer = layer.sublayers.firstObject;
        }
        UIView *copyView = [[UIView alloc] initWithFrame:cachedView.frame];
        copyView.contentMode = UIViewContentModeScaleToFill;
        copyView.contentScaleFactor = cachedView.contentScaleFactor;
        copyView.layer.contents = layer.contents;
        copyView.layer.contentsRect = layer.contentsRect;
        copyView.layer.contentsScale = layer.contentsScale;
        copyView.layer.rasterizationScale = layer.rasterizationScale;
        
        UIView *containerView = [[UIView alloc] initWithFrame:cachedView.frame];
        containerView.contentMode = UIViewContentModeCenter;
        containerView.contentScaleFactor = 1.0f;
        [containerView addSubview:copyView];
        return containerView;
    } else {
        return nil;
    }
}

@end
