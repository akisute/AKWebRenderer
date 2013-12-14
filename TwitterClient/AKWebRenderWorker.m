//
//  AKWebRenderWorker.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/29.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "AKWebRenderWorker.h"

@interface AKWebRenderWorker () <UIWebViewDelegate>
@property (nonatomic) UIWindow *window;     // The window which holds web view
@property (nonatomic) UIWebView *webView;   // The web view to render HTML

@property (nonatomic) AKWebRenderRequest *renderRequest;
@property (nonatomic, strong) AKWebRenderWorkerCompletionHandler callback;
@property (nonatomic) AKWebRenderWorkerStatus status;
@property (nonatomic) NSInteger numberOfCurrentLoads;
@end

@implementation AKWebRenderWorker

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
        
        self.status = AKWebRenderWorkerStatusReady;
        self.numberOfCurrentLoads = 0;
    }
    return self;
}

#pragma mark - Private

- (void)finishRenderingIfPossible
{
    if (self.numberOfCurrentLoads > 0) {
        NSLog(@"  waiting for current loads");
        return;
    }
    NSLog(@"  finishing");
    
    if (self.callback) {
        CGRect rect;
        switch (self.renderRequest.mode) {
            case AKWebRenderRequestModeFullscreen:
                rect = self.webView.bounds;
                break;
            case AKWebRenderRequestModeSquareTopLeft:
                if (self.webView.bounds.size.width > self.webView.bounds.size.height) {
                    rect = CGRectMake(0, 0, self.webView.bounds.size.height, self.webView.bounds.size.height);
                } else {
                    rect = CGRectMake(0, 0, self.webView.bounds.size.width, self.webView.bounds.size.width);
                }
                break;
            case AKWebRenderRequestModeSquareCenter:
                if (self.webView.bounds.size.width > self.webView.bounds.size.height) {
                    rect = CGRectMake((self.webView.bounds.size.width-self.webView.bounds.size.height)/2, 0, self.webView.bounds.size.height, self.webView.bounds.size.height);
                } else {
                    rect = CGRectMake(0, (self.webView.bounds.size.height-self.webView.bounds.size.width)/2, self.webView.bounds.size.width, self.webView.bounds.size.width);
                }
                break;
        }
        UIView *view = [self.webView resizableSnapshotViewFromRect:rect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        self.callback(view, self.renderRequest.url);
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.numberOfCurrentLoads = 0;
    self.renderRequest = nil;
    self.callback = nil;
    self.status = AKWebRenderWorkerStatusReady;
}

#pragma mark - Public

- (BOOL)startRenderingWithURL:(NSURL *)url completionHandler:(AKWebRenderWorkerCompletionHandler)completionHandler
{
    return [self startRenderingWithRenderRequest:[AKWebRenderRequest renderRequestWithURL:url mode:AKWebRenderRequestModeFullscreen]
                               completionHandler:completionHandler];
}

- (BOOL)startRenderingWithRenderRequest:(AKWebRenderRequest *)renderRequest completionHandler:(AKWebRenderWorkerCompletionHandler)completionHandler
{
    /*
     Warning:
     self.status is not thread-safe in this code.
     This means the state can be completely broken if a render worker is requested from multiple threads.
     */
    if (self.status != AKWebRenderWorkerStatusReady) {
        return NO;
    }
    
    self.renderRequest = renderRequest;
    self.callback = [completionHandler copy];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.renderRequest.url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0f];
    [self.webView loadRequest:request];
    self.status = AKWebRenderWorkerStatusExecuting;
    return YES;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.numberOfCurrentLoads = self.numberOfCurrentLoads + 1;
    NSLog(@"  loading count = %lu", self.numberOfCurrentLoads);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.numberOfCurrentLoads = self.numberOfCurrentLoads - 1;
    NSLog(@"  loading count = %lu", self.numberOfCurrentLoads);
    
    [self performSelector:@selector(finishRenderingIfPossible) withObject:nil afterDelay:0.05 inModes:@[NSRunLoopCommonModes]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.numberOfCurrentLoads = self.numberOfCurrentLoads - 1;
    NSLog(@"  loading count = %lu", self.numberOfCurrentLoads);
    
    [self performSelector:@selector(finishRenderingIfPossible) withObject:nil afterDelay:0.05 inModes:@[NSRunLoopCommonModes]];
}

@end
