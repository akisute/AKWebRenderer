//
//  MTweets.h
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/05.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTweetURLObject.h"

typedef enum MTWeetsType_ {
    MTWeetsTypeUnknown = 0,
    MTWeetsTypeText,        // No URLs
    MTWeetsTypeWeb,         // Has URLs, but there's no image URL
    MTWeetsTypeImage,       // Has at least 1 image URL
} MTWeetsType;

@interface MTweets : NSObject

+ (NSInteger)count;
+ (NSArray *)allObjects;
+ (NSArray *)allObjectsSortedByComparator:(NSComparator)comparator;
+ (NSArray *)allObjectsSortedByDescriptors:(NSArray *)descriptors;
+ (void)insertNewObject:(MTweets *)object;

- (id)initWithJSONObject:(NSDictionary *)jsonObject;

@property (nonatomic, copy) NSString *tweetID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userScreenName;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *text;
@property (nonatomic) NSArray *urls;                // List of MTweetURLObject
@property (nonatomic) MTweets *retweetedStatus;     // Original MTweets Object, which is retweeted by this tweet. Does not nest.

@property (nonatomic, readonly) MTWeetsType tweetType;

@end
