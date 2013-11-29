//
//  TwitterPicturesViewImageCell.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/03.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterPicturesViewImageCell.h"

#import "TwitterMediaCache.h"

@implementation TwitterPicturesViewImageCell

- (void)onTweetUpdated
{
    [super onTweetUpdated];
    MTweetMediaObject *mediaObject = self.tweet.medias.firstObject;
    if (mediaObject) {
        [[TwitterMediaCache sharedCache] imageWithURL:mediaObject.mediaURL completionHandler:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        }];
    } else {
        self.imageView.image = nil;
    }
}

@end
