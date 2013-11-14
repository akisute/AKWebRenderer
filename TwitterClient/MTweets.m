//
//  MTweets.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/05.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "MTweets.h"

static NSMutableArray *objects;
static NSMutableSet *objectIDs;

@implementation MTweets

- (MTWeetsType)tweetType
{
    if (self.medias.count) {
        return MTWeetsTypeImage;
    } else if (self.urls.count) {
        return MTWeetsTypeWeb;
    } else {
        return MTWeetsTypeText;
    }
}

#pragma mark -

+ (void)load
{
    [super load];
    if (objects == nil) {
        objects = [NSMutableArray array];
    }
    if (objectIDs == nil) {
        objectIDs = [NSMutableSet set];
    }
}

+ (NSInteger)count
{
    @synchronized(objects) {
        return objects.count;
    }
}

+ (NSArray *)allObjects
{
    @synchronized(objects) {
        return [NSArray arrayWithArray:objects];
    }
}

+ (NSArray *)allObjectsSortedByComparator:(NSComparator)comparator
{
    NSArray *original;
    @synchronized(objects) {
        original = [NSArray arrayWithArray:objects];
    }
    return [original sortedArrayWithOptions:NSSortConcurrent usingComparator:comparator];
}

+ (NSArray *)allObjectsSortedByDescriptors:(NSArray *)descriptors
{
    NSArray *original;
    @synchronized(objects) {
        original = [NSArray arrayWithArray:objects];
    }
    return [original sortedArrayUsingDescriptors:descriptors];
}

+ (void)insertNewObject:(MTweets *)object
{
    @synchronized(objects) {
        if (![objectIDs containsObject:object.tweetID]) {
            [objects addObject:object];
            [objectIDs addObject:object.tweetID];
        }
    }
}

- (id)initWithJSONObject:(NSDictionary *)jsonObject
{
    self = [super init];
    if (self) {
        self.tweetID        = jsonObject[@"id"];
        self.userID         = jsonObject[@"user"][@"id_str"];
        self.userScreenName = jsonObject[@"user"][@"screen_name"];
        self.username       = jsonObject[@"user"][@"name"];
        self.text           = jsonObject[@"text"];
        
        NSMutableArray *urlBuffer = [NSMutableArray array];
        for (NSDictionary *urlDictionary in jsonObject[@"entities"][@"urls"]) {
            MTweetURLObject *urlObject = [[MTweetURLObject alloc] initWithJSONObject:urlDictionary];
            if (urlObject) {
                [urlBuffer addObject:urlObject];
            }
        }
        self.urls = [NSArray arrayWithArray:urlBuffer];
        
        NSMutableArray *mediaBuffer = [NSMutableArray array];
        for (NSDictionary *mediaDictionary in jsonObject[@"entities"][@"media"]) {
            MTweetMediaObject *mediaObject = [[MTweetMediaObject alloc] initWithJSONObject:mediaDictionary];
            if (mediaObject) {
                [mediaBuffer addObject:mediaObject];
            }
        }
        self.medias = [NSArray arrayWithArray:mediaBuffer];
        
        NSDictionary *retweetedStatusDictionary = jsonObject[@"retweeted_status"];
        if (retweetedStatusDictionary) {
            MTweets *retweetedStatus = [[MTweets alloc] initWithJSONObject:retweetedStatusDictionary];
            self.retweetedStatus = retweetedStatus;
        }
    }
    return self;
}

@end
