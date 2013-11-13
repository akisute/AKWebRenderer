//
//  TwitterPicturesViewWebCell.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/12.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterPicturesViewWebCell.h"

@implementation TwitterPicturesViewWebCell

- (void)onTweetUpdated
{
    [super onTweetUpdated];
    MTweetURLObject *urlObject = self.tweet.urls.firstObject;
    self.URLLabel.text = urlObject.displayURLString;
}

@end
