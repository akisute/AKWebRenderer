//
//  TwitterPicturesViewCell.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/13.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterPicturesViewCell.h"

@implementation TwitterPicturesViewCell

- (void)setTweet:(MTweets *)tweet
{
    if (_tweet == tweet) {
        return;
    }
    _tweet = tweet;
    [self onTweetUpdated];
    [self setNeedsDisplay];
}

- (void)onTweetUpdated
{
    // Override this method in each subclasses.
}

@end
