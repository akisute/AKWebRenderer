//
//  TwitterWebRenderWorker.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/29.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterWebRenderWorker.h"

@interface TwitterWebRenderWorker () <UIWebViewDelegate>
@property (nonatomic) UIWindow *window;     // The window which holds web view
@property (nonatomic) UIWebView *webView;   // The web view to render HTML
@property (nonatomic, strong) TwitterWebRenderWorkerCompletionHandler callback;
@end

@implementation TwitterWebRenderWorker

- (TwitterWebRenderWorkerStatus)status
{
    if (!self.webView) {
        return TwitterWebRenderWorkerStatusUnknown;
    }
    return (self.webView.loading) ? TwitterWebRenderWorkerStatusExecuting : TwitterWebRenderWorkerStatusReady;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Requires application instance (=screen, window) to render HTML using UIWebView
        UIApplication *application = [UIApplication sharedApplication];
        if (!application) {
            return nil;
        }
        
        // Uses default key window of the application as a host of web view
        // Perhaps we can create off-screen window for this, but I'm not confident whether off-screen windows can render web contents
        self.window = application.keyWindow;
        if (!self.window) {
            return nil;
        }
        
        // Create a web view and hide it below any views in the window
        self.webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
        self.webView.backgroundColor = [UIColor redColor]; // for debug purpose
        self.webView.userInteractionEnabled = NO;
        self.webView.hidden = NO;
        self.webView.delegate = self;
        UIView *backmostView = self.window.subviews.firstObject;
        [self.window insertSubview:self.webView belowSubview:backmostView];
    }
    return self;
}

- (BOOL)startRenderingWithURL:(NSURL *)url completionHandler:(TwitterWebRenderWorkerCompletionHandler)completionHandler
{
    return [self startRenderingWithRenderRequest:[TwitterWebRenderRequest renderRequestWithURL:url mode:TwitterWebRenderRequestModeFullscreen]
                               completionHandler:completionHandler];
}

- (BOOL)startRenderingWithRenderRequest:(TwitterWebRenderRequest *)renderRequest completionHandler:(TwitterWebRenderWorkerCompletionHandler)completionHandler
{
    if (self.status != TwitterWebRenderWorkerStatusReady) {
        return NO;
    }
    
    self.callback = [completionHandler copy];
    
    // TODO: handle render request corretly
    NSURLRequest *request = [NSURLRequest requestWithURL:renderRequest.url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0f];
    [self.webView loadRequest:request];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.callback) {
        // workaround code...
        UIView *view = [webView snapshotViewAfterScreenUpdates:NO];
        //UIView *view = [webView resizableSnapshotViewFromRect:CGRectMake(0, 0, 320, 320) afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        self.callback(view, webView.request.URL);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.callback) {
        self.callback(nil, webView.request.URL);
    }
}

@end
