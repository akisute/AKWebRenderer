//
//  TwitterPicturesViewTextCell.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/12.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterPicturesViewTextCell.h"

@implementation TwitterPicturesViewTextCell

- (void)onTweetUpdated
{
    [super onTweetUpdated];
    self.textView.text = self.tweet.text;
}

@end
