//
//  WebViewController.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/12.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTweets.h"

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic) MTweets *tweet;

- (IBAction)openActionMenu:(id)sender;

@end
