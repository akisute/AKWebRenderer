//
//  WebViewController.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/12.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.tweet) {
        MTweetURLObject *urlObject = self.tweet.urls.firstObject;
        if (urlObject.url) {
            NSURLRequest *request = [NSURLRequest requestWithURL:urlObject.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0f];
            [self.webView loadRequest:request];
        }
    }
}

@end
