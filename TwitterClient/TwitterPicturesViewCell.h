//
//  TwitterPicturesViewCell.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/13.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTweets.h"

@interface TwitterPicturesViewCell : UICollectionViewCell

@property (nonatomic) MTweets *tweet;

- (void)onTweetUpdated;

@end
