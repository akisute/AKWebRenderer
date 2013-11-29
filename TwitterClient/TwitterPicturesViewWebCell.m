//
//  TwitterPicturesViewWebCell.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/12.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterPicturesViewWebCell.h"

#import "TwitterMediaCache.h"

@interface TwitterPicturesViewWebCell ()
@property (nonatomic) UIView *snapshotView;
@end

@implementation TwitterPicturesViewWebCell

- (void)onTweetUpdated
{
    [super onTweetUpdated];
    MTweetURLObject *urlObject = self.tweet.urls.firstObject;
    if (urlObject) {
        self.URLLabel.hidden = NO;
        self.URLLabel.text = urlObject.displayURLString;
        [[TwitterMediaCache sharedCache] snapshotViewWithURL:urlObject.url completionHandler:^(UIView *view) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (view) {
                    self.URLLabel.hidden = YES;
                    [self.snapshotView removeFromSuperview];
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
