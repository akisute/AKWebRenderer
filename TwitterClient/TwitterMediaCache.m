//
//  TwitterMediaCache.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/18.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterMediaCache.h"

@interface TwitterMediaCache ()
@property (nonatomic) NSURLSession *session;
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
    /*
     Strategy:
     1. place UIWebView instance silently on window on initialize, hiding behind any views
     2. ask the UIWebView to request
     3. when request is finished, use resizableSnapshotViewFromRect:afterScreenUpdates:withCapInsets: to grab the snapshow
     4. return the snapshot. The view might be resized in completion handler.
     
     must queue snapshot requests because one 'worker UIWebView' can handle only one requests at a time
     place several 'worker UIWebView' if performance is not appropriate but it will be very complecated...
     */
    return NO;
}

@end
