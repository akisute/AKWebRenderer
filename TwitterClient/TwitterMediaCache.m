//
//  TwitterMediaCache.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/18.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterMediaCache.h"
#import "TwitterWebRenderWorker.h"

@interface TwitterMediaCache ()
@property (nonatomic) NSURLSession *session;
@property (nonatomic) TwitterWebRenderWorker *webRenderWorker;
@end

@implementation TwitterMediaCache

+ (id)sharedCache
{
    static TwitterMediaCache* sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[TwitterMediaCache alloc] init];
    });
    return sharedCache;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Cookie Storage and Credential Storage is always shared
        // Create own Cache Storage for Media
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:20*1000*1000 diskCapacity:100*1000*1000 diskPath:@"Media"];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.URLCache = cache;
        configuration.timeoutIntervalForRequest = 10.0f;
        configuration.timeoutIntervalForResource = 45.0f;
        self.session = [NSURLSession sessionWithConfiguration:configuration];
        
        // Setup web render worker
        self.webRenderWorker = [[TwitterWebRenderWorker alloc] init];
    }
    return self;
}

- (BOOL)imageWithURL:(NSURL *)url completionHandler:(TwitterMediaCacheImageCompletionHandler)completionHandler
{
    TwitterMediaCacheImageCompletionHandler callback = [completionHandler copy];
    [[self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            callback(nil);
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        callback(image);
    }] resume];
    return YES;
}

- (BOOL)snapshotViewWithURL:(NSURL *)url completionHandler:(TwitterMediaCacheSnapshotViewCompletionHandler)completionHandler
{
    return [self snapshotViewWithRenderRequest:[TwitterWebRenderRequest renderRequestWithURL:url mode:TwitterWebRenderRequestModeFullscreen]
                             completionHandler:completionHandler];
}

- (BOOL)snapshotViewWithRenderRequest:(TwitterWebRenderRequest *)renderRequest completionHandler:(TwitterMediaCacheSnapshotViewCompletionHandler)completionHandler
{
    /*
     Strategy:
     1. Place UIWebView instance silently on window, hiding behind any views. They are treated as 'render workers'.
     2. Queue URL requests
     3. Dequeue URL requests into render workers whenever they are available
     4. When URL requests are finished in render workers, call resizableSnapshotViewFromRect:afterScreenUpdates:withCapInsets: to grab the snapshot, then return it
     
     For current implementation, only 1 render worker is available at a time. Having multiple render workers could result in very complecated code.
     */
    
    // TODO: need a queue system
    // TODO: need a cache system
    
    TwitterMediaCacheSnapshotViewCompletionHandler callback = [completionHandler copy];
    return [self.webRenderWorker startRenderingWithRenderRequest:renderRequest completionHandler:^(UIView *view, NSURL *url) {
        callback(view);
    }];
}

@end
