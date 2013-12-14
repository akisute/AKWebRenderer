//
//  TwitterPicturesViewWebCell.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/12.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterPicturesViewWebCell.h"

#import "AKMediaCache.h"

@interface TwitterPicturesViewWebCell ()
@property (nonatomic) UIView *snapshotView;
@end

@implementation TwitterPicturesViewWebCell

- (void)onTweetUpdated
{
    [super onTweetUpdated];
    
    /*
     Strategy:
     onTweetUpdated is only called when self.tweet is changed. This means the implementation here will never be called on the same tweet twice, but
     the cell itself will be reused on other tweets.
     
     When scrolling fast enough, this method can be called while AKMediaCache is stil rendering a snapshot for old self.tweet.
     In this case, we need to cancel previous request then ask for new snapshot.
     
     Known Problem:
     Cancel is not available right now.
     To solve this, snapshotViewWithRenderRequest:completionHandler: should return request ID for later use. Add a cancel request method
     to media cache. ImageCell also require this.
     */
    MTweetURLObject *urlObject = self.tweet.urls.firstObject;
    if (urlObject) {
        self.URLLabel.hidden = NO;
        self.URLLabel.text = urlObject.displayURLString;
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        [[AKMediaCache sharedCache] snapshotViewWithRenderRequest:[AKWebRenderRequest renderRequestWithURL:urlObject.url mode:AKWebRenderRequestModeSquareTopLeft]
                                                     completionHandler:^(UIView *view) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             if (view) {
                                                                 self.URLLabel.hidden = YES;
                                                                 self.URLLabel.text = nil;
                                                                 self.snapshotView = view;
                                                                 self.snapshotView.frame = self.contentView.bounds;
                                                                 self.snapshotView.contentMode = UIViewContentModeCenter;
                                                                 [self.contentView addSubview:self.snapshotView];
                                                             } else {
                                                                 [self.snapshotView removeFromSuperview];
                                                                 self.snapshotView = nil;
                                                             }
                                                         });
                                                     }];
    } else {
        self.URLLabel.hidden = YES;
        self.URLLabel.text = nil;
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
    }
}

@end
