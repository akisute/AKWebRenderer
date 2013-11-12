//
//  MTweets.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/05.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MTWeetsType_ {
    MTWeetsTypeUnknown = 0,
    MTWeetsTypeText,        // No URLs
    MTWeetsTypeWeb,         // Has URLs, but there's no image URL
    MTWeetsTypeImage,       // Has at least 1 image URL
} MTWeetsType;

@interface MTweets : NSObject

+ (NSInteger)count;
+ (NSArray *)allObjects;
+ (void)insertNewObject:(MTweets *)object;

- (id)initWithJSONObject:(NSDictionary *)jsonObject;

@property (nonatomic, copy) NSString *tweetID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userScreenName;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *text;
@property (nonatomic) NSArray *urls;                // list of NSURL objects TODO: should create MTweetURLObject instead of using direct NSURL
@property (nonatomic) MTweets *retweetedStatus;     // Original Tweet Object, which is retweeted by this tweet. Does not nest.

@property (nonatomic, readonly) MTWeetsType tweetType;

@end
